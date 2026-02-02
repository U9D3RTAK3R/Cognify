package api

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"

	"cache-crew/cognify/internal/db"
	"cache-crew/cognify/internal/models"
	"cache-crew/cognify/internal/services"

	"cloud.google.com/go/firestore"
	"github.com/google/generative-ai-go/genai"
)

// LessonCompleteRequest represents the request body for lesson completion
type LessonCompleteRequest struct {
	UserID     string         `json:"userId"`
	CourseID   string         `json:"courseId"`
	LevelID    string         `json:"levelId"`
	Answers    []AnswerSubmit `json:"answers"`
	TimeTakenS int            `json:"timeTakenSeconds"`
}

type AnswerSubmit struct {
	QuestionID    string `json:"questionId"`
	SelectedIndex int    `json:"selectedIndex"`
}

// LessonCompleteResponse contains the result of lesson completion
type LessonCompleteResponse struct {
	Success         bool     `json:"success"`
	Message         string   `json:"message"`
	XPGained        int      `json:"xpGained"`
	CorrectCount    int      `json:"correctCount"`
	TotalQuestions  int      `json:"totalQuestions"`
	NewTotalXP      int      `json:"newTotalXp"`
	NewLevel        int      `json:"newLevel"`
	LevelUnlocked   bool     `json:"levelUnlocked"`
	NextLevelID     string   `json:"nextLevelId,omitempty"`
	WeakPoints      []string `json:"weakPoints"`
	StrongPoints    []string `json:"strongPoints"`
	ConfidenceScore int      `json:"confidenceScore"`
	AIFeedback      string   `json:"aiFeedback"`
}

// CompleteLessonHandler handles lesson completion, battle analysis, and XP updates
func CompleteLessonHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req LessonCompleteRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Invalid request"})
		return
	}

	ctx := r.Context()

	// 1. Fetch course and level
	courseDoc, err := db.FirestoreClient.Collection("courses").Doc(req.CourseID).Get(ctx)
	if err != nil {
		respondJSON(w, http.StatusNotFound, map[string]string{"error": "Course not found"})
		return
	}
	var course models.Course
	courseDoc.DataTo(&course)

	// Find level index
	var currentLevel *models.CourseLevel
	var levelIndex int = -1
	for i, l := range course.Levels {
		if l.ID == req.LevelID {
			currentLevel = &course.Levels[i]
			levelIndex = i
			break
		}
	}
	if currentLevel == nil {
		respondJSON(w, http.StatusNotFound, map[string]string{"error": "Level not found"})
		return
	}

	// 2. Fetch questions and grade answers
	correctCount := 0
	var questionsForAI []map[string]interface{}
	var answersForAI []map[string]interface{}

	for _, ans := range req.Answers {
		qDoc, err := db.FirestoreClient.Collection("questions").Doc(ans.QuestionID).Get(ctx)
		if err != nil {
			continue
		}
		var q models.Question
		qDoc.DataTo(&q)

		isCorrect := q.CorrectIndex == ans.SelectedIndex
		if isCorrect {
			correctCount++
		}

		questionsForAI = append(questionsForAI, map[string]interface{}{
			"id":      q.ID,
			"text":    q.Text,
			"topic":   q.Topic,
			"correct": q.CorrectIndex,
		})
		answersForAI = append(answersForAI, map[string]interface{}{
			"questionId": q.ID,
			"selected":   ans.SelectedIndex,
			"isCorrect":  isCorrect,
		})
	}

	totalQuestions := len(req.Answers)
	if totalQuestions == 0 {
		totalQuestions = 1
	}

	// 3. Calculate XP
	baseXP := 50
	bonusXP := correctCount * 10
	totalXPGained := baseXP + bonusXP

	// 4. AI Analysis (Confidence, Weak/Strong Points)
	weakPoints, strongPoints, confidenceScore, aiFeedback := analyzeWithAI(ctx, questionsForAI, answersForAI)

	// 5. Update UserStats
	statsRef := db.FirestoreClient.Collection("user_stats").Doc(req.UserID)
	statsDoc, err := statsRef.Get(ctx)

	var stats models.UserStats
	if err == nil {
		statsDoc.DataTo(&stats)
	} else {
		// Create new stats if doesn't exist
		stats = models.UserStats{
			UserID:  req.UserID,
			TotalXP: 0,
			Level:   1,
		}
	}

	stats.TotalXP += totalXPGained
	stats.Level = calculateLevel(stats.TotalXP)

	// Update confidence score (rolling average with new score)
	if stats.ConfidenceScore == 0 {
		stats.ConfidenceScore = confidenceScore
	} else {
		stats.ConfidenceScore = (stats.ConfidenceScore + confidenceScore) / 2
	}

	// Merge weak points (only store recent unique ones)
	stats.WeakPoints = mergeStringSlices(stats.WeakPoints, weakPoints, 5)
	stats.StrongPoints = mergeStringSlices(stats.StrongPoints, strongPoints, 5)

	// Update weekly XP - keys are YYYY-MM-DD
	if stats.WeeklyXP == nil {
		stats.WeeklyXP = make(map[string]int)
	}
	todayStr := time.Now().Format("2006-01-02")
	stats.WeeklyXP[todayStr] += totalXPGained

	// Save stats to user_stats collection
	_, err = statsRef.Set(ctx, stats)
	if err != nil {
		log.Printf("ERROR: Failed to save user_stats: %v", err)
	} else {
		log.Printf("SUCCESS: Updated user_stats for %s - TotalXP: %d, Level: %d, Confidence: %d", req.UserID, stats.TotalXP, stats.Level, stats.ConfidenceScore)
	}

	// Also update the users collection XP (for profile display)
	userRef := db.FirestoreClient.Collection("users").Doc(req.UserID)
	_, err = userRef.Update(ctx, []firestore.Update{
		{Path: "xp", Value: stats.TotalXP},
		{Path: "level", Value: stats.Level},
	})
	if err != nil {
		log.Printf("Warning: Could not update users XP: %v (user may not exist in users collection)", err)
	} else {
		log.Printf("SUCCESS: Updated users collection XP for %s", req.UserID)
	}

	// 6. Update Enrollment progress
	enrollmentID := fmt.Sprintf("%s_%s", req.UserID, req.CourseID)
	enrollRef := db.FirestoreClient.Collection("enrollments").Doc(enrollmentID)

	progress := float64(levelIndex+1) / float64(len(course.Levels))
	if progress > 1 {
		progress = 1
	}

	// Check if this specific completion event triggers course completion
	// We need to fetch previous enrollment status to avoid double counting if re-playing
	// But for simplicity/MVP, we just set it.
	// To strictly increment CoursesCompleted only once, we should check if it WAS NOT completed before.

	wasCompleted := false
	enrollSnap, err := enrollRef.Get(ctx)
	if err == nil {
		var prevEnroll models.Enrollment
		enrollSnap.DataTo(&prevEnroll)
		wasCompleted = prevEnroll.Completed
	}

	isNowCompleted := progress >= 1

	enrollRef.Set(ctx, map[string]interface{}{
		"userId":    req.UserID,
		"courseId":  req.CourseID,
		"progress":  progress,
		"completed": isNowCompleted,
		"updatedAt": time.Now(),
	}, firestore.MergeAll)

	// Update CoursesCompleted count if newly completed
	if isNowCompleted && !wasCompleted {
		_, err = statsRef.Update(ctx, []firestore.Update{
			{Path: "coursesCompleted", Value: firestore.Increment(1)},
		})
		if err == nil {
			// Update local stats struct to reflect change for achievement check
			stats.CoursesCompleted++
		}
	}

	// 7. Determine next level
	nextLevelID := ""
	levelUnlocked := false
	if levelIndex+1 < len(course.Levels) {
		nextLevelID = course.Levels[levelIndex+1].ID
		levelUnlocked = true
	}

	// 8. Recalculate Global Rank
	go updateGlobalRanks(context.Background())

	// 9. Check Achievements
	go CheckAndUnlockAchievements(context.Background(), req.UserID, stats)

	respondJSON(w, http.StatusOK, LessonCompleteResponse{
		Success:         true,
		Message:         "Lesson completed!",
		XPGained:        totalXPGained,
		CorrectCount:    correctCount,
		TotalQuestions:  totalQuestions,
		NewTotalXP:      stats.TotalXP,
		NewLevel:        stats.Level,
		LevelUnlocked:   levelUnlocked,
		NextLevelID:     nextLevelID,
		WeakPoints:      weakPoints,
		StrongPoints:    strongPoints,
		ConfidenceScore: confidenceScore,
		AIFeedback:      aiFeedback,
	})
}

// analyzeWithAI calls Gemini to analyze battle performance
func analyzeWithAI(ctx context.Context, questions, answers []map[string]interface{}) (weak, strong []string, confidence int, feedback string) {
	if services.GetGeminiModel() == nil {
		return []string{}, []string{}, 50, "AI analysis unavailable"
	}

	qJSON, _ := json.Marshal(questions)
	aJSON, _ := json.Marshal(answers)

	prompt := fmt.Sprintf(`Analyze this quiz performance.
Questions: %s
User Answers: %s

Respond in JSON ONLY:
{
  "weakPoints": ["topic1", "topic2"],
  "strongPoints": ["topic1"],
  "confidenceScore": 75,
  "feedback": "Brief encouraging feedback (max 30 words)"
}`, string(qJSON), string(aJSON))

	resp, err := services.GetGeminiModel().GenerateContent(ctx, genai.Text(prompt))
	if err != nil {
		log.Printf("AI analysis error: %v", err)
		return []string{}, []string{}, 50, "Keep practicing!"
	}

	var resultText string
	for _, cand := range resp.Candidates {
		if cand.Content != nil {
			for _, part := range cand.Content.Parts {
				resultText += fmt.Sprintf("%v", part)
			}
		}
	}

	// Strip markdown code blocks if present (Gemini sometimes wraps JSON)
	resultText = strings.TrimSpace(resultText)
	if strings.HasPrefix(resultText, "```json") {
		resultText = strings.TrimPrefix(resultText, "```json")
	}
	if strings.HasPrefix(resultText, "```") {
		resultText = strings.TrimPrefix(resultText, "```")
	}
	if strings.HasSuffix(resultText, "```") {
		resultText = strings.TrimSuffix(resultText, "```")
	}
	resultText = strings.TrimSpace(resultText)

	log.Printf("AI Response (cleaned): %s", resultText)

	// Parse JSON
	var result struct {
		WeakPoints      []string `json:"weakPoints"`
		StrongPoints    []string `json:"strongPoints"`
		ConfidenceScore int      `json:"confidenceScore"`
		Feedback        string   `json:"feedback"`
	}
	if err := json.Unmarshal([]byte(resultText), &result); err != nil {
		log.Printf("AI JSON parse error: %v, raw: %s", err, resultText)
		return []string{}, []string{}, 50, "Good effort! Keep learning."
	}

	return result.WeakPoints, result.StrongPoints, result.ConfidenceScore, result.Feedback
}

func calculateLevel(xp int) int {
	// Simple level formula: every 500 XP = 1 level
	return (xp / 500) + 1
}

func mergeStringSlices(existing, new []string, maxLen int) []string {
	combined := append(new, existing...)
	seen := make(map[string]bool)
	var result []string
	for _, s := range combined {
		if !seen[s] {
			seen[s] = true
			result = append(result, s)
		}
		if len(result) >= maxLen {
			break
		}
	}
	return result
}

// updateGlobalRanks recalculates ranks based on XP
func updateGlobalRanks(ctx context.Context) {
	if db.FirestoreClient == nil {
		return
	}

	// Fetch all user_stats ordered by XP
	iter := db.FirestoreClient.Collection("user_stats").OrderBy("totalXp", firestore.Desc).Documents(ctx)
	docs, err := iter.GetAll()
	if err != nil {
		log.Printf("Failed to fetch stats for ranking: %v", err)
		return
	}

	// Update ranks
	for i, doc := range docs {
		doc.Ref.Update(ctx, []firestore.Update{
			{Path: "globalRank", Value: i + 1},
		})
	}
	log.Printf("Updated global ranks for %d users", len(docs))
}

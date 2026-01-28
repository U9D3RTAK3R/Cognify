package api

import (
	"net/http"

	"cache-crew/cognify/internal/db"
	"cache-crew/cognify/internal/models"
	"cache-crew/cognify/internal/services" // Import services package

	"google.golang.org/api/iterator"
)

// GetRecommendationsHandler returns AI course recommendations
func GetRecommendationsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	userID := r.URL.Query().Get("userId")
	if userID == "" {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "userId required"})
		return
	}

	// Fetch user details to build profile (Mocking some parts for speed, ideally fetch from UserStats)
	// In a real app, query 'user_stats' or 'users' collection here.
	req := services.RecommendationRequest{
		UserID:        userID,
		UserLevel:     "Cyber Ninja", // TODO: Fetch from DB
		UserModifier:  "Normal",
		WeakPoints:    []string{"State Management", "Testing"}, // TODO: Compute from BattleHistory
		RecentScores:  []map[string]interface{}{{"topic": "Dart", "score": 85}, {"topic": "Provider", "score": 40}},
		LearningStyle: "Visual",
	}

	recs, err := services.GetCourseRecommendations(r.Context(), req)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{"success": true, "recommendations": recs})
}

// GetBattleQuestionsHandler returns questions for a battle
func GetBattleQuestionsHandler(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Optional filters
	// topic := r.URL.Query().Get("topic")
	// difficulty := r.URL.Query().Get("difficulty")

	var questions []models.Question

	if db.FirestoreClient != nil {
		iter := db.FirestoreClient.Collection("questions").Limit(5).Documents(ctx)
		for {
			doc, err := iter.Next()
			if err == iterator.Done {
				break
			}
			if err != nil {
				respondJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
				return
			}
			var q models.Question
			doc.DataTo(&q)
			questions = append(questions, q)
		}
	}

	// Fallback mock if empty
	if len(questions) == 0 {
		questions = []models.Question{
			{
				ID: "q1", Text: "What is a StatefulWidget in Flutter?",
				Options:      []string{"Immutable widget", "Mutable widget", "Database", "API"},
				CorrectIndex: 1, Difficulty: "Easy", Topic: "Flutter", Points: 10, TimeLimit: 30,
			},
			{
				ID: "q2", Text: "Which method is called only once in State lifecycle?",
				Options:      []string{"build", "setState", "initState", "dispose"},
				CorrectIndex: 2, Difficulty: "Medium", Topic: "Flutter", Points: 20, TimeLimit: 20,
			},
		}
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{"success": true, "questions": questions})
}

// SeedBattleDataHandler initializes questions and courses
func SeedBattleDataHandler(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	if db.FirestoreClient == nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "DB not valid"})
		return
	}

	// Pre-define questions for embedding
	q1 := models.Question{ID: "q1", Text: "What does 'setState' do?", Options: []string{"Rebuilds the widget", "Stops the app", "Nothing", "Deletes data"}, CorrectIndex: 0, Difficulty: "Easy", Topic: "Flutter", Points: 10, TimeLimit: 30}
	q2 := models.Question{ID: "q2", Text: "Which is NOT a state management solution?", Options: []string{"Provider", "Riverpod", "Bloc", "Container"}, CorrectIndex: 3, Difficulty: "Easy", Topic: "State Management", Points: 10, TimeLimit: 30}
	q3 := models.Question{ID: "q3", Text: "What is the purpose of 'key' in Flutter?", Options: []string{"Authentication", "Preserve state", "Styling", "Navigation"}, CorrectIndex: 1, Difficulty: "Medium", Topic: "Flutter", Points: 20, TimeLimit: 45}
	animQ1 := models.Question{ID: "anim_q1", Text: "What is the difference between implicit and explicit animations?", Options: []string{"Implicit is automatic, explicit uses controllers", "No difference", "Explicit is faster", "Implicit uses controllers"}, CorrectIndex: 0, Difficulty: "Medium", Topic: "Animation", Points: 20, TimeLimit: 30}
	animQ2 := models.Question{ID: "anim_q2", Text: "Which widget automatically animates property changes?", Options: []string{"Container", "AnimatedContainer", "StatefulWidget", "Scaffold"}, CorrectIndex: 1, Difficulty: "Easy", Topic: "Animation", Points: 10, TimeLimit: 20}
	animQ3 := models.Question{ID: "anim_q3", Text: "What does AnimatedOpacity animate?", Options: []string{"Position", "Size", "Transparency", "Color"}, CorrectIndex: 2, Difficulty: "Easy", Topic: "Animation", Points: 10, TimeLimit: 20}
	animQ4 := models.Question{ID: "anim_q4", Text: "What parameter controls animation speed in implicit widgets?", Options: []string{"speed", "duration", "velocity", "time"}, CorrectIndex: 1, Difficulty: "Easy", Topic: "Animation", Points: 10, TimeLimit: 20}
	animQ5 := models.Question{ID: "anim_q5", Text: "What does an AnimationController control?", Options: []string{"Widget tree", "Animation timing", "Database", "Routing"}, CorrectIndex: 1, Difficulty: "Medium", Topic: "Animation", Points: 20, TimeLimit: 30}
	animQ6 := models.Question{ID: "anim_q6", Text: "What is a Tween used for?", Options: []string{"Tweeting updates", "Defining animation value range", "Styling", "Navigation"}, CorrectIndex: 1, Difficulty: "Medium", Topic: "Animation", Points: 20, TimeLimit: 30}

	// Seed Courses with Levels
	advAnimationsLevels := []models.CourseLevel{
		{
			ID:        "anim_l1",
			Title:     "Introduction to Animations",
			Content:   "# Welcome to Advanced Animations\n\nAnimations bring your Flutter apps to life! In this module, you'll learn:\n\n- What makes a great animation\n- The Flutter animation framework\n- Implicit vs Explicit animations\n\n## Why Animations Matter\n\nSmooth animations improve user experience by providing visual feedback and making interactions feel natural.",
			VideoURL:  "https://www.youtube.com/watch?v=IVTjpW3W33s",
			Questions: []models.Question{animQ1, animQ2},
		},
		{
			ID:        "anim_l2",
			Title:     "Implicit Animations",
			Content:   "# Implicit Animations\n\nImplicit animations are the easiest way to add animations in Flutter.\n\n## Key Widgets\n- `AnimatedContainer`\n- `AnimatedOpacity`\n- `AnimatedPadding`\n- `AnimatedPositioned`\n\n## How They Work\nJust change a property value and Flutter automatically animates to the new value!",
			VideoURL:  "https://www.youtube.com/watch?v=IVTjpW3W33s",
			Questions: []models.Question{animQ3, animQ4},
		},
		{
			ID:        "anim_l3",
			Title:     "Explicit Animations & Controllers",
			Content:   "# Explicit Animations\n\nFor complete control, use `AnimationController` and `Tween`.\n\n## Core Concepts\n- AnimationController - controls timing\n- Tween - defines start/end values\n- AnimatedBuilder - rebuilds on each frame\n\n## Advanced Techniques\n- Curves for easing\n- Staggered animations\n- Hero animations",
			VideoURL:  "https://www.youtube.com/watch?v=txLvvlooT20",
			Questions: []models.Question{animQ5, animQ6},
		},
	}

	courses := []models.Course{
		{ID: "c_flutter_basics", Title: "Flutter Basics", Subtitle: "Build Your First App", Description: "Master the basics of Flutter UI.", DifficultyRating: 1, Tags: []string{"Flutter", "Basics"}, InstructorID: "inst1", Emoji: "🦋", ColorHex: "0xFF00BCD4"},
		{ID: "c_state_mgmt", Title: "State Management Mastery", Subtitle: "Provider & Riverpod", Description: "Deep dive into Provider and Riverpod.", DifficultyRating: 4, Tags: []string{"State Management", "Provider"}, InstructorID: "inst1", Emoji: "🧠", ColorHex: "0xFF9C27B0"},
		{ID: "c_dart_async", Title: "Asynchronous Dart", Subtitle: "Futures & Streams", Description: "Future, Streams, and Isolates.", DifficultyRating: 3, Tags: []string{"Dart", "Async"}, InstructorID: "inst1", Emoji: "⚡", ColorHex: "0xFFFFEB3B"},
		{ID: "c_animations", Title: "Advanced Animations", Subtitle: "Complex UI Magic", Description: "Create stunning animations.", DifficultyRating: 5, Tags: []string{"Animation", "UI"}, InstructorID: "inst1", Emoji: "✨", ColorHex: "0xFFFF5722", Levels: advAnimationsLevels},
		{ID: "c_dart_basics", Title: "Dart Fundamentals", Subtitle: "Core Language Skills", Description: "Learn Dart from scratch.", DifficultyRating: 1, Tags: []string{"Dart", "Basics"}, InstructorID: "inst1", Emoji: "🎯", ColorHex: "0xFF2196F3"},
	}

	for _, c := range courses {
		db.FirestoreClient.Collection("courses").Doc(c.ID).Set(ctx, c)
	}

	// Seed Questions (including animation questions) - for global pool
	questions := []models.Question{q1, q2, q3, animQ1, animQ2, animQ3, animQ4, animQ5, animQ6}
	for _, q := range questions {
		db.FirestoreClient.Collection("questions").Doc(q.ID).Set(ctx, q)
	}

	respondJSON(w, http.StatusOK, map[string]string{"message": "Seeded courses and questions with Advanced Animations levels"})
}

package api

import (
	"log"
	"net/http"
	"time"

	"cache-crew/cognify/internal/db"
	"cache-crew/cognify/internal/middleware"
	"cache-crew/cognify/internal/models"
	"cache-crew/cognify/internal/services"

	"cloud.google.com/go/firestore"
	"golang.org/x/crypto/bcrypt"
	"google.golang.org/api/iterator"
)

// dummy use of iterator to prevent compile errors
var _ = iterator.Done

// Predefined achievements
var achievements = []models.Achievement{
	{
		ID:          "first_win",
		Name:        "First Win",
		Description: "Win your first battle",
		Emoji:       "🏆",
		Requirement: "Win 1 battle",
		XPReward:    50,
		Category:    "battles",
	},
	{
		ID:          "streak_7",
		Name:        "7 Day Streak",
		Description: "Maintain a learning streak for 7 days",
		Emoji:       "🔥",
		Requirement: "7 day streak",
		XPReward:    100,
		Category:    "learning",
	},
	{
		ID:          "speed_demon",
		Name:        "Speed Demon",
		Description: "Complete a battle in under 60 seconds",
		Emoji:       "⚡",
		Requirement: "Complete battle < 60s",
		XPReward:    75,
		Category:    "battles",
	},
	{
		ID:          "perfect_score",
		Name:        "Perfect Score",
		Description: "Get 100% on any quiz",
		Emoji:       "🎯",
		Requirement: "100% quiz score",
		XPReward:    100,
		Category:    "learning",
	},
	{
		ID:          "course_complete",
		Name:        "Course Master",
		Description: "Complete your first course",
		Emoji:       "📚",
		Requirement: "Complete 1 course",
		XPReward:    200,
		Category:    "courses",
	},
	{
		ID:          "battle_veteran",
		Name:        "Battle Veteran",
		Description: "Win 10 battles",
		Emoji:       "⚔️",
		Requirement: "Win 10 battles",
		XPReward:    150,
		Category:    "battles",
	},
	{
		ID:          "social_butterfly",
		Name:        "Social Butterfly",
		Description: "Make 5 forum posts",
		Emoji:       "🦋",
		Requirement: "Create 5 posts",
		XPReward:    75,
		Category:    "social",
	},
	{
		ID:          "streak_30",
		Name:        "Month Warrior",
		Description: "Maintain a 30 day streak",
		Emoji:       "💪",
		Requirement: "30 day streak",
		XPReward:    300,
		Category:    "learning",
	},
}

// GetAchievementsHandler returns all available achievements
func GetAchievementsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success":      true,
		"achievements": achievements,
	})
}

// GetUserStatsHandler returns statistics for the authenticated user
func GetUserStatsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	userID := r.URL.Query().Get("userId")
	if userID == "" {
		if claims, ok := r.Context().Value(middleware.UserContextKey).(*services.JWTClaims); ok {
			userID = claims.UserID
		}
	}
	if userID == "" {
		userID = "default"
	}

	// Try to get from Firestore
	if db.FirestoreClient != nil {
		doc, err := db.FirestoreClient.Collection("user_stats").Doc(userID).Get(r.Context())
		if err == nil {
			var stats models.UserStats
			if err := doc.DataTo(&stats); err == nil {
				respondJSON(w, http.StatusOK, map[string]interface{}{
					"success": true,
					"stats":   stats,
				})
				return
			}
		}
	}

	// Return mock stats if not found
	stats := models.UserStats{
		UserID:           userID,
		TotalXP:          0,
		Level:            1,
		BattlesWon:       0,
		BattlesPlayed:    0,
		CoursesCompleted: 0,
		CoursesEnrolled:  0,
		CurrentStreak:    0,
		LongestStreak:    0,
		GlobalRank:       42,
		ForumPosts:       0,
		ForumComments:    0,
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"stats":   stats,
	})
}

// GetUserAchievementsHandler returns achievements unlocked by the user
func GetUserAchievementsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	userID := r.URL.Query().Get("userId")
	if userID == "" {
		if ctxUserID := r.Context().Value("userID"); ctxUserID != nil {
			userID = ctxUserID.(string)
		}
	}
	if userID == "" {
		userID = "default"
	}

	var userAchievements []models.UserAchievement

	if db.FirestoreClient != nil {
		iter := db.FirestoreClient.Collection("user_achievements").Where("userId", "==", userID).Documents(r.Context())
		for {
			doc, err := iter.Next()
			if err == iterator.Done {
				break
			}
			if err != nil {
				break
			}
			var ua models.UserAchievement
			if err := doc.DataTo(&ua); err == nil {
				userAchievements = append(userAchievements, ua)
			}
		}
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success":      true,
		"achievements": userAchievements,
	})
}

// GetLeaderboardHandler returns the top 10 users by XP
func GetLeaderboardHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Always return mock leaderboard for demo purposes
	// Real implementation would fetch from Firestore
	leaderboard := []models.LeaderboardEntry{
		{Rank: 1, UserID: "1", Name: "Alex Chen", AvatarEmoji: "🦊", TotalXP: 12500, Level: 15, BattlesWon: 45},
		{Rank: 2, UserID: "2", Name: "Sarah Kim", AvatarEmoji: "🐼", TotalXP: 11200, Level: 14, BattlesWon: 38},
		{Rank: 3, UserID: "3", Name: "Mike Johnson", AvatarEmoji: "🦁", TotalXP: 10800, Level: 13, BattlesWon: 35},
		{Rank: 4, UserID: "4", Name: "Emma Wilson", AvatarEmoji: "🐯", TotalXP: 9500, Level: 12, BattlesWon: 30},
		{Rank: 5, UserID: "5", Name: "David Lee", AvatarEmoji: "🐸", TotalXP: 8900, Level: 11, BattlesWon: 28},
		{Rank: 6, UserID: "6", Name: "Lisa Park", AvatarEmoji: "🦋", TotalXP: 8200, Level: 10, BattlesWon: 25},
		{Rank: 7, UserID: "7", Name: "James Brown", AvatarEmoji: "🦉", TotalXP: 7500, Level: 9, BattlesWon: 22},
		{Rank: 8, UserID: "8", Name: "Amy Zhang", AvatarEmoji: "🐢", TotalXP: 6800, Level: 8, BattlesWon: 20},
		{Rank: 9, UserID: "9", Name: "Tom Miller", AvatarEmoji: "🐙", TotalXP: 6200, Level: 7, BattlesWon: 18},
		{Rank: 10, UserID: "10", Name: "Sophie Davis", AvatarEmoji: "🦄", TotalXP: 5500, Level: 6, BattlesWon: 15},
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success":     true,
		"leaderboard": leaderboard,
	})
}

// SeedDataHandler seeds test data for development
func SeedDataHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	if db.FirestoreClient == nil {
		respondJSON(w, http.StatusInternalServerError, map[string]interface{}{
			"success": false,
			"error":   "Firestore not initialized",
		})
		return
	}

	ctx := r.Context()
	userID := r.URL.Query().Get("userId")
	if userID == "" {
		userID = "narutouzumaki05805@gmail.com"
	}

	// Seed user_achievements - unlock "streak_7" achievement
	_, err := db.FirestoreClient.Collection("user_achievements").Doc("streak7_"+userID).Set(ctx, map[string]interface{}{
		"id":            "streak7_" + userID,
		"userId":        userID,
		"achievementId": "streak_7",
		"unlockedAt":    time.Now(),
	})
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]interface{}{
			"success": false,
			"error":   "Failed to seed achievement: " + err.Error(),
		})
		return
	}

	// Hash default password
	hashedPwd, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)

	// Update User in Firestore
	_, err = db.FirestoreClient.Collection("users").Doc(userID).Set(ctx, map[string]interface{}{
		"xp":        2450,
		"level":     5,
		"password":  string(hashedPwd), // Set default password
		"updatedAt": time.Now(),
	}, firestore.MergeAll)
	if err != nil {
		// Log error but don't return, as user might not exist yet, and stats seeding is more critical.
		// In a real app, you might handle this more robustly.
		log.Printf("Warning: Failed to update user document for %s: %v", userID, err)
	}

	// Seed user_stats
	_, err = db.FirestoreClient.Collection("user_stats").Doc(userID).Set(ctx, map[string]interface{}{
		"userId":           userID,
		"totalXp":          2450,
		"level":            5,
		"battlesWon":       12,
		"battlesPlayed":    18,
		"coursesCompleted": 2,
		"coursesEnrolled":  4,
		"currentStreak":    7,
		"longestStreak":    14,
		"globalRank":       42,
		"forumPosts":       5,
		"forumComments":    12,
	})
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]interface{}{
			"success": false,
			"error":   "Failed to seed stats: " + err.Error(),
		})
		return
	}

	// Update user's XP in users collection
	_, err = db.FirestoreClient.Collection("users").Doc(userID).Update(ctx, []firestore.Update{
		{Path: "xp", Value: 2450},
		{Path: "level", Value: 5},
	})
	if err != nil {
		// User might not exist, try Set instead
		// Just log and continue
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"message": "Test data seeded successfully for user: " + userID,
	})
}

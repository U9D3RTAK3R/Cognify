package api

import (
	"context" // Added
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
	{
		ID:          "comment_critic",
		Name:        "Comment Critic",
		Description: "Post 3 comments on the forum",
		Emoji:       "💬",
		Requirement: "Post 3 comments",
		XPReward:    50,
		Category:    "social",
	},
}

// CheckAndUnlockAchievements checks if the user has unlocked any new achievements
func CheckAndUnlockAchievements(ctx context.Context, userID string, stats models.UserStats) {
	if db.FirestoreClient == nil {
		return
	}

	// 1. Get already unlocked achievements
	iter := db.FirestoreClient.Collection("user_achievements").Where("userId", "==", userID).Documents(ctx)
	unlockedIDs := make(map[string]bool)
	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			log.Printf("Error unlocking achievements: %v", err)
			return
		}
		var ua models.UserAchievement
		if err := doc.DataTo(&ua); err == nil {
			unlockedIDs[ua.AchievementID] = true
		}
	}

	// 2. Check requirements
	for _, ach := range achievements {
		if unlockedIDs[ach.ID] {
			continue // Already unlocked
		}

		unlocked := false
		switch ach.ID {
		case "first_win":
			if stats.BattlesWon >= 1 {
				unlocked = true
			}
		case "battle_veteran":
			if stats.BattlesWon >= 10 {
				unlocked = true
			}
		case "streak_7":
			if stats.CurrentStreak >= 7 {
				unlocked = true
			}
		case "streak_30":
			if stats.CurrentStreak >= 30 {
				unlocked = true
			}
		case "social_butterfly":
			if stats.ForumPosts >= 5 {
				unlocked = true
			}
		case "comment_critic":
			if stats.ForumComments >= 3 {
				unlocked = true
			}
		case "course_complete":
			if stats.CoursesCompleted >= 1 {
				unlocked = true
			}
		}

		if unlocked {
			// Grant Achievement
			log.Printf("Unlocking achievement %s for user %s", ach.ID, userID)

			// 1. Create UserAchievement logic
			ua := models.UserAchievement{
				ID:            ach.ID + "_" + userID,
				UserID:        userID,
				AchievementID: ach.ID,
				UnlockedAt:    time.Now(),
			}
			_, err := db.FirestoreClient.Collection("user_achievements").Doc(ua.ID).Set(ctx, ua)
			if err != nil {
				log.Printf("Failed to save achievement %s: %v", ach.ID, err)
				continue
			}

			// 2. Grant XP
			stats.TotalXP += ach.XPReward

			// Update stats with new XP (careful not to subscribe to race conditions if caller saves too, but caller usually saves stats BEFORE calling this.
			// Actually, we should update the stats object and let caller save? Or save here?
			// The caller typically passes a COPY or a pointer.
			// Better: Update stats completely here and save it? Or just increment XP in DB?
			// To be safe and avoid overwriting caller's specific updates, we should use atomic increment for XP or just re-save.
			// Re-saving might overwrite caller's changes if not careful.
			// Let's assume this function is called AFTER caller saves their specific updates,
			// AND we only update XP here.

			_, err = db.FirestoreClient.Collection("user_stats").Doc(userID).Update(ctx, []firestore.Update{
				{Path: "totalXp", Value: firestore.Increment(ach.XPReward)},
			})
			if err != nil {
				log.Printf("Failed to award XP for achievement %s: %v", ach.ID, err)
			}

			// Also notify user? (For now just log)
		}
	}
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
				log.Printf("Found achievement for user %s: %s", userID, ua.AchievementID)
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

	var leaderboard []models.LeaderboardEntry

	if db.FirestoreClient != nil {
		iter := db.FirestoreClient.Collection("user_stats").
			OrderBy("totalXp", firestore.Desc).
			Limit(10).
			Documents(r.Context())

		rank := 1
		for {
			doc, err := iter.Next()
			if err == iterator.Done {
				break
			}
			if err != nil {
				log.Printf("Error fetching leaderboard: %v", err)
				break
			}
			var stats models.UserStats
			if err := doc.DataTo(&stats); err == nil {
				// Use default name if missing (e.g. legacy data)
				name := stats.Name
				if name == "" {
					name = "User"
				}
				avatar := stats.AvatarEmoji
				if avatar == "" {
					avatar = "👤"
				}

				leaderboard = append(leaderboard, models.LeaderboardEntry{
					Rank:        rank,
					UserID:      stats.UserID,
					Name:        name,
					AvatarEmoji: avatar,
					TotalXP:     stats.TotalXP,
					Level:       stats.Level,
					BattlesWon:  stats.BattlesWon,
				})
				rank++
			}
		}
	} else {
		// Fallback to mock if DB not ready (or keep existing mock)
		// But better to return empty than confusing mock?
		// User asked to "propagate ... in backend".
		// Use empty list if DB up but empty.
	}

	// Just in case no DB or empty, provide empty list or handle gracefully
	if leaderboard == nil {
		leaderboard = []models.LeaderboardEntry{}
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

	// Generate past 7 days XP map
	weeklyXP := make(map[string]int)
	now := time.Now()
	testXP := []int{120, 150, 180, 90, 200, 160, 220} // Just some values

	// Fill map backwards (today, yesterday, etc.)
	for i := 0; i < 7; i++ {
		dateStr := now.AddDate(0, 0, -i).Format("2006-01-02")
		weeklyXP[dateStr] = testXP[i%len(testXP)]
	}

	// Seed user_stats for the requested user
	_, err = db.FirestoreClient.Collection("user_stats").Doc(userID).Set(ctx, map[string]interface{}{
		"userId":           userID,
		"name":             "Naruto Uzumaki", // Default name for seeded user
		"avatarEmoji":      "🦊",              // Default avatar
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
		"weeklyXp":         weeklyXP,
		"categoryStats": map[string]int{
			"Flutter":  40,
			"Python":   25,
			"Data Sci": 20,
			"Web Dev":  15,
		},
	})
	if err != nil {
		log.Printf("Error seeding stats for %s: %v", userID, err)
	}

	// NOTE: Bulk seeding removed as mock data is already propagated.

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

package models

import "time"

// Achievement represents a game achievement that users can unlock
type Achievement struct {
	ID          string `json:"id" firestore:"id"`
	Name        string `json:"name" firestore:"name"`
	Description string `json:"description" firestore:"description"`
	Emoji       string `json:"emoji" firestore:"emoji"`
	Requirement string `json:"requirement" firestore:"requirement"` // e.g., "Win 1 battle"
	XPReward    int    `json:"xpReward" firestore:"xpReward"`
	Category    string `json:"category" firestore:"category"` // "battles", "courses", "social", "learning"
}

// UserAchievement tracks which achievements a user has unlocked
type UserAchievement struct {
	ID            string    `json:"id" firestore:"id"`
	UserID        string    `json:"userId" firestore:"userId"`
	AchievementID string    `json:"achievementId" firestore:"achievementId"`
	UnlockedAt    time.Time `json:"unlockedAt" firestore:"unlockedAt"`
}

// UserStats contains detailed user statistics
type UserStats struct {
	UserID           string `json:"userId" firestore:"userId"`
	TotalXP          int    `json:"totalXp" firestore:"totalXp"`
	Level            int    `json:"level" firestore:"level"`
	BattlesWon       int    `json:"battlesWon" firestore:"battlesWon"`
	BattlesPlayed    int    `json:"battlesPlayed" firestore:"battlesPlayed"`
	CoursesCompleted int    `json:"coursesCompleted" firestore:"coursesCompleted"`
	CoursesEnrolled  int    `json:"coursesEnrolled" firestore:"coursesEnrolled"`
	CurrentStreak    int    `json:"currentStreak" firestore:"currentStreak"`
	LongestStreak    int    `json:"longestStreak" firestore:"longestStreak"`
	GlobalRank       int    `json:"globalRank" firestore:"globalRank"`
	ForumPosts       int    `json:"forumPosts" firestore:"forumPosts"`
	ForumComments    int    `json:"forumComments" firestore:"forumComments"`
}

// LeaderboardEntry represents a user's position on the leaderboard
type LeaderboardEntry struct {
	Rank        int    `json:"rank"`
	UserID      string `json:"userId"`
	Name        string `json:"name"`
	AvatarEmoji string `json:"avatarEmoji"`
	TotalXP     int    `json:"totalXp"`
	Level       int    `json:"level"`
	BattlesWon  int    `json:"battlesWon"`
}

package api

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"cache-crew/cognify/internal/db"
	"cache-crew/cognify/internal/models"

	"cloud.google.com/go/firestore"
	"google.golang.org/api/iterator"
)

// Mock posts for when Firestore is not available
var mockPosts = []models.Post{
	{
		ID:           "1",
		AuthorID:     "user1",
		AuthorName:   "Alex Chen",
		CourseID:     "1",
		Title:        "How to structure a Flutter project?",
		Content:      "I'm new to Flutter and wondering what's the best way to organize files and folders in a large app.",
		Tags:         []string{"flutter", "architecture"},
		Upvotes:      15,
		Downvotes:    2,
		CommentCount: 5,
		CreatedAt:    time.Now().Add(-24 * time.Hour),
	},
	{
		ID:           "2",
		AuthorID:     "user2",
		AuthorName:   "Sarah Kim",
		CourseID:     "2",
		Title:        "Best resources for learning AI?",
		Content:      "Looking for beginner-friendly resources to understand machine learning concepts.",
		Tags:         []string{"ai", "resources", "beginner"},
		Upvotes:      25,
		Downvotes:    1,
		CommentCount: 12,
		CreatedAt:    time.Now().Add(-48 * time.Hour),
	},
}

// GetPostsHandler returns forum posts
func GetPostsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	courseID := r.URL.Query().Get("courseId")
	posts, err := getPosts(r.Context(), courseID)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{
			"error": "Failed to fetch posts",
		})
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"posts":   posts,
	})
}

// GetCommentsHandler returns comments for a specific post
func GetCommentsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	postID := r.URL.Query().Get("postId")
	if postID == "" {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"error": "postId is required",
		})
		return
	}

	comments, err := getCommentsForPost(r.Context(), postID)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{
			"error": "Failed to fetch comments",
		})
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success":  true,
		"comments": comments,
	})
}

func getCommentsForPost(ctx context.Context, postID string) ([]models.Comment, error) {
	if db.FirestoreClient == nil {
		// Return empty in mock mode
		return []models.Comment{}, nil
	}

	// Query without OrderBy to avoid requiring a composite index
	query := db.FirestoreClient.Collection("comments").Where("postId", "==", postID)
	iter := query.Documents(ctx)
	var comments []models.Comment

	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			// Log error and return empty
			return []models.Comment{}, nil
		}

		var comment models.Comment
		if err := doc.DataTo(&comment); err != nil {
			continue
		}
		comments = append(comments, comment)
	}

	// Sort by createdAt in memory
	for i := 0; i < len(comments)-1; i++ {
		for j := i + 1; j < len(comments); j++ {
			if comments[j].CreatedAt.Before(comments[i].CreatedAt) {
				comments[i], comments[j] = comments[j], comments[i]
			}
		}
	}

	return comments, nil
}

// CreatePostHandler creates a new forum post
func CreatePostHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		AuthorID    string   `json:"authorId"`
		AuthorName  string   `json:"authorName"`
		AvatarEmoji string   `json:"avatarEmoji"`
		CourseID    string   `json:"courseId"`
		Title       string   `json:"title"`
		Content     string   `json:"content"`
		Tags        []string `json:"tags"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"error": "Invalid request body",
		})
		return
	}

	post := &models.Post{
		ID:           generateID(),
		AuthorID:     req.AuthorID,
		AuthorName:   req.AuthorName,
		AvatarEmoji:  req.AvatarEmoji,
		CourseID:     req.CourseID,
		Title:        req.Title,
		Content:      req.Content,
		Tags:         req.Tags,
		Upvotes:      0,
		Downvotes:    0,
		UpvotedBy:    []string{},
		DownvotedBy:  []string{},
		CommentCount: 0,
		ViewCount:    0,
		CreatedAt:    time.Now(),
	}

	if db.FirestoreClient != nil {
		_, err := db.FirestoreClient.Collection("posts").Doc(post.ID).Set(r.Context(), post)
		if err != nil {
			respondJSON(w, http.StatusInternalServerError, map[string]string{
				"error": "Failed to create post",
			})
			return
		}
	}

	// ---------------------------------------------------------
	// UPDATE USER STATS (ForumPosts)
	// ---------------------------------------------------------
	if db.FirestoreClient != nil {
		statsRef := db.FirestoreClient.Collection("user_stats").Doc(req.AuthorID)

		// 1. Increment ForumPosts
		_, err := statsRef.Update(r.Context(), []firestore.Update{
			{Path: "forumPosts", Value: firestore.Increment(1)},
		})

		// 2. Check Achievements (async)
		if err == nil {
			go func() {
				// We need to fetch fresh stats to check achievements
				doc, err := statsRef.Get(context.Background())
				if err == nil {
					var stats models.UserStats
					doc.DataTo(&stats)
					CheckAndUnlockAchievements(context.Background(), req.AuthorID, stats)
				}
			}()
		}
	}

	respondJSON(w, http.StatusCreated, map[string]interface{}{
		"success": true,
		"post":    post,
	})
}

// VotePostHandler handles upvoting/downvoting posts
func VotePostHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		PostID   string `json:"postId"`
		UserID   string `json:"userId"`
		VoteType string `json:"voteType"` // "up" or "down"
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"error": "Invalid request body",
		})
		return
	}

	// For mock mode
	if db.FirestoreClient == nil {
		respondJSON(w, http.StatusOK, map[string]interface{}{
			"success": true,
			"message": "Vote recorded (mock mode)",
		})
		return
	}

	// Get post
	doc, err := db.FirestoreClient.Collection("posts").Doc(req.PostID).Get(r.Context())
	if err != nil {
		respondJSON(w, http.StatusNotFound, map[string]string{
			"error": "Post not found",
		})
		return
	}

	var post models.Post
	if err := doc.DataTo(&post); err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{
			"error": "Failed to parse post",
		})
		return
	}

	// Update vote
	if req.VoteType == "up" {
		// Remove from downvoted if present
		post.DownvotedBy = removeFromSlice(post.DownvotedBy, req.UserID)
		if !contains(post.UpvotedBy, req.UserID) {
			post.UpvotedBy = append(post.UpvotedBy, req.UserID)
		}
	} else {
		// Remove from upvoted if present
		post.UpvotedBy = removeFromSlice(post.UpvotedBy, req.UserID)
		if !contains(post.DownvotedBy, req.UserID) {
			post.DownvotedBy = append(post.DownvotedBy, req.UserID)
		}
	}

	post.Upvotes = len(post.UpvotedBy)
	post.Downvotes = len(post.DownvotedBy)

	// Save
	_, err = db.FirestoreClient.Collection("posts").Doc(req.PostID).Set(r.Context(), post)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{
			"error": "Failed to update vote",
		})
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success":   true,
		"upvotes":   post.Upvotes,
		"downvotes": post.Downvotes,
	})
}

// AddCommentHandler adds a comment to a post
func AddCommentHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		PostID      string `json:"postId"`
		AuthorID    string `json:"authorId"`
		AuthorName  string `json:"authorName"`
		AvatarEmoji string `json:"avatarEmoji"`
		Content     string `json:"content"`
		ParentID    string `json:"parentId"` // Added
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"error": "Invalid request body",
		})
		return
	}

	comment := &models.Comment{
		ID:          generateID(),
		PostID:      req.PostID,
		AuthorID:    req.AuthorID,
		AuthorName:  req.AuthorName,
		AvatarEmoji: req.AvatarEmoji,
		Content:     req.Content,
		ParentID:    req.ParentID, // Populate
		CreatedAt:   time.Now(),
	}

	if db.FirestoreClient != nil {
		_, err := db.FirestoreClient.Collection("comments").Doc(comment.ID).Set(r.Context(), comment)
		if err != nil {
			respondJSON(w, http.StatusInternalServerError, map[string]string{
				"error": "Failed to add comment",
			})
			return
		}

		// Increment the post's commentCount
		postRef := db.FirestoreClient.Collection("posts").Doc(req.PostID)
		_, err = postRef.Update(r.Context(), []firestore.Update{
			{Path: "commentCount", Value: firestore.Increment(1)},
		})
		if err != nil {
			// Log but don't fail - comment was saved
		}

		// ---------------------------------------------------------
		// UPDATE USER STATS (ForumComments) & CHECK ACHIEVEMENTS
		// ---------------------------------------------------------
		statsRef := db.FirestoreClient.Collection("user_stats").Doc(req.AuthorID)
		_, err = statsRef.Update(r.Context(), []firestore.Update{
			{Path: "forumComments", Value: firestore.Increment(1)},
		})

		// Check Achievements Async
		if err == nil {
			go func() {
				// We need to fetch fresh stats to check achievements
				doc, err := statsRef.Get(context.Background())
				if err == nil {
					var stats models.UserStats
					doc.DataTo(&stats)
					CheckAndUnlockAchievements(context.Background(), req.AuthorID, stats)
				}
			}()
		}
	}

	respondJSON(w, http.StatusCreated, map[string]interface{}{
		"success": true,
		"comment": comment,
	})
}

// IncrementViewHandler increments the view count for a post
func IncrementViewHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		PostID string `json:"postId"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"error": "Invalid request body",
		})
		return
	}

	if db.FirestoreClient != nil {
		postRef := db.FirestoreClient.Collection("posts").Doc(req.PostID)
		_, err := postRef.Update(r.Context(), []firestore.Update{
			{Path: "viewCount", Value: firestore.Increment(1)},
		})
		if err != nil {
			respondJSON(w, http.StatusInternalServerError, map[string]string{
				"error": "Failed to increment view count",
			})
			return
		}
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
	})
}

// VoteCommentHandler handles upvoting/downvoting comments
func VoteCommentHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		CommentID string `json:"commentId"`
		UserID    string `json:"userId"`
		VoteType  string `json:"voteType"` // "up" or "down"
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"error": "Invalid request body",
		})
		return
	}

	// For mock mode
	if db.FirestoreClient == nil {
		respondJSON(w, http.StatusOK, map[string]interface{}{
			"success": true,
			"message": "Vote recorded (mock mode)",
		})
		return
	}

	// Get comment
	doc, err := db.FirestoreClient.Collection("comments").Doc(req.CommentID).Get(r.Context())
	if err != nil {
		respondJSON(w, http.StatusNotFound, map[string]string{
			"error": "Comment not found",
		})
		return
	}

	var comment models.Comment
	if err := doc.DataTo(&comment); err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{
			"error": "Failed to parse comment",
		})
		return
	}

	// Update vote
	if req.VoteType == "up" {
		// Remove from downvoted if present
		comment.DownvotedBy = removeFromSlice(comment.DownvotedBy, req.UserID)
		if !contains(comment.UpvotedBy, req.UserID) {
			comment.UpvotedBy = append(comment.UpvotedBy, req.UserID)
		}
	} else {
		// Remove from upvoted if present
		comment.UpvotedBy = removeFromSlice(comment.UpvotedBy, req.UserID)
		if !contains(comment.DownvotedBy, req.UserID) {
			comment.DownvotedBy = append(comment.DownvotedBy, req.UserID)
		}
	}

	comment.Upvotes = len(comment.UpvotedBy)
	comment.Downvotes = len(comment.DownvotedBy)

	// Save
	_, err = db.FirestoreClient.Collection("comments").Doc(req.CommentID).Set(r.Context(), comment)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{
			"error": "Failed to update vote",
		})
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success":   true,
		"upvotes":   comment.Upvotes,
		"downvotes": comment.Downvotes,
	})
}

func getPosts(ctx context.Context, courseID string) ([]models.Post, error) {
	if db.FirestoreClient == nil {
		if courseID != "" {
			var filtered []models.Post
			for _, p := range mockPosts {
				if p.CourseID == courseID {
					filtered = append(filtered, p)
				}
			}
			return filtered, nil
		}
		return mockPosts, nil
	}

	query := db.FirestoreClient.Collection("posts").OrderBy("createdAt", 1)
	if courseID != "" {
		query = db.FirestoreClient.Collection("posts").Where("courseId", "==", courseID).OrderBy("createdAt", 1)
	}

	iter := query.Documents(ctx)
	var posts []models.Post

	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return mockPosts, nil
		}

		var post models.Post
		if err := doc.DataTo(&post); err != nil {
			continue
		}
		posts = append(posts, post)
	}

	if len(posts) == 0 {
		return mockPosts, nil
	}

	return posts, nil
}

func generateID() string {
	return time.Now().Format("20060102150405") + "-" + randomString(6)
}

func randomString(n int) string {
	const letters = "abcdefghijklmnopqrstuvwxyz0123456789"
	b := make([]byte, n)
	for i := range b {
		b[i] = letters[time.Now().UnixNano()%int64(len(letters))]
		time.Sleep(time.Nanosecond)
	}
	return string(b)
}

func contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}

func removeFromSlice(slice []string, item string) []string {
	var result []string
	for _, s := range slice {
		if s != item {
			result = append(result, s)
		}
	}
	return result
}

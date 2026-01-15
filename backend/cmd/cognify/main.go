package main

import (
	"context"
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"

	"cache-crew/cognify/internal/api"
	"cache-crew/cognify/internal/config"
	"cache-crew/cognify/internal/db"
	"cache-crew/cognify/internal/middleware"
	"cache-crew/cognify/internal/services"
)

func main() {
	// Load configuration
	if err := config.Load(); err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	ctx := context.Background()

	// Initialize services
	if err := db.InitFirestore(ctx); err != nil {
		log.Printf("Firestore initialization warning: %v", err)
	}
	defer db.CloseFirestore()

	if err := db.InitBigQuery(ctx); err != nil {
		log.Printf("BigQuery initialization warning: %v", err)
	}
	defer db.CloseBigQuery()

	if err := services.InitGemini(ctx); err != nil {
		log.Printf("Gemini initialization warning: %v", err)
	}
	defer services.CloseGemini()

	// Start OTP cleanup goroutine
	services.StartOTPCleanup()

	// Create router
	r := chi.NewRouter()

	// Middleware
	r.Use(chimiddleware.Logger)
	r.Use(chimiddleware.Recoverer)
	r.Use(chimiddleware.RequestID)
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "X-CSRF-Token"},
		ExposedHeaders:   []string{"Link"},
		AllowCredentials: true,
		MaxAge:           300,
	}))

	// Health check
	r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte(`{"status":"ok","service":"cognify-backend"}`))
	})

	// Public routes
	r.Route("/api", func(r chi.Router) {
		// Auth routes (public)
		r.Post("/login", api.LoginHandler)
		r.Post("/signup", api.SignupHandler)
		r.Post("/verify", api.VerifyOTPHandler)
		r.Get("/debug/otp", api.DebugOTPHandler) // Remove in production

		// Course routes (public)
		r.Get("/courses", api.GetCoursesHandler)
		r.Get("/course", api.GetCourseHandler)

		// Forum routes (public read)
		r.Get("/posts", api.GetPostsHandler)
		r.Get("/posts/comments", api.GetCommentsHandler)

		// Gamification routes (public read)
		r.Get("/achievements", api.GetAchievementsHandler)
		r.Get("/leaderboard", api.GetLeaderboardHandler)
		r.Post("/seed-data", api.SeedDataHandler) // Dev only - seeds test data

		// Protected routes
		r.Group(func(r chi.Router) {
			r.Use(middleware.AuthMiddleware)

			// Course enrollment
			r.Post("/courses/enroll", api.EnrollCourseHandler)

			// Forum write operations
			r.Post("/posts", api.CreatePostHandler)
			r.Post("/posts/vote", api.VotePostHandler)
			r.Post("/posts/comment", api.AddCommentHandler)
			r.Post("/posts/comment/vote", api.VoteCommentHandler)
			r.Post("/posts/view", api.IncrementViewHandler)

			// AI routes (protected - login required)
			r.Post("/ai/chat", api.ChatHandler)
			r.Post("/ai/summarize", api.SummarizeHandler)
			r.Post("/ai/image-chat", api.ImageChatHandler)
			r.Post("/support/chat", api.SupportChatHandler)

			// User routes
			r.Post("/update-profile", api.UpdateProfileHandler)
			r.Get("/user/stats", api.GetUserStatsHandler)
			r.Get("/user/achievements", api.GetUserAchievementsHandler)
		})

		// Instructor routes
		r.Route("/instructor", func(r chi.Router) {
			// Some instructor routes may be public for demo
			r.Get("/dashboard", api.InstructorDashboardHandler)
			r.Post("/certificate/generate", api.GenerateCertificateHandler)
			r.Post("/certificate/data", api.GetCertificateDataHandler)
		})
	})

	// Start server
	port := config.AppConfig.Port
	log.Printf("🚀 Cognify Backend starting on port %s", port)
	log.Printf("📝 API Documentation:")
	log.Printf("   POST /api/login           - Request OTP")
	log.Printf("   POST /api/verify          - Verify OTP and get token")
	log.Printf("   GET  /api/courses         - Get all courses")
	log.Printf("   GET  /api/posts           - Get forum posts")
	log.Printf("   POST /api/ai/chat         - Chat with AI")
	log.Printf("   POST /api/ai/summarize    - Summarize data")
	log.Printf("   POST /api/instructor/certificate/generate - Generate certificate PDF")

	if err := http.ListenAndServe(":"+port, r); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}

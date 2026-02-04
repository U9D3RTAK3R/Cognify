package main

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
	"github.com/joho/godotenv"

	"cache-crew/cognify/internal/api"
	"cache-crew/cognify/internal/blockchain"
	"cache-crew/cognify/internal/config"
	"cache-crew/cognify/internal/db"
	"cache-crew/cognify/internal/middleware"
	"cache-crew/cognify/internal/services"
	"cache-crew/cognify/internal/utils"
)

func main() {
	// Load environment variables from .env file
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Load configuration
	config.Load()

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

	// Initialize blockchain client based on mode
	if config.AppConfig.BlockchainMode == "real" {
		log.Println("🔗 Initializing REAL blockchain client...")

		// Decrypt private key
		privateKey, err := utils.DecryptPrivateKey(
			config.AppConfig.PrivateKeyEncrypted,
			config.AppConfig.EncryptionPass,
		)
		if err != nil {
			log.Printf("⚠️  Failed to decrypt private key: %v", err)
			log.Println("   Falling back to mock blockchain")
			blockchain.InitMockBlockchain()
		} else {
			err = blockchain.InitRealBlockchain(
				config.AppConfig.BlockchainRPC,
				config.AppConfig.ContractAddress,
				privateKey,
			)
			if err != nil {
				log.Printf("⚠️  Failed to initialize real blockchain: %v", err)
				log.Println("   Falling back to mock blockchain")
				blockchain.InitMockBlockchain()
			} else {
				log.Println("✅ Real blockchain client initialized")
			}
		}
	} else {
		log.Println("🔧 Using MOCK blockchain (development mode)")
		blockchain.InitMockBlockchain()
		log.Println("✅ Mock blockchain client initialized")
	}

	// Create router
	r := chi.NewRouter()

	// Middleware
	// CORS must be first to handle OPTIONS requests correctly
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"http://localhost:5000", "http://localhost:3000", "*"}, // Explicit origins + wildcard
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "X-CSRF-Token", "Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers", "X-Wallet-Address", "X-Wallet-Signature", "X-Signed-Message"},
		ExposedHeaders:   []string{"Link"},
		AllowCredentials: true,
		MaxAge:           300,
	}))
	r.Use(chimiddleware.Logger)
	r.Use(chimiddleware.Recoverer)
	r.Use(chimiddleware.RequestID)

	// Force handle OPTIONS for all routes as a fallback
	r.Options("/*", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	// Health check
	r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte(`{"status":"ok","service":"cognify-backend"}`))
	})

	// Public routes
	// --- WALLET AUTH ROUTES (NEW) ---
	r.Post("/api/auth/nonce", api.GenerateNonceHandler)
	r.Post("/api/auth/login/wallet", api.WalletLoginHandler)

	// Auth routes (public)
	r.Post("/api/login", api.LoginHandler)
	r.Post("/api/signup", api.SignupHandler)
	r.Post("/api/verify", api.VerifyOTPHandler)
	r.Get("/api/debug/otp", api.DebugOTPHandler) // Remove in production

	// MetaMask Wallet Authentication (NEW)
	// TODO: Implement these handlers
	// r.Post("/api/auth/metamask", api.MetaMaskAuthHandler)
	// r.Get("/api/user/{wallet}", api.GetUserByWalletHandler)

	// Password Reset routes (public)
	r.Post("/api/forgot-password", api.ForgotPasswordHandler)
	r.Post("/api/verify-reset-otp", api.VerifyResetOTPHandler)
	r.Post("/api/reset-password", api.ResetPasswordHandler)

	// Course routes (public)
	r.Get("/api/courses", api.GetCoursesHandler)
	r.Get("/api/course", api.GetCourseHandler)
	r.Get("/api/user/enrollments", api.GetUserEnrollmentsHandler)

	// Instructor Course Management (Protected in real app, keeping simple for now)
	r.Post("/api/courses", api.CreateCourseHandler)
	r.Put("/api/courses", api.UpdateCourseHandler)
	// For getting courses by instructor ID specifically
	r.Get("/api/instructor/courses", api.GetInstructorCoursesHandler)

	// Forum routes (public read)
	r.Get("/api/posts", api.GetPostsHandler)
	r.Get("/api/posts/comments", api.GetCommentsHandler)

	// Gamification routes (public read)
	r.Get("/api/achievements", api.GetAchievementsHandler)
	// Duplicate removed (api.GetAchievementsHandler was listed twice)
	r.Get("/api/leaderboard", api.GetLeaderboardHandler)
	r.Post("/api/seed-data", api.SeedDataHandler) // Dev only - seeds test data

	// Public Verification Route
	r.Post("/api/certificates/verify", api.VerifyCertificateHandler)

	// Protected Instructor Routes
	r.Group(func(r chi.Router) {
		r.Use(middleware.WalletAuthMiddleware)
		r.Use(middleware.RoleAuthMiddleware("instructor"))
		r.Use(middleware.InstructorOnlyMiddleware)

		r.Post("/api/instructor/mint/prepare", api.PrepareMintHandler)
		// r.Post("/api/instructor/mint/confirm", api.ConfirmMintHandler) // Future: Record on-chain success
	})
	r.Get("/api/courses/recommendations", api.GetRecommendationsHandler)
	r.Get("/api/battles/questions", api.GetBattleQuestionsHandler)
	r.Post("/api/battles/complete", api.CompleteBattleHandler)
	r.Post("/api/seed-battle-data", api.SeedBattleDataHandler)
	r.Post("/api/notifications/seed", api.SeedNotificationsHandler(db.FirestoreClient))

	// Lesson Completion (Student Progress)
	r.Post("/api/course/level/complete", api.CompleteLessonHandler)

	// Certificate Verification (Public)
	r.Group(func(r chi.Router) {
		// TODO: Fix RateLimitMiddleware type signature
		// r.Use(middleware.RateLimitMiddleware(20, 1*time.Minute))
		r.Post("/api/verify-certificate", api.VerifyCertificateHandler)
	})
	r.Get("/api/verify/stats", api.GetVerificationStatsHandler)

	// Trust Intelligence Analytics (Public)
	r.Get("/api/analytics/trust", api.GetTrustAnalyticsHandler)
	r.Get("/api/analytics/instructor", api.GetInstructorAnalyticsHandler)
	r.Post("/api/analytics/instructor/update-reputation", api.UpdateInstructorReputationHandler)

	// Protected routes
	r.Group(func(r chi.Router) {
		r.Use(middleware.AuthMiddleware)

		// Course enrollment
		r.Post("/api/courses/enroll", api.EnrollCourseHandler)

		// Forum write operations
		r.Post("/api/posts", api.CreatePostHandler)
		r.Post("/api/posts/vote", api.VotePostHandler)
		r.Post("/api/posts/comment", api.AddCommentHandler)
		r.Post("/api/posts/comment/vote", api.VoteCommentHandler)
		r.Post("/api/posts/view", api.IncrementViewHandler)

		// AI routes (protected - login required)
		r.Post("/api/ai/chat", api.ChatHandler)
		r.Post("/api/ai/summarize", api.SummarizeHandler)
		r.Post("/api/ai/image-chat", api.ImageChatHandler)
		r.Post("/api/support/chat", api.SupportChatHandler)

		// User routes
		r.Post("/api/update-profile", api.UpdateProfileHandler)
		r.Get("/api/user/stats", api.GetUserStatsHandler)
		r.Get("/api/user/achievements", api.GetUserAchievementsHandler)

		// Certificate History (Protected)
		r.Get("/api/certificate/history", api.GetCertificateHistoryHandler)

		// Notification routes
		r.Get("/api/notifications", api.GetNotificationsHandler(db.FirestoreClient))
		r.Post("/api/notifications/:id/read", api.MarkNotificationReadHandler(db.FirestoreClient))
	})

	// Instructor routes
	r.Route("/api/instructor", func(r chi.Router) {
		// Some instructor routes may be public for demo, OR secured
		r.Get("/dashboard", api.InstructorDashboardHandler)
		r.Post("/certificate/generate", api.GenerateCertificateHandler)
		r.Post("/certificate/data", api.GetCertificateDataHandler)
		r.Get("/analytics", api.InstructorAnalyticsHandler)
		r.Post("/ai/question", api.GenerateQuestionHandler)

		// NEW: Instructor certificate management
		r.Get("/certificates", api.GetInstructorCertificatesHandler)
		r.Get("/stats", api.GetInstructorStatsHandler)
	})

	// Start blockchain services (Listener + Sync Worker)
	go func() {
		if config.AppConfig.BlockchainMode == "real" {
			log.Println("🎧 Starting Blockchain Event Listener...")
			listener, err := blockchain.NewEventListener(config.AppConfig.BlockchainRPC, config.AppConfig.ContractAddress)
			if err != nil {
				log.Printf("❌ Failed to start listener: %v", err)
			} else {
				listener.Start(context.Background())
			}

			// Start Background Sync Worker (Every 5 minutes)
			log.Println("🔄 Starting Background Sync Worker...")
			worker, err := blockchain.NewSyncWorker(config.AppConfig.BlockchainRPC, config.AppConfig.ContractAddress, 5*time.Minute)
			if err != nil {
				log.Printf("❌ Failed to start sync worker: %v", err)
			} else {
				worker.Start(context.Background())
			}
		}
	}()

	// Start server
	port := config.AppConfig.Port
	log.Printf("🚀 Cognify Backend starting on port %s", port)
	log.Printf("📝 API Documentation:")
	log.Printf("   POST /api/login           - Request OTP")
	log.Printf("   POST /api/verify          - Verify OTP and get token")
	log.Printf("   POST /api/auth/nonce      - Get login nonce")
	log.Printf("   POST /api/auth/login/wallet - Login with signature")

	if err := http.ListenAndServe(":"+port, r); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}

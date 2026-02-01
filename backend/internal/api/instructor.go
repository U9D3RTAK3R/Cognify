package api

import (
	"encoding/json"
	"net/http"
	"time"

	"cache-crew/cognify/internal/config"
	"cache-crew/cognify/internal/db"
	"cache-crew/cognify/internal/models"
	"cache-crew/cognify/internal/services"
	"cache-crew/cognify/internal/utils"
)

// GenerateCertificateRequest represents a certificate generation request
type GenerateCertificateRequest struct {
	UserID         string  `json:"userId"`
	UserName       string  `json:"userName"`
	CourseID       string  `json:"courseId"`
	CourseName     string  `json:"courseName"`
	Marks          float64 `json:"marks,omitempty"`
	WalletAddress  string  `json:"walletAddress,omitempty"`
	CompletionData string  `json:"completionData,omitempty"`
}

// GenerateCertificateHandler prepares certificate metadata for frontend minting
// This handler does NOT mint on the blockchain - the frontend does via MetaMask
func GenerateCertificateHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req GenerateCertificateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"error": "Invalid request body",
		})
		return
	}

	if req.UserID == "" || req.UserName == "" || req.CourseID == "" || req.CourseName == "" {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"error": "UserID, UserName, CourseID, and CourseName are required",
		})
		return
	}

	if req.WalletAddress == "" {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"error": "Student WalletAddress is required for blockchain minting",
		})
		return
	}

	issuedAt := time.Now()

	// Generate certificate hash using utility
	certHash := utils.GenerateCertificateHash(req.UserID, req.CourseID, issuedAt)

	// Generate Academic DNA for the student
	platformSecret := config.AppConfig.PlatformSecret
	if platformSecret == "" {
		platformSecret = "COGNIFY_PLATFORM_SECRET_V1" // Fallback for dev
	}
	academicDNA := utils.GenerateAcademicDNA(req.WalletAddress, req.UserID, issuedAt, platformSecret)

	// Create a PENDING certificate record (not yet minted)
	certificate := &models.Certificate{
		Hash:              certHash,
		StudentID:         req.UserID,
		StudentName:       req.UserName,
		CourseID:          req.CourseID,
		CourseName:        req.CourseName,
		Marks:             req.Marks,
		WalletAddress:     req.WalletAddress,
		IssuedAt:          issuedAt,
		BlockchainTx:      "", // Will be filled when frontend confirms minting
		TrustScore:        50, // Initial trust score
		VerificationCount: 0,
		AcademicDNA:       academicDNA,
		IsMinted:          false, // Pending state
	}

	// Calculate initial trust score
	trustEngine := services.NewTrustEngine()
	certificate.TrustScore = trustEngine.CalculateTrustScore(r.Context(), certificate)

	// Save PENDING certificate to Firestore
	if db.FirestoreClient != nil {
		_, err := db.FirestoreClient.Collection("certificates").Doc(certHash).Set(r.Context(), certificate)
		if err != nil {
			respondJSON(w, http.StatusInternalServerError, map[string]string{
				"error": "Failed to save pending certificate",
			})
			return
		}
	}

	// Return metadata for frontend to use in MetaMask transaction
	// The frontend will call the smart contract's mintCertificate function
	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success":         true,
		"certificateHash": certHash,
		"academicDNA":     academicDNA,
		"studentWallet":   req.WalletAddress,
		"issuedAt":        issuedAt.Unix(),
		"status":          "pending_mint",
		"message":         "Certificate prepared. Use MetaMask to mint on blockchain.",
		"data":            certificate,
	})
}

// GetCertificateDataHandler returns certificate data without generating PDF
func GetCertificateDataHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req GenerateCertificateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"error": "Invalid request body",
		})
		return
	}

	// Generate certificate content using Gemini
	content, err := services.GenerateCertificateContent(
		r.Context(),
		req.UserName,
		req.CourseName,
		req.CompletionData,
	)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{
			"error": "Failed to generate certificate content",
		})
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success":     true,
		"content":     content,
		"studentName": req.UserName,
		"courseName":  req.CourseName,
	})
}

// InstructorDashboardHandler returns instructor dashboard data
func InstructorDashboardHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	instructorID := r.URL.Query().Get("instructorId")
	if instructorID == "" {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"error": "Instructor ID is required",
		})
		return
	}

	var stats models.InstructorStats

	// Try to fetch from DB
	if db.FirestoreClient != nil {
		docRef := db.FirestoreClient.Collection("instructor_stats").Doc(instructorID)
		docSnap, err := docRef.Get(r.Context())

		if err != nil {
			// If not found or error, we assume missing and seed default data
			// User requested to "populate the database" so we'll create seed data

			// Seed Data (matches user's profile expectations: 156 students, 2 courses)
			stats = models.InstructorStats{
				InstructorID:     instructorID,
				TotalStudents:    156,
				ActiveCourses:    2,
				TotalEnrollments: 423,
				CompletionRate:   78.0,
				AverageRating:    4.8,
			}

			// Save seed data to DB
			_, setErr := docRef.Set(r.Context(), stats)
			if setErr != nil {
				// Just log error but continue with seeded stats locally
				// In a real app we'd log this properly
			}
		} else {
			// Found, unmarshal
			if err := docSnap.DataTo(&stats); err != nil {
				respondJSON(w, http.StatusInternalServerError, map[string]string{
					"error": "Failed to parse instructor stats",
				})
				return
			}
		}
	} else {
		// No DB connection, use mock
		stats = models.InstructorStats{
			InstructorID:     instructorID,
			TotalStudents:    156,
			ActiveCourses:    2,
			TotalEnrollments: 423,
			CompletionRate:   78.0,
			AverageRating:    4.8,
		}
	}

	// Load Recent Activity
	var activities []models.ActivityItem

	if db.FirestoreClient != nil {
		actDocRef := db.FirestoreClient.Collection("instructor_activities").Doc(instructorID)
		actSnap, err := actDocRef.Get(r.Context())

		if err != nil {
			// Seed Data
			activities = []models.ActivityItem{
				{ID: "a1", Type: "enrollment", Title: "New student enrolled", Subtitle: "John Doe joined Flutter Mastery", Timestamp: time.Now().Add(-20 * time.Minute)},
				{ID: "a2", Type: "completion", Title: "Course completed", Subtitle: "Jane completed Dart Basics", Timestamp: time.Now().Add(-2 * time.Hour)},
				{ID: "a3", Type: "feedback", Title: "New feedback", Subtitle: "5 new reviews on your course", Timestamp: time.Now().Add(-5 * time.Hour)},
				{ID: "a4", Type: "certificate", Title: "Certificate issued", Subtitle: "Mike earned Flutter Pro badge", Timestamp: time.Now().Add(-24 * time.Hour)},
			}
			// Wrapper struct for saving
			wrapper := map[string]interface{}{
				"items": activities,
			}
			_, _ = actDocRef.Set(r.Context(), wrapper)
		} else {
			var wrapper struct {
				Items []models.ActivityItem `firestore:"items"`
			}
			if err := actSnap.DataTo(&wrapper); err == nil {
				activities = wrapper.Items
			}
		}
	} else {
		// Mock
		activities = []models.ActivityItem{
			{ID: "a1", Type: "enrollment", Title: "New student enrolled", Subtitle: "John Doe joined Flutter Mastery", Timestamp: time.Now().Add(-20 * time.Minute)},
			{ID: "a2", Type: "completion", Title: "Course completed", Subtitle: "Jane completed Dart Basics", Timestamp: time.Now().Add(-2 * time.Hour)},
		}
	}

	// Construct final response
	dashboardData := map[string]interface{}{
		"totalStudents":    stats.TotalStudents,
		"activeCourses":    stats.ActiveCourses,
		"totalEnrollments": stats.TotalEnrollments,
		"completionRate":   stats.CompletionRate,
		"averageRating":    stats.AverageRating,
		"recentActivity":   activities,
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"data":    dashboardData,
	})
}

// InstructorAnalyticsHandler returns instructor analytics data including AI insights
func InstructorAnalyticsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	instructorID := r.URL.Query().Get("instructorId")
	if instructorID == "" {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"error": "Instructor ID is required",
		})
		return
	}

	var analytics models.InstructorAnalytics
	var activeCount, droppedCount, completedCount int

	// Try to fetch from DB
	if db.FirestoreClient != nil {
		docRef := db.FirestoreClient.Collection("instructor_analytics").Doc(instructorID)
		docSnap, err := docRef.Get(r.Context())

		if err != nil {
			// Seed Data if missing
			studs := []models.StudentProgress{
				{ID: "s1", StudentName: "John Doe", CourseName: "Flutter Mastery", Progress: 85, Status: "Active", LastActive: time.Now()},
				{ID: "s2", StudentName: "Jane Smith", CourseName: "Dart Basics", Progress: 42, Status: "Dropped", LastActive: time.Now().Add(-72 * time.Hour)},
				{ID: "s3", StudentName: "Mike Johnson", CourseName: "State Management", Progress: 95, Status: "Completed", LastActive: time.Now()},
				{ID: "s4", StudentName: "Sarah Wilson", CourseName: "Flutter Mastery", Progress: 28, Status: "Dropped", LastActive: time.Now().Add(-120 * time.Hour)},
				{ID: "s5", StudentName: "Tom Brown", CourseName: "UI/UX Design", Progress: 67, Status: "Active", LastActive: time.Now()},
			}

			// Calc counts
			for _, s := range studs {
				if s.Status == "Active" {
					activeCount++
				} else if s.Status == "Dropped" {
					droppedCount++
				} else if s.Status == "Completed" {
					completedCount++
				}
			}

			// Generate AI Insights
			dataSummary := "Students are struggling with State Management. Dropout rate is increasing in Dart Basics. Flutter Mastery has high engagement."
			insights, _ := services.GenerateAnalyticsInsights(r.Context(), dataSummary)

			// Fill model
			analytics = models.InstructorAnalytics{
				InstructorID:    instructorID,
				ActiveCount:     189, // Mocking larger numbers to match UI screenshot approximately
				DroppedCount:    23,
				CompletedCount:  45,
				StudentProgress: studs,
				Insights: models.AIInsights{
					Roadblocks:      insights.Roadblocks,
					Recommendations: insights.Recommendations,
				},
				UpdatedAt: time.Now(),
			}

			// Save to DB
			_, _ = docRef.Set(r.Context(), analytics)
		} else {
			// Found
			if err := docSnap.DataTo(&analytics); err != nil {
				respondJSON(w, http.StatusInternalServerError, map[string]string{
					"error": "Failed to parse analytics",
				})
				return
			}
		}
	} else {
		// Mock mode
		analytics = models.InstructorAnalytics{
			InstructorID:   instructorID,
			ActiveCount:    189,
			DroppedCount:   23,
			CompletedCount: 45,
			StudentProgress: []models.StudentProgress{
				{ID: "s1", StudentName: "John Doe", CourseName: "Flutter Mastery", Progress: 85, Status: "Active"},
				{ID: "s2", StudentName: "Jane Smith", CourseName: "Dart Basics", Progress: 42, Status: "Dropped"},
				{ID: "s3", StudentName: "Mike Johnson", CourseName: "State Management", Progress: 95, Status: "Completed"},
			},
			Insights: models.AIInsights{
				Roadblocks:      []string{"High dropoff in Module 3", "Quiz 1 scores low"},
				Recommendations: []string{"Add more examples", "Review Module 3 content"},
			},
		}
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"data":    analytics,
	})
}

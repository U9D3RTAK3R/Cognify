package api

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"cache-crew/cognify/internal/db"
	"cache-crew/cognify/internal/models"
	"cache-crew/cognify/internal/services"

	"cloud.google.com/go/firestore"
	"golang.org/x/crypto/bcrypt"
)

// LoginRequest represents the login request body
type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
	Role     string `json:"role"` // "student" or "instructor"
}

// VerifyOTPRequest represents the OTP verification request body
type VerifyOTPRequest struct {
	Email string `json:"email"`
	Code  string `json:"code"`
}

// AuthResponse represents the authentication response
type AuthResponse struct {
	Success bool         `json:"success"`
	Message string       `json:"message"`
	Token   string       `json:"token,omitempty"`
	User    *models.User `json:"user,omitempty"`
}

// LoginHandler handles the login request (sends OTP)
func LoginHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, AuthResponse{
			Success: false,
			Message: "Invalid request body",
		})
		return
	}

	if req.Email == "" {
		respondJSON(w, http.StatusBadRequest, AuthResponse{
			Success: false,
			Message: "Email is required",
		})
		return
	}

	// Check if user exists and get password
	var user models.User
	doc, err := db.FirestoreClient.Collection("users").Doc(req.Email).Get(r.Context())
	if err != nil {
		// Assume user not found or error
		respondJSON(w, http.StatusNotFound, AuthResponse{Success: false, Message: "User not found. Please sign up."})
		return
	}
	if err := doc.DataTo(&user); err != nil {
		respondJSON(w, http.StatusInternalServerError, AuthResponse{Success: false, Message: "Database error"})
		return
	}

	// Verify Password
	if user.Password == "" {
		// Allow legacy login if user has no password enabled?
		// User requested SECURITY flaw fix. So strict.
		// But for now, if no password set, maybe allow?
		// No, user specifically complained about "anyone can log in".
		// So force password check.
		respondJSON(w, http.StatusUnauthorized, AuthResponse{Success: false, Message: "Password authentication required. Please contact support or reset password."})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		respondJSON(w, http.StatusUnauthorized, AuthResponse{Success: false, Message: "Invalid email or password"})
		return
	}

	// Generate OTP
	otp, err := services.GenerateOTP(req.Email)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, AuthResponse{
			Success: false,
			Message: "Failed to generate OTP",
		})
		return
	}

	// Send OTP via email
	if err := services.SendOTPEmail(req.Email, otp); err != nil {
		respondJSON(w, http.StatusInternalServerError, AuthResponse{
			Success: false,
			Message: "Failed to send OTP email",
		})
		return
	}

	// Log attempt to BigQuery
	go func() {
		_ = db.InsertAnalyticsEvent(r.Context(), db.AnalyticsEvent{
			UserID:    req.Email,
			EventType: "auth_attempt",
			Data:      "{\"role\":\"" + req.Role + "\"}",
			Timestamp: time.Now().Unix(),
		})
	}()

	respondJSON(w, http.StatusOK, AuthResponse{
		Success: true,
		Message: "Password verified. OTP sent to your email.",
	})
}

// SignupHandler handles the signup request (sends OTP for new users)
func SignupHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req LoginRequest // Re-use LoginRequest struct as it has Email/Role
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, AuthResponse{Success: false, Message: "Invalid request body"})
		return
	}

	if req.Email == "" {
		respondJSON(w, http.StatusBadRequest, AuthResponse{Success: false, Message: "Email is required"})
		return
	}

	// Hash password
	hashedPwd, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, AuthResponse{Success: false, Message: "Failed to process password"})
		return
	}

	// Create user with hashed password (marked as unverified implicitly by lack of token usage initially, but we allow Login flow to handle 2FA)
	// We create the user doc now so Login can verify the password.
	newUser := map[string]interface{}{
		"id":        req.Email,
		"email":     req.Email,
		"role":      req.Role,
		"password":  string(hashedPwd),
		"createdAt": time.Now(),
		"updatedAt": time.Now(),
		// Add default fields to prevent nil issues later
		"xp":          0,
		"level":       1,
		"avatarEmoji": "🥷",
		"name":        "User", // Simplified name extraction
		"username":    req.Email,
	}

	if db.FirestoreClient != nil {
		_, err = db.FirestoreClient.Collection("users").Doc(req.Email).Set(r.Context(), newUser)
		if err != nil {
			respondJSON(w, http.StatusInternalServerError, AuthResponse{Success: false, Message: "Failed to create user"})
			return
		}
	}

	// Generate and Send OTP
	otp, err := services.GenerateOTP(req.Email)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, AuthResponse{Success: false, Message: "Failed to generate OTP"})
		return
	}

	if err := services.SendOTPEmail(req.Email, otp); err != nil {
		respondJSON(w, http.StatusInternalServerError, AuthResponse{Success: false, Message: "Failed to send OTP email"})
		return
	}

	respondJSON(w, http.StatusOK, AuthResponse{
		Success: true,
		Message: "OTP sent. Please verify to complete signup.",
	})
}

// VerifyOTPHandler handles OTP verification
func VerifyOTPHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req VerifyOTPRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, AuthResponse{
			Success: false,
			Message: "Invalid request body",
		})
		return
	}

	if req.Email == "" || req.Code == "" {
		respondJSON(w, http.StatusBadRequest, AuthResponse{
			Success: false,
			Message: fmt.Sprintf("Email and code are required"),
		})
		return
	}

	// Verify OTP
	if !services.VerifyOTP(req.Email, req.Code) {
		respondJSON(w, http.StatusUnauthorized, AuthResponse{
			Success: false,
			Message: "Invalid or expired OTP",
		})
		return
	}

	// Get or create user
	user, err := getOrCreateUser(r.Context(), req.Email)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, AuthResponse{
			Success: false,
			Message: "Failed to get user data",
		})
		return
	}

	// Generate JWT
	token, err := services.GenerateJWT(user.ID, user.Email, user.Role)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, AuthResponse{
			Success: false,
			Message: "Failed to generate token",
		})
		return
	}

	// Log success to BigQuery
	go func() {
		_ = db.InsertAnalyticsEvent(r.Context(), db.AnalyticsEvent{
			UserID:    user.ID,
			EventType: "auth_success",
			Data:      "{\"role\":\"" + user.Role + "\"}",
			Timestamp: time.Now().Unix(),
		})
	}()

	respondJSON(w, http.StatusOK, AuthResponse{
		Success: true,
		Message: "Authentication successful",
		Token:   token,
		User:    user,
	})
}

// DebugOTPHandler returns the current OTP for testing (remove in production)
func DebugOTPHandler(w http.ResponseWriter, r *http.Request) {
	email := r.URL.Query().Get("email")
	if email == "" {
		http.Error(w, "Email parameter required", http.StatusBadRequest)
		return
	}

	debug := services.GetOTPDebug(email)
	respondJSON(w, http.StatusOK, map[string]string{"debug": debug})
}

// UpdateProfileRequest represents the profile update request body
type UpdateProfileRequest struct {
	ID          string `json:"id"` // Email
	Name        string `json:"name"`
	Username    string `json:"username"`
	Bio         string `json:"bio"`
	AvatarEmoji string `json:"avatarEmoji"`
}

// UpdateProfileHandler handles profile updates
func UpdateProfileHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req UpdateProfileRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, AuthResponse{
			Success: false,
			Message: "Invalid request body",
		})
		return
	}

	if req.ID == "" {
		respondJSON(w, http.StatusBadRequest, AuthResponse{
			Success: false,
			Message: "User ID (email) is required",
		})
		return
	}

	// Update in Firestore
	if db.FirestoreClient != nil {
		_, err := db.FirestoreClient.Collection("users").Doc(req.ID).Set(r.Context(), map[string]interface{}{
			"name":        req.Name,
			"username":    req.Username,
			"bio":         req.Bio,
			"avatarEmoji": req.AvatarEmoji,
			"updatedAt":   time.Now(),
		}, firestore.MergeAll)

		if err != nil {
			respondJSON(w, http.StatusInternalServerError, AuthResponse{
				Success: false,
				Message: "Failed to update profile",
			})
			return
		}
	}

	respondJSON(w, http.StatusOK, AuthResponse{
		Success: true,
		Message: "Profile updated successfully",
	})
}

func getOrCreateUser(ctx context.Context, email string) (*models.User, error) {
	// If Firestore is not initialized, return mock user
	if db.FirestoreClient == nil {
		return &models.User{
			ID:        "mock-user-id",
			Email:     email,
			Name:      "Mock User",
			Role:      "student",
			XP:        100,
			Level:     1,
			CreatedAt: time.Now(),
			UpdatedAt: time.Now(),
		}, nil
	}

	// Try to get existing user
	doc, err := db.FirestoreClient.Collection("users").Doc(email).Get(ctx)
	if err == nil {
		var user models.User
		if err := doc.DataTo(&user); err == nil {
			return &user, nil
		}
		fmt.Printf("Error parsing user data: %v\n", err)
	} else {
		// Only log if it's NOT a "not found" error, although in Go Firestore, Not Found is an error (status code).
		// simpler: fmt.Printf("Get User Error (might be new user): %v\n", err)
	}

	// Create new user
	name := extractNameFromEmail(email)
	newUser := &models.User{
		ID:          email,
		Email:       email,
		Name:        name,
		Username:    name, // Default username from email part
		Role:        "student",
		AvatarEmoji: "🥷", // Default Ninja Avatar
		XP:          0,
		Level:       1,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	_, err = db.FirestoreClient.Collection("users").Doc(email).Set(ctx, newUser)
	if err != nil {
		fmt.Printf("Error Creating User in Firestore: %v\n", err)
		return nil, err
	}

	return newUser, nil
}

func extractNameFromEmail(email string) string {
	at := 0
	for i, c := range email {
		if c == '@' {
			at = i
			break
		}
	}
	if at > 0 {
		return email[:at]
	}
	return "User"
}

func checkUserExists(ctx context.Context, email string) (bool, error) {
	if db.FirestoreClient == nil {
		return true, nil // Mock mode: assume user exists for login flow simplicity or handle differently
	}
	doc, err := db.FirestoreClient.Collection("users").Doc(email).Get(ctx)
	if err != nil {
		// grpc.Code(err) == codes.NotFound ?
		// simplistic check: if error contains "not found" or similar
		// But firestore.Get returns error if not found.
		// Actually best way is to check doc.Exists() but Get() errors if missing.
		// Wait, go firestore Get() returns error if doc doesn't exist.
		return false, nil
	}
	return doc.Exists(), nil
}

func respondJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(data)
}

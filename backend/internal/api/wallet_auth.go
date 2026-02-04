package api

import (
	"context"
	"crypto/rand"
	"encoding/hex"
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
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/ethereum/go-ethereum/crypto"
)

// NonceRequest represents request for a nonce
type NonceRequest struct {
	WalletAddress string `json:"walletAddress"`
}

// WalletLoginRequest represents wallet login with signature
type WalletLoginRequest struct {
	WalletAddress string `json:"walletAddress"`
	Signature     string `json:"signature"`
	Email         string `json:"email,omitempty"` // Optional: for linking/2FA
}

// GenerateNonceHandler generates a cryptographically secure nonce
func GenerateNonceHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req NonceRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, AuthResponse{Success: false, Message: "Invalid request"})
		return
	}

	if req.WalletAddress == "" {
		respondJSON(w, http.StatusBadRequest, AuthResponse{Success: false, Message: "Wallet address required"})
		return
	}

	// Generate secure random nonce
	nonceBytes := make([]byte, 32)
	if _, err := rand.Read(nonceBytes); err != nil {
		respondJSON(w, http.StatusInternalServerError, AuthResponse{Success: false, Message: "Failed to generate nonce"})
		return
	}
	nonce := hex.EncodeToString(nonceBytes)
	message := fmt.Sprintf("Sign this message to authenticate with Cognify: %s", nonce)

	if db.FirestoreClient != nil {
		_, err := db.FirestoreClient.Collection("auth_nonces").Doc(strings.ToLower(req.WalletAddress)).Set(r.Context(), map[string]interface{}{
			"nonce":     nonce,
			"message":   message,
			"expiresAt": time.Now().Add(5 * time.Minute),
		})
		if err != nil {
			log.Printf("Failed to store nonce: %v", err)
			respondJSON(w, http.StatusInternalServerError, AuthResponse{Success: false, Message: "Database error"})
			return
		}
	} else {
		log.Printf("[MOCK] Generated Nonce for %s: %s", req.WalletAddress, message)
	}

	respondJSON(w, http.StatusOK, map[string]string{
		"nonce":   nonce,
		"message": message,
	})
}

// WalletLoginHandler verifies signature and issues token
func WalletLoginHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req WalletLoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, AuthResponse{Success: false, Message: "Invalid request"})
		return
	}

	walletLower := strings.ToLower(req.WalletAddress)

	// 1. Retrieve Nonce and Verify Signature
	if db.FirestoreClient != nil {
		doc, err := db.FirestoreClient.Collection("auth_nonces").Doc(walletLower).Get(r.Context())
		if err != nil {
			respondJSON(w, http.StatusUnauthorized, AuthResponse{Success: false, Message: "Nonce expired or invalid. Request new nonce."})
			return
		}

		expiresAt := doc.Data()["expiresAt"].(time.Time)
		if time.Now().After(expiresAt) {
			respondJSON(w, http.StatusUnauthorized, AuthResponse{Success: false, Message: "Nonce expired"})
			return
		}
		storedMessage := doc.Data()["message"].(string)

		// Verify Signature
		valid, err := verifySignature(req.WalletAddress, req.Signature, storedMessage)
		if err != nil || !valid {
			log.Printf("Signature verification failed: %v", err)
			respondJSON(w, http.StatusUnauthorized, AuthResponse{Success: false, Message: "Invalid signature"})
			return
		}

		// Invalidate nonce to prevent replay
		_, _ = db.FirestoreClient.Collection("auth_nonces").Doc(walletLower).Delete(r.Context())

	} else {
		if req.Signature != "mock_sig" {
			respondJSON(w, http.StatusBadRequest, AuthResponse{Success: false, Message: "Mock mode requires 'mock_sig'"})
			return
		}
	}

	// 2. Get User (by Email if provided, else by Wallet)
	var user *models.User
	var err error

	if req.Email != "" {
		// 2FA/Linking Scenario: Fetch by Email
		user, err = getUserByEmail(r.Context(), req.Email)
		if err != nil {
			respondJSON(w, http.StatusNotFound, AuthResponse{Success: false, Message: "User not found with provided email"})
			return
		}
		// LINK WALLET: Update user's wallet address if not set or different
		if user.WalletAddress != walletLower && db.FirestoreClient != nil {
			_, err := db.FirestoreClient.Collection("users").Doc(user.ID).Update(r.Context(), []firestore.Update{
				{Path: "walletAddress", Value: walletLower},
			})
			if err != nil {
				log.Printf("Failed to link wallet: %v", err)
				// Continue anyway, just logging the error
			}
			user.WalletAddress = walletLower
		}
	} else {
		// Primary Wallet Login: Fetch by Wallet
		user, err = getUserByWallet(r.Context(), walletLower)
		if err != nil {
			respondJSON(w, http.StatusNotFound, AuthResponse{Success: false, Message: "Wallet not registered. Please sign up or link wallet."})
			return
		}
	}

	// 3. Generate Token
	token, err := services.GenerateJWT(user.ID, user.Email, user.Role)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, AuthResponse{Success: false, Message: "Token generation failed"})
		return
	}

	respondJSON(w, http.StatusOK, AuthResponse{
		Success: true,
		Token:   token,
		User:    user,
		Message: "Wallet authentication successful",
	})
}

// Helper to get user by email (Add this if not present or rely on existing)
func getUserByEmail(ctx context.Context, email string) (*models.User, error) {
	if db.FirestoreClient == nil {
		return &models.User{ID: email, Email: email, Role: "student"}, nil
	}
	doc, err := db.FirestoreClient.Collection("users").Doc(email).Get(ctx)
	if err != nil {
		return nil, err
	}
	var user models.User
	if err := doc.DataTo(&user); err != nil {
		return nil, err
	}
	return &user, nil
}

func verifySignature(address, signature, message string) (bool, error) {
	// Add Ethereum message prefix
	prefixedMessage := fmt.Sprintf("\x19Ethereum Signed Message:\n%d%s", len(message), message)
	hash := crypto.Keccak256Hash([]byte(prefixedMessage))

	sigBytes, err := hexutil.Decode(signature)
	if err != nil {
		return false, err
	}

	// Adjust V value for recovery
	if sigBytes[64] >= 27 {
		sigBytes[64] -= 27
	}

	pubKey, err := crypto.SigToPub(hash.Bytes(), sigBytes)
	if err != nil {
		return false, err
	}

	recoveredAddr := crypto.PubkeyToAddress(*pubKey)
	return strings.ToLower(recoveredAddr.Hex()) == strings.ToLower(address), nil
}

func getUserByWallet(ctx context.Context, wallet string) (*models.User, error) {
	if db.FirestoreClient == nil {
		// Mock
		return &models.User{
			ID:            "mock_user",
			Email:         "mock@cognify.edu",
			Role:          "student",
			WalletAddress: wallet,
		}, nil
	}

	// Query users by walletAddress field
	iter := db.FirestoreClient.Collection("users").Where("walletAddress", "==", wallet).Documents(ctx)
	doc, err := iter.Next()
	if err != nil {
		return nil, err
	}

	var user models.User
	if err := doc.DataTo(&user); err != nil {
		return nil, err
	}
	return &user, nil
}

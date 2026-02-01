package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"cache-crew/cognify/internal/config"
)

// SendOTPEmail sends an OTP code to the specified email address using Resend.com
func SendOTPEmail(toEmail, otpCode string) error {
	cfg := config.AppConfig

	// If Resend API Key is not configured, log the OTP instead
	if cfg.ResendAPIKey == "" {
		log.Printf("=== MOCK EMAIL (Resend Key Missing) ===")
		log.Printf("To: %s", toEmail)
		log.Printf("Subject: Your Cognify Verification Code")
		log.Printf("Body: Your verification code is: %s (valid for 180 seconds)", otpCode)
		log.Printf("=======================================")
		return nil
	}

	url := "https://api.resend.com/emails"

	// Compose the email HTML body
	htmlBody := fmt.Sprintf(`
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; background-color: #0a0a0a; color: #ffffff; }
        .container { max-width: 500px; margin: 0 auto; padding: 40px; }
        .header { text-align: center; margin-bottom: 30px; }
        .logo { font-size: 32px; font-weight: bold; color: #00f5ff; letter-spacing: 4px; }
        .code-box { background: linear-gradient(135deg, #00f5ff22, #bf00ff22); 
                    border: 1px solid #00f5ff44; border-radius: 12px; 
                    padding: 30px; text-align: center; margin: 20px 0; }
        .code { font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #00f5ff; }
        .timer { color: #888; font-size: 14px; margin-top: 10px; }
        .footer { text-align: center; color: #666; font-size: 12px; margin-top: 30px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">COGNIFY</div>
            <p>Level Up Your Mind</p>
        </div>
        <div class="code-box">
            <p>Your verification code is:</p>
            <div class="code">%s</div>
            <div class="timer">⏱️ Valid for 180 seconds</div>
        </div>
        <div class="footer">
            <p>If you didn't request this code, please ignore this email.</p>
        </div>
    </div>
</body>
</html>
`, otpCode)

	payload := map[string]interface{}{
		"from":    "Cognify <onboarding@cognify.localplayer.dev>", // Use verified domain in prod or onboarding@resend.dev for test
		"to":      []string{toEmail},
		"subject": "Your Cognify Verification Code",
		"html":    htmlBody,
	}

	jsonPayload, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal email payload: %w", err)
	}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonPayload))
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Authorization", "Bearer "+cfg.ResendAPIKey)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{
		Timeout: 10 * time.Second,
	}
	resp, err := client.Do(req)
	if err != nil {
		// Don't block flow, just log error
		log.Printf("Error sending email via Resend: %v", err)
		log.Printf("=== BACKUP OTP LOG ===")
		log.Printf("To: %s", toEmail)
		log.Printf("Code: %s", otpCode)
		return nil
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		// Read body for details
		// Don't block flow, just log error
		log.Printf("Error sending email via Resend: Status %d", resp.StatusCode)
		log.Printf("=== BACKUP OTP LOG ===")
		log.Printf("To: %s", toEmail)
		log.Printf("Code: %s", otpCode)
		return nil
	}

	log.Printf("OTP email sent successfully to %s via Resend", toEmail)
	return nil
}

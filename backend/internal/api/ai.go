package api

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"

	"cache-crew/cognify/internal/db"
	"cache-crew/cognify/internal/services"
)

// ChatRequest represents an AI chat request
type ChatRequest struct {
	Message string `json:"message"`
	Context string `json:"context,omitempty"`
}

// SummarizeRequest represents a summarization request
type SummarizeRequest struct {
	DataType string `json:"dataType"` // e.g., "class_performance", "student_progress"
	Data     string `json:"data"`     // JSON string of the data to summarize
}

// ChatHandler handles AI chat requests
// ChatHandler handles AI chat requests
func ChatHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Println("DEBUG: Entering ChatHandler")
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req ChatRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		fmt.Printf("DEBUG: Error decoding request: %v\n", err)
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"message": "Invalid request body",
		})
		return
	}
	fmt.Printf("DEBUG: Chat Request Received: Message='%s'\n", req.Message)

	if req.Message == "" {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"message": "Message is required",
		})
		return
	}

	fmt.Println("DEBUG: Calling services.ChatWithAI")
	response, err := services.ChatWithAI(r.Context(), req.Message, req.Context)
	if err != nil {
		fmt.Printf("DEBUG: GenAI Error: %v\n", err)
		respondJSON(w, http.StatusInternalServerError, map[string]string{
			"message": fmt.Sprintf("AI Error: %v", err),
		})
		return
	}
	fmt.Println("DEBUG: ChatWithAI returned success")

	// Log AI interaction to BigQuery
	go func() {
		userID := "anonymous"
		_ = db.InsertAnalyticsEvent(r.Context(), db.AnalyticsEvent{
			UserID:    userID,
			EventType: "ai_interaction",
			Data:      "{\"type\":\"chat\"}",
			Timestamp: time.Now().Unix(),
		})
	}()

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success":  true,
		"response": response,
	})
}

// SummarizeHandler handles data summarization requests
func SummarizeHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req SummarizeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"error": "Invalid request body",
		})
		return
	}

	if req.DataType == "" || req.Data == "" {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"error": "DataType and Data are required",
		})
		return
	}

	summary, err := services.SummarizeData(r.Context(), req.DataType, req.Data)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{
			"error": "Failed to summarize data",
		})
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"summary": summary,
	})
}

// SupportChatRequest represents a support chat request
type SupportChatRequest struct {
	Message string `json:"message"`
	Context string `json:"context,omitempty"`
}

// SupportChatHandler handles support chat requests with a specialized persona
func SupportChatHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req SupportChatRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"message": "Invalid request body",
		})
		return
	}

	if req.Message == "" {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"message": "Message is required",
		})
		return
	}

	response, err := services.SupportChatWithAI(r.Context(), req.Message, req.Context)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{
			"message": fmt.Sprintf("Support error: %v", err),
		})
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success":  true,
		"response": response,
	})
}

// ImageChatHandler handles image analysis requests with Gemini Vision
func ImageChatHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Parse multipart form (max 10MB)
	if err := r.ParseMultipartForm(10 << 20); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"message": "Failed to parse form data. Max file size is 10MB.",
		})
		return
	}

	// Get the message (optional)
	message := r.FormValue("message")

	// Get the image file
	file, header, err := r.FormFile("image")
	if err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"message": "Image file is required",
		})
		return
	}
	defer file.Close()

	// Read image data
	imageData := make([]byte, header.Size)
	if _, err := file.Read(imageData); err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{
			"message": "Failed to read image file",
		})
		return
	}

	// Detect MIME type from actual file bytes (more reliable than header)
	mimeType := http.DetectContentType(imageData)

	// Ensure it's a valid image type
	if mimeType == "application/octet-stream" {
		// Try to guess from file extension
		filename := header.Filename
		switch {
		case strings.HasSuffix(strings.ToLower(filename), ".png"):
			mimeType = "image/png"
		case strings.HasSuffix(strings.ToLower(filename), ".gif"):
			mimeType = "image/gif"
		case strings.HasSuffix(strings.ToLower(filename), ".webp"):
			mimeType = "image/webp"
		default:
			mimeType = "image/jpeg" // Default to JPEG
		}
	}

	fmt.Printf("DEBUG: Received image for analysis (size: %d bytes, type: %s)\n", len(imageData), mimeType)

	// Call Gemini Vision
	response, err := services.ChatWithImage(r.Context(), message, imageData, mimeType)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{
			"message": fmt.Sprintf("Vision analysis error: %v", err),
		})
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success":  true,
		"response": response,
	})
}

// GenerateQuestionRequest represents a request to generate a course question
type GenerateQuestionRequest struct {
	CourseTitle       string `json:"courseTitle"`
	LevelTitle        string `json:"levelTitle"`
	ExistingQuestions []struct {
		Text    string   `json:"text"`
		Options []string `json:"options"`
	} `json:"existingQuestions"`
}

// GenerateQuestionHandler handles question generation requests
func GenerateQuestionHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req GenerateQuestionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"message": "Invalid request body",
		})
		return
	}

	// Validation
	if len(req.ExistingQuestions) == 0 {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"message": "At least one existing question is required to generate a new one.",
		})
		return
	}

	// Limit check (simple static check here, could be dynamic)
	if len(req.ExistingQuestions) >= 20 {
		respondJSON(w, http.StatusBadRequest, map[string]string{
			"message": "Question limit reached (20). Cannot generate more.",
		})
		return
	}

	// Construct Prompt
	prompt := fmt.Sprintf(`You are an expert course instructor for a course titled "%s", level "%s".
Your task is to generate ONE new multiple-choice question relevant to this level.
Use the following existing questions as context for style and difficulty (do not duplicate them):
`, req.CourseTitle, req.LevelTitle)

	for i, q := range req.ExistingQuestions {
		prompt += fmt.Sprintf("Q%d: %s\n", i+1, q.Text)
	}

	prompt += `
Return the new question in strictly valid JSON format like this:
{
  "text": "Question text here",
  "options": ["Option A", "Option B", "Option C", "Option D"],
  "correctIndex": 0,
  "difficulty": "Medium",
  "explanation": "Brief explanation"
}
Key requirements:
1. "correctIndex" must be an integer (0-3).
2. "options" must have exactly 4 strings.
3. Do not wrap code blocks or markdown around the JSON. Return only the JSON string (no backticks).
`

	response, err := services.ChatWithAI(r.Context(), prompt, "")
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{
			"message": fmt.Sprintf("AI Generation Error: %v", err),
		})
		return
	}

	// Parse valid JSON from response (Gemini might wrap in brackets sometimes or add text)
	cleanResponse := strings.TrimSpace(response)

	// Find the first '{' and last '}' to extract the JSON object
	start := strings.Index(cleanResponse, "{")
	end := strings.LastIndex(cleanResponse, "}")

	if start != -1 && end != -1 && end > start {
		cleanResponse = cleanResponse[start : end+1]
	} else {
		// Fallback cleanups if regex-like extraction failed (though unlikely if valid JSON exists)
		cleanResponse = strings.TrimPrefix(cleanResponse, "```json")
		cleanResponse = strings.TrimPrefix(cleanResponse, "```")
		cleanResponse = strings.TrimSuffix(cleanResponse, "```")
	}

	// Create a temporary struct to decode AI response
	var generatedQ struct {
		Text         string   `json:"text"`
		Options      []string `json:"options"`
		CorrectIndex int      `json:"correctIndex"`
		Difficulty   string   `json:"difficulty"`
		Explanation  string   `json:"explanation"`
	}

	if err := json.Unmarshal([]byte(cleanResponse), &generatedQ); err != nil {
		// Log error but try to return raw if parsing fails
		fmt.Printf("JSON Parse Error on AI response: %v\nResponse: %s\n", err, cleanResponse)
		respondJSON(w, http.StatusInternalServerError, map[string]string{
			"message": "AI generated invalid format. Please try again.",
		})
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"data":    generatedQ,
	})
}

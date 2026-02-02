package models

import "time"

type User struct {
	ID              string    `json:"id,omitempty" firestore:"id,omitempty"`
	Email           string    `json:"email" firestore:"email"`
	Name            string    `json:"name" firestore:"name"`
	Username        string    `json:"username" firestore:"username"`
	Role            string    `json:"role" firestore:"role"` // "student" or "instructor"
	CreatedAt       time.Time `json:"createdAt" firestore:"created_at"`
	ProfileImageURL string    `json:"profileImageUrl,omitempty" firestore:"profile_image_url,omitempty"`

	// Legacy fields (for backward compatibility with old auth)
	Password       string    `json:"-" firestore:"password,omitempty"`
	Institution    string    `json:"institution,omitempty" firestore:"institution,omitempty"`
	XP             int       `json:"xp,omitempty" firestore:"xp,omitempty"`
	Level          int       `json:"level,omitempty" firestore:"level,omitempty"`
	UpdatedAt      time.Time `json:"updatedAt,omitempty" firestore:"updatedAt,omitempty"`
	ProfilePicture string    `json:"profilePicture,omitempty" firestore:"profilePicture,omitempty"`
	AvatarEmoji    string    `json:"avatarEmoji,omitempty" firestore:"avatarEmoji,omitempty"`

	// MetaMask Wallet Authentication
	WalletAddress   string    `json:"walletAddress,omitempty" firestore:"wallet_address,omitempty"`
	ReputationScore int       `json:"reputationScore,omitempty" firestore:"reputation_score,omitempty"`
	LastLogin       time.Time `json:"lastLogin,omitempty" firestore:"last_login,omitempty"`
	StudentName     string    `json:"studentName,omitempty" firestore:"student_name,omitempty"`

	// Academic DNA Identity
	AcademicDNA    string    `json:"academicDNA,omitempty" firestore:"academic_dna,omitempty"`
	DNAGeneratedAt time.Time `json:"dnaGeneratedAt,omitempty" firestore:"dna_generated_at,omitempty"`
	StudentID      string    `json:"studentId,omitempty" firestore:"student_id,omitempty"`

	// Instructor-specific fields
	InstructorName string `json:"instructorName,omitempty" firestore:"instructor_name,omitempty"`
	IsAuthorized   bool   `json:"isAuthorized,omitempty" firestore:"is_authorized,omitempty"`
}

type Course struct {
	ID               string        `json:"id" firestore:"id"`
	Title            string        `json:"title" firestore:"title"`
	Subtitle         string        `json:"subtitle" firestore:"subtitle"`
	Description      string        `json:"description" firestore:"description"`
	Emoji            string        `json:"emoji" firestore:"emoji"`
	ColorHex         string        `json:"colorHex" firestore:"colorHex"`
	Tags             []string      `json:"tags" firestore:"tags"`
	InstructorID     string        `json:"instructorId" firestore:"instructorId"`
	InstructorName   string        `json:"instructorName" firestore:"instructorName"`     // Added
	Duration         string        `json:"duration" firestore:"duration"`                 // Added: e.g. "5h", "10h 30m"
	DifficultyRating int           `json:"difficultyRating" firestore:"difficultyRating"` // 1-5 or similar
	Prerequisites    []string      `json:"prerequisites" firestore:"prerequisites"`
	LearningOutcomes string        `json:"learningOutcomes" firestore:"learningOutcomes"`
	Levels           []CourseLevel `json:"levels" firestore:"levels"` // Ordered list of lessons
	CreatedAt        time.Time     `json:"createdAt" firestore:"createdAt"`
}

// CourseLevel represents a single lesson/module within a course
type CourseLevel struct {
	ID        string     `json:"id" firestore:"id"`
	Title     string     `json:"title" firestore:"title"`
	Content   string     `json:"content" firestore:"content"`     // Markdown text for reading
	VideoURL  string     `json:"videoUrl" firestore:"videoUrl"`   // YouTube embed URL
	Questions []Question `json:"questions" firestore:"questions"` // Embedded questions
}

type Enrollment struct {
	ID          string     `json:"id" firestore:"id"`
	UserID      string     `json:"userId" firestore:"userId"`
	CourseID    string     `json:"courseId" firestore:"courseId"`
	Progress    float64    `json:"progress" firestore:"progress"`
	Completed   bool       `json:"completed" firestore:"completed"`
	StartedAt   time.Time  `json:"startedAt" firestore:"startedAt"`
	CompletedAt *time.Time `json:"completedAt,omitempty" firestore:"completedAt,omitempty"`
}

type Post struct {
	ID           string    `json:"id" firestore:"id"`
	AuthorID     string    `json:"authorId" firestore:"authorId"`
	AuthorName   string    `json:"authorName" firestore:"authorName"`
	AvatarEmoji  string    `json:"avatarEmoji" firestore:"avatarEmoji"`
	CourseID     string    `json:"courseId" firestore:"courseId"`
	Title        string    `json:"title" firestore:"title"`
	Content      string    `json:"content" firestore:"content"`
	Tags         []string  `json:"tags" firestore:"tags"`
	Upvotes      int       `json:"upvotes" firestore:"upvotes"`
	Downvotes    int       `json:"downvotes" firestore:"downvotes"`
	UpvotedBy    []string  `json:"upvotedBy" firestore:"upvotedBy"`
	DownvotedBy  []string  `json:"downvotedBy" firestore:"downvotedBy"`
	CommentCount int       `json:"commentCount" firestore:"commentCount"`
	ViewCount    int       `json:"viewCount" firestore:"viewCount"`
	CreatedAt    time.Time `json:"createdAt" firestore:"createdAt"`
}

type Comment struct {
	ID          string    `json:"id" firestore:"id"`
	PostID      string    `json:"postId" firestore:"postId"`
	AuthorID    string    `json:"authorId" firestore:"authorId"`
	AuthorName  string    `json:"authorName" firestore:"authorName"`
	AvatarEmoji string    `json:"avatarEmoji" firestore:"avatarEmoji"`
	Content     string    `json:"content" firestore:"content"`
	Upvotes     int       `json:"upvotes" firestore:"upvotes"`
	Downvotes   int       `json:"downvotes" firestore:"downvotes"`
	UpvotedBy   []string  `json:"upvotedBy" firestore:"upvotedBy"`
	DownvotedBy []string  `json:"downvotedBy" firestore:"downvotedBy"`
	CreatedAt   time.Time `json:"createdAt" firestore:"createdAt"`
	ParentID    string    `json:"parentId,omitempty" firestore:"parentId,omitempty"` // Added for replies
}

type Certificate struct {
	// Legacy fields (for backward compatibility)
	ID          string    `json:"id,omitempty" firestore:"id,omitempty"`
	UserID      string    `json:"userId,omitempty" firestore:"userId,omitempty"`
	UserName    string    `json:"userName,omitempty" firestore:"userName,omitempty"`
	CourseID    string    `json:"courseId,omitempty" firestore:"courseId,omitempty"`
	CourseTitle string    `json:"courseTitle,omitempty" firestore:"courseTitle,omitempty"`
	IssuedAt    time.Time `json:"issuedAt" firestore:"issuedAt"`
	Skills      []string  `json:"skills,omitempty" firestore:"skills,omitempty"`
	Message     string    `json:"message,omitempty" firestore:"message,omitempty"`
	PDFUrl      string    `json:"pdfUrl,omitempty" firestore:"pdfUrl,omitempty"`

	// Blockchain Verification Fields (NEW)
	Hash              string  `firestore:"hash" json:"hash,omitempty"`
	StudentID         string  `firestore:"student_id" json:"studentId,omitempty"`
	StudentName       string  `firestore:"student_name" json:"studentName,omitempty"`
	CourseName        string  `firestore:"course_name" json:"courseName,omitempty"`
	Marks             float64 `firestore:"marks" json:"marks,omitempty"`
	WalletAddress     string  `firestore:"wallet_address" json:"walletAddress,omitempty"`
	BlockchainTx      string  `firestore:"blockchain_tx" json:"blockchainTx,omitempty"`
	IPFSCID           string  `firestore:"ipfs_cid" json:"ipfsCid,omitempty"`
	TrustScore        int     `firestore:"trust_score" json:"trustScore,omitempty"`
	VerificationCount int     `firestore:"verification_count" json:"verificationCount,omitempty"`
	Revoked           bool    `firestore:"revoked" json:"revoked,omitempty"`
	IsMinted          bool    `firestore:"is_minted" json:"isMinted,omitempty"`

	// Academic DNA Identity (NEW)
	AcademicDNA string `firestore:"academic_dna" json:"academicDNA,omitempty"`

	// Instructor Information (NEW)
	InstructorWallet string `firestore:"instructor_wallet" json:"instructorWallet,omitempty"`
	InstructorName   string `firestore:"instructor_name" json:"instructorName,omitempty"`
}

// Question represents a battle question
type Question struct {
	ID           string   `json:"id" firestore:"id"`
	Text         string   `json:"text" firestore:"text"`
	Options      []string `json:"options" firestore:"options"`
	CorrectIndex int      `json:"correctIndex" firestore:"correctIndex"`
	Difficulty   string   `json:"difficulty" firestore:"difficulty"` // "Easy", "Medium", "Hard", "Boss"
	Topic        string   `json:"topic" firestore:"topic"`           // e.g. "Dart", "Flutter", "State Management"
	Explanation  string   `json:"explanation" firestore:"explanation"`
	Points       int      `json:"points" firestore:"points"`
	TimeLimit    int      `json:"timeLimit" firestore:"timeLimit"`
}

// BattleHistory tracks a user's battle performance
type BattleHistory struct {
	ID          string    `json:"id" firestore:"id"`
	UserID      string    `json:"userId" firestore:"userId"`
	QuestionIDs []string  `json:"questionIds" firestore:"questionIds"`
	Score       int       `json:"score" firestore:"score"`
	Outcome     string    `json:"outcome" firestore:"outcome"` // "Victory", "Defeat"
	WeakPoints  []string  `json:"weakPoints" firestore:"weakPoints"`
	PlayedAt    time.Time `json:"playedAt" firestore:"playedAt"`
}

// AIRecommendation represents a course recommendation
type AIRecommendation struct {
	ID          string    `json:"id" firestore:"id"`
	UserID      string    `json:"userId" firestore:"userId"`
	CourseID    string    `json:"courseId" firestore:"courseId"` // Linked course ID
	Reason      string    `json:"reason" firestore:"reason"`     // "Why this was chosen"
	GeneratedAt time.Time `json:"generatedAt" firestore:"generatedAt"`
}

type InstructorStats struct {
	InstructorID     string  `json:"instructorId" firestore:"instructorId"`
	TotalStudents    int     `json:"totalStudents" firestore:"totalStudents"`
	ActiveCourses    int     `json:"activeCourses" firestore:"activeCourses"`
	TotalEnrollments int     `json:"totalEnrollments" firestore:"totalEnrollments"`
	CompletionRate   float64 `json:"completionRate" firestore:"completionRate"`
	AverageRating    float64 `json:"averageRating" firestore:"averageRating"`
}

type StudentProgress struct {
	ID          string    `json:"id" firestore:"id"`
	StudentName string    `json:"studentName" firestore:"studentName"`
	CourseName  string    `json:"courseName" firestore:"courseName"`
	Progress    int       `json:"progress" firestore:"progress"`
	Status      string    `json:"status" firestore:"status"` // "Active", "Dropped", "Completed"
	LastActive  time.Time `json:"lastActive" firestore:"lastActive"`
}

type AIInsights struct {
	Roadblocks      []string `json:"roadblocks" firestore:"roadblocks"`
	Recommendations []string `json:"recommendations" firestore:"recommendations"`
}

type InstructorAnalytics struct {
	InstructorID    string            `json:"instructorId" firestore:"instructorId"`
	ActiveCount     int               `json:"activeCount" firestore:"activeCount"`
	DroppedCount    int               `json:"droppedCount" firestore:"droppedCount"`
	CompletedCount  int               `json:"completedCount" firestore:"completedCount"`
	StudentProgress []StudentProgress `json:"studentProgress" firestore:"studentProgress"`
	Insights        AIInsights        `json:"insights" firestore:"insights"`
	UpdatedAt       time.Time         `json:"updatedAt" firestore:"updatedAt"`
}

type ActivityItem struct {
	ID        string    `json:"id" firestore:"id"`
	Type      string    `json:"type" firestore:"type"` // "enrollment", "completion", "feedback", "certificate"
	Title     string    `json:"title" firestore:"title"`
	Subtitle  string    `json:"subtitle" firestore:"subtitle"`
	Timestamp time.Time `json:"timestamp" firestore:"timestamp"`
}

// SystemState tracks global system state like blockchain sync progress
type SystemState struct {
	ID              string    `json:"id" firestore:"id"` // "sync_state"
	LastSyncedBlock uint64    `json:"lastSyncedBlock" firestore:"last_synced_block"`
	UpdatedAt       time.Time `json:"updatedAt" firestore:"updated_at"`
}

// -------------------------------------------------------------------
// TRUST INTELLIGENCE MODELS
// -------------------------------------------------------------------

// IssuerReputation tracks the long-term trustworthiness of an instructor
type IssuerReputation struct {
	InstructorID    string    `json:"instructorId" firestore:"instructor_id"`
	TotalIssued     int       `json:"totalIssued" firestore:"total_issued"`
	RevocationCount int       `json:"revocationCount" firestore:"revocation_count"`
	AvgTrustScore   float64   `json:"avgTrustScore" firestore:"avg_trust_score"`
	ReputationScore float64   `json:"reputationScore" firestore:"reputation_score"` // 0-100
	UpdatedAt       time.Time `json:"updatedAt" firestore:"updated_at"`
}

// TrustHistoryEvent records a snapshot of a certificate's trust score
type TrustHistoryEvent struct {
	CertificateHash string    `firestore:"certificate_hash" json:"certificateHash"`
	Score           int       `firestore:"score" json:"score"`
	Reason          string    `firestore:"reason" json:"reason"` // e.g. "verification", "manual_update"
	Timestamp       time.Time `firestore:"timestamp" json:"timestamp"`
}

// VerificationMetric tracks aggregated verification testing data
type VerificationMetric struct {
	CertificateHash    string         `json:"certificateHash" firestore:"certificate_hash"`
	TotalVerifications int            `json:"totalVerifications" firestore:"total_verifications"`
	UniqueVerifiers    int            `json:"uniqueVerifiers" firestore:"unique_verifiers"`
	GeoDistribution    map[string]int `json:"geoDistribution" firestore:"geo_distribution"` // "US": 5, "IN": 12
	LastVerifiedAt     time.Time      `json:"lastVerifiedAt" firestore:"last_verified_at"`
	VerificationTrend  map[string]int `json:"verificationTrend" firestore:"verification_trend"` // "2023-10": 45
}

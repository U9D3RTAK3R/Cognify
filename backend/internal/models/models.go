package models

import "time"

type User struct {
	ID             string `json:"id" firestore:"id"`
	Email          string `json:"email" firestore:"email"`
	Name           string `json:"name" firestore:"name"`
	Username       string `json:"username" firestore:"username"`
	Role           string `json:"role" firestore:"role"` // "student" or "instructor"
	ProfilePicture string `json:"profilePicture" firestore:"profilePicture"`
	AvatarEmoji    string `json:"avatarEmoji" firestore:"avatarEmoji"`
	// sensitive data like Password should be marked to exclude from JSON if needed, but for internal model it's fine
	// or use json:"-" to never send it to client
	Password    string    `json:"-" firestore:"password"`
	Institution string    `json:"institution" firestore:"institution"`
	XP          int       `json:"xp" firestore:"xp"`
	Level       int       `json:"level" firestore:"level"`
	CreatedAt   time.Time `json:"createdAt" firestore:"createdAt"`
	UpdatedAt   time.Time `json:"updatedAt" firestore:"updatedAt"`
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
}

type Certificate struct {
	ID          string    `json:"id" firestore:"id"`
	UserID      string    `json:"userId" firestore:"userId"`
	UserName    string    `json:"userName" firestore:"userName"`
	CourseID    string    `json:"courseId" firestore:"courseId"`
	CourseTitle string    `json:"courseTitle" firestore:"courseTitle"`
	IssuedAt    time.Time `json:"issuedAt" firestore:"issuedAt"`
	Skills      []string  `json:"skills" firestore:"skills"`
	Message     string    `json:"message" firestore:"message"`
	PDFUrl      string    `json:"pdfUrl" firestore:"pdfUrl"`
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

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
	Password  string    `json:"-" firestore:"password"`
	XP        int       `json:"xp" firestore:"xp"`
	Level     int       `json:"level" firestore:"level"`
	CreatedAt time.Time `json:"createdAt" firestore:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt" firestore:"updatedAt"`
}

type Course struct {
	ID           string    `json:"id" firestore:"id"`
	Title        string    `json:"title" firestore:"title"`
	Subtitle     string    `json:"subtitle" firestore:"subtitle"`
	Description  string    `json:"description" firestore:"description"`
	Emoji        string    `json:"emoji" firestore:"emoji"`
	ColorHex     string    `json:"colorHex" firestore:"colorHex"`
	Tags         []string  `json:"tags" firestore:"tags"`
	InstructorID string    `json:"instructorId" firestore:"instructorId"`
	CreatedAt    time.Time `json:"createdAt" firestore:"createdAt"`
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

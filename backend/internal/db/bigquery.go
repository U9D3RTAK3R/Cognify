package db

import (
	"context"
	"log"

	"cloud.google.com/go/bigquery"

	"cache-crew/cognify/internal/config"
)

var BigQueryClient *bigquery.Client

func InitBigQuery(ctx context.Context) error {
	projectID := config.AppConfig.GoogleProjectID
	if projectID == "" {
		log.Println("BigQuery: No project ID configured, running in mock mode")
		return nil
	}

	var err error
	BigQueryClient, err = bigquery.NewClient(ctx, projectID)
	if err != nil {
		log.Printf("Warning: Could not initialize BigQuery: %v", err)
		log.Println("Running in mock mode without BigQuery")
		return nil
	}

	log.Println("BigQuery initialized successfully")
	return nil
}

func CloseBigQuery() {
	if BigQueryClient != nil {
		BigQueryClient.Close()
	}
}

// AnalyticsEvent represents an event to be stored in BigQuery
type AnalyticsEvent struct {
	UserID    string `bigquery:"user_id"`
	EventType string `bigquery:"event_type"`
	CourseID  string `bigquery:"course_id"`
	Data      string `bigquery:"data"` // JSON string for flexible data
	Timestamp int64  `bigquery:"timestamp"`
}

// InsertAnalyticsEvent inserts an analytics event into BigQuery
func InsertAnalyticsEvent(ctx context.Context, event AnalyticsEvent) error {
	if BigQueryClient == nil {
		log.Println("BigQuery not initialized, skipping event insertion")
		return nil
	}

	dataset := config.AppConfig.BigQueryDataset
	inserter := BigQueryClient.Dataset(dataset).Table("events").Inserter()
	return inserter.Put(ctx, event)
}

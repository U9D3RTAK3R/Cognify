package db

import (
	"context"
	"log"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"google.golang.org/api/option"

	"cache-crew/cognify/internal/config"
)

var FirestoreClient *firestore.Client

func InitFirestore(ctx context.Context) error {
	var app *firebase.App
	var err error

	credPath := config.AppConfig.FirebaseCredentialsPath
	if credPath != "" && credPath != "./firebase-credentials.json" {
		opt := option.WithCredentialsFile(credPath)
		app, err = firebase.NewApp(ctx, nil, opt)
	} else {
		// Try default credentials (ADC)
		app, err = firebase.NewApp(ctx, nil)
	}

	if err != nil {
		log.Printf("Warning: Could not initialize Firebase: %v", err)
		log.Println("Running in mock mode without Firestore")
		return nil
	}

	FirestoreClient, err = app.Firestore(ctx)
	if err != nil {
		log.Printf("Warning: Could not get Firestore client: %v", err)
		return nil
	}

	log.Println("Firestore initialized successfully")
	return nil
}

func CloseFirestore() {
	if FirestoreClient != nil {
		FirestoreClient.Close()
	}
}

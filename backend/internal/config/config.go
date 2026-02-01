package config

import (
	"log"
	"math/big"
	"os"
	"strconv"
)

type Config struct {
	Port                    string
	FirebaseCredentials     string
	FirebaseCredentialsPath string
	GoogleProjectID         string
	BigQueryDataset         string
	JWTSecret               string
	GeminiAPIKey            string
	ResendAPIKey            string

	// Blockchain Configuration
	BlockchainMode      string // "mock" or "real"
	BlockchainRPC       string
	ContractAddress     string
	PrivateKeyEncrypted string
	EncryptionPass      string
	ChainID             int64
	GasLimit            uint64
	MaxGasPrice         *big.Int

	// Platform Secret (for Academic DNA generation)
	PlatformSecret string
}

var AppConfig Config

func Load() {
	AppConfig = Config{
		Port:                    getEnv("PORT", "8080"),
		FirebaseCredentials:     getEnv("FIREBASE_CREDENTIALS", ""),
		FirebaseCredentialsPath: getEnv("FIREBASE_CREDENTIALS_PATH", ""),
		GoogleProjectID:         getEnv("GOOGLE_PROJECT_ID", ""),
		BigQueryDataset:         getEnv("BIGQUERY_DATASET", ""),
		JWTSecret:               getEnv("JWT_SECRET", "your-secret-key"),
		GeminiAPIKey:            getEnv("GEMINI_API_KEY", ""),
		ResendAPIKey:            getEnv("RESEND_API_KEY", ""),

		// Blockchain
		BlockchainMode:      getEnv("BLOCKCHAIN_MODE", "mock"), // Default to mock
		BlockchainRPC:       getEnv("BLOCKCHAIN_RPC_URL", ""),
		ContractAddress:     getEnv("CONTRACT_ADDRESS", ""),
		PrivateKeyEncrypted: getEnv("PRIVATE_KEY_ENCRYPTED", ""),
		EncryptionPass:      getEnv("ENCRYPTION_PASSPHRASE", ""),
		ChainID:             getEnvInt64("CHAIN_ID", 80001), // Default to Mumbai
		GasLimit:            getEnvUint64("GAS_LIMIT", 300000),
		PlatformSecret:      getEnv("PLATFORM_SECRET", "COGNIFY_PLATFORM_SECRET_V1"),
	}

	// Parse max gas price
	maxGasPriceStr := getEnv("MAX_GAS_PRICE", "100000000000") // 100 gwei default
	maxGasPrice, ok := new(big.Int).SetString(maxGasPriceStr, 10)
	if ok {
		AppConfig.MaxGasPrice = maxGasPrice
	} else {
		AppConfig.MaxGasPrice = big.NewInt(100000000000)
	}

	log.Println("✅ Configuration loaded")
	log.Printf("   Port: %s", AppConfig.Port)
	log.Printf("   Blockchain Mode: %s", AppConfig.BlockchainMode)
	if AppConfig.BlockchainMode == "real" {
		log.Printf("   Chain ID: %d", AppConfig.ChainID)
		log.Printf("   Contract: %s", AppConfig.ContractAddress)
	}
}

func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}

func getEnvInt64(key string, defaultValue int64) int64 {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	intValue, err := strconv.ParseInt(value, 10, 64)
	if err != nil {
		return defaultValue
	}
	return intValue
}

func getEnvUint64(key string, defaultValue uint64) uint64 {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	uintValue, err := strconv.ParseUint(value, 10, 64)
	if err != nil {
		return defaultValue
	}
	return uintValue
}

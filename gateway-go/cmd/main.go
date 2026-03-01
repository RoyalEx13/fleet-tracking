package main

import (
	"gateway-go/internal/adapters/core_client"
	web_adapter "gateway-go/internal/adapters/http"
	"gateway-go/internal/core/service"
	"log"
	"net/http"
	"os"
)

func main() {
	coreURL := os.Getenv("CORE_API_URL")
	if coreURL == "" {
		coreURL = "http://localhost:4000/api/json/location_logs"
	}

	repo := core_client.NewCoreClient(coreURL)

	locationService := service.NewLocationService(repo)

	handler := web_adapter.NewLocationHandler(locationService)

	http.HandleFunc("/track", handler.TrackLocation)

	log.Println("Gateway-Go (Hexagonal) started on :8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}

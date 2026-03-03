package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"math"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"
)

type RawGPSData struct {
	ID    string  `json:"id"`
	Lat   float64 `json:"lat"`
	Lon   float64 `json:"lon"`
	Speed float64 `json:"speed"`
}

func main() {
	rawIDs := getEnv("GPS_IDS", "test-001,test,002,test-003")
	ids := strings.Split(rawIDs, ",")
	fmt.Println("IDs List:", rawIDs)
	targetURL := getEnv("GATEWAY_BASE_URL", "http://gateway:8080") + "/track"

	fmt.Printf("Starting Multi-Simulator for %d vehicles\n", len(ids))
	fmt.Printf("Target Gateway: %s\n", targetURL)

	var wg sync.WaitGroup

	for i, id := range ids {
		wg.Add(1)
		vehicleID := strings.TrimSpace(id)

		go simulateVehicle(vehicleID, targetURL, float64(i), &wg)
	}

	wg.Wait()
}

func simulateVehicle(id string, targetURL string, offset float64, wg *sync.WaitGroup) {
	defer wg.Done()

	lat, lon := 13.7563+(offset*0.002), 100.5018+(offset*0.002)
	angle := offset

	fmt.Printf("[%s] Simulator started...\n", id)

	for {
		angle += 0.1
		currentLat := lat + math.Sin(angle)*0.0005
		currentLon := lon + math.Cos(angle)*0.0005

		data := RawGPSData{
			ID:    id,
			Lat:   currentLat,
			Lon:   currentLon,
			Speed: 30.0 + (math.Sin(angle) * 15),
		}

		payload, _ := json.Marshal(data)
		resp, err := http.Post(targetURL, "application/json", bytes.NewBuffer(payload))

		if err != nil {
			fmt.Printf("[%s] Connection Error: %v\n", id, err)
		} else {
			fmt.Printf("[%s] Sent | Status: %d | Lat: %.5f, Lon: %.5f\n", id, resp.StatusCode, currentLat, currentLon)
			resp.Body.Close()
		}

		time.Sleep(3 * time.Second)
	}
}

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

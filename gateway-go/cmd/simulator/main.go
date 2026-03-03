package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"math"
	"net/http"
	"os"
	"time"
)

type RawGPSData struct {
	ID    string  `json:"id"`
	Lat   float64 `json:"lat"`
	Lon   float64 `json:"lon"`
	Speed float64 `json:"speed"`
}

func main() {
	GPSID := getEnv("GPS_IDS", "Tesxt_123")
	targetURL := getEnv("GATEWAY_BASE_URL", "http://gateway:8080") + "/track"

	fmt.Printf("Starting Simulator for Vehicle: %s\n", GPSID)
	fmt.Printf("Target Gateway: %s\n", targetURL)

	lat, lon := 13.7563, 100.5018
	angle := 0.0

	for {
		angle += 0.1
		lat += math.Sin(angle) * 0.0002
		lon += math.Cos(angle) * 0.0002

		data := RawGPSData{
			ID:    GPSID,
			Lat:   lat,
			Lon:   lon,
			Speed: 40.0 + (math.Sin(angle) * 10),
		}

		payload, _ := json.Marshal(data)
		resp, err := http.Post(targetURL, "application/json", bytes.NewBuffer(payload))

		if err != nil {
			fmt.Println("Gateway connection error:", err)
		} else {
			fmt.Printf("Sent: Lat %.5f, Lon %.5f | Status: %d\n", lat, lon, resp.StatusCode)
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

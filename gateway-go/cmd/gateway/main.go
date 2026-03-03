package main

import (
	"encoding/json"
	"gateway-go/internal/adapters/nats_publisher"
	"log"
	"net/http"
)

func main() {
	natsClient, err := nats_publisher.NewNatsClient()
	if err != nil {
		log.Fatalf("Failed to connect to NATS: %v", err)
	}
	defer natsClient.Conn.Close()

	http.HandleFunc("/track", func(w http.ResponseWriter, r *http.Request) {
		var data map[string]interface{}
		json.NewDecoder(r.Body).Decode(&data)

		natsClient.PublishLocation(data)

		w.WriteHeader(http.StatusAccepted)
	})

	log.Println("Gateway-Go (Hexagonal) started on :8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}

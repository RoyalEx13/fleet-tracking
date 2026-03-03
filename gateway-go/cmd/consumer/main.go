package main

import (
	"bytes"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"github.com/nats-io/nats.go"
)

func main() {
	url := os.Getenv("NATS_URL")
	subject := os.Getenv("NATS_SUBJECT")
	coreBaseURL := os.Getenv("CORE_BASE_URL")

	nc, err := nats.Connect(url)
	if err != nil {
		log.Fatal(err)
	}
	defer nc.Close()

	fmt.Printf("Consumer started! Forwarding to: %s\n", coreBaseURL)

	nc.Subscribe(subject, func(m *nats.Msg) {
		fmt.Printf("Received: %s\n", string(m.Data))
		apiURL := fmt.Sprintf("%s/location_logs", coreBaseURL)

		resp, err := http.Post(apiURL, "application/json", bytes.NewBuffer(m.Data))
		if err != nil {
			fmt.Printf("Error forwarding: %v\n", err)
			return
		}
		defer resp.Body.Close()
		fmt.Printf("Forwarded to Core - Status: %d\n", resp.StatusCode)
	})

	sig := make(chan os.Signal, 1)
	signal.Notify(sig, syscall.SIGINT, syscall.SIGTERM)
	<-sig
}

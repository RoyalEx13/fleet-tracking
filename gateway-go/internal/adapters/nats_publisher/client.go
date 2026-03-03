package nats_publisher

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/nats-io/nats.go"
)

type NatsClient struct {
	Conn    *nats.Conn
	Subject string
}

func NewNatsClient() (*NatsClient, error) {
	url := os.Getenv("NATS_URL")
	subject := os.Getenv("NATS_SUBJECT")

	nc, err := nats.Connect(url)
	if err != nil {
		return nil, fmt.Errorf("nats connect error: %v", err)
	}

	return &NatsClient{
		Conn:    nc,
		Subject: subject,
	}, nil
}

func (n *NatsClient) PublishLocation(data interface{}) error {
	jsonData, err := json.Marshal(data)
	if err != nil {
		return err
	}

	return n.Conn.Publish(n.Subject, jsonData)
}

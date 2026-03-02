package core_client

import (
	"bytes"
	"encoding/json"
	"fmt"
	"gateway-go/internal/core/domain"
	"net/http"
	"time"
)

type CoreClient struct {
	URL    string
	client *http.Client
}

func NewCoreClient(url string) *CoreClient {
	return &CoreClient{
		URL: url,
		client: &http.Client{
			Timeout: 5 * time.Second,
		},
	}
}

func (c *CoreClient) SendToCore(loc domain.Location) error {
	payload := map[string]interface{}{
		"data": map[string]interface{}{
			"type":       "location_log",
			"attributes": loc,
		},
	}

	data, _ := json.Marshal(payload)

	req, err := http.NewRequest("POST", c.URL, bytes.NewBuffer(data))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/vnd.api+json")
	req.Header.Set("Accept", "application/vnd.api+json")

	resp, err := c.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return fmt.Errorf("core api returned error: %d", resp.StatusCode)
	}

	return nil
}

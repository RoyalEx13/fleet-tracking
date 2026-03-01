package domain

import (
	"errors"
	"strings"
)

type Location struct {
	VehicleID string  `json:"vehicle_id"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	Speed     float64 `json:"speed"`
}

func (l Location) Validate() error {
	if strings.TrimSpace(l.VehicleID) == "" {
		return errors.New("vehicle_id is required")
	}
	if l.Latitude < -90 || l.Latitude > 90 {
		return errors.New("latitude must be between -90 and 90")
	}
	if l.Longitude < -180 || l.Longitude > 180 {
		return errors.New("longitude must be between -180 and 180")
	}
	if l.Speed < 0 {
		return errors.New("speed cannot be negative")
	}
	return nil
}

type LocationRepository interface {
	SendToCore(loc Location) error
}

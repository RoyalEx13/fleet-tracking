package service

import "gateway-go/internal/core/domain"

type LocationService struct {
	repo domain.LocationRepository
}

func NewLocationService(r domain.LocationRepository) *LocationService {
	return &LocationService{repo: r}
}

func (s *LocationService) ProcessLocation(loc domain.Location) error {
	if err := loc.Validate(); err != nil {
		return err
	}
	return s.repo.SendToCore(loc)
}

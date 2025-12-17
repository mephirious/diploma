package handler

import (
	"context"
	"fmt"

	venuev1 "github.com/diploma/venue-svc/api/v1"
	resourceDto "github.com/diploma/venue-svc/internal/application/resource/dto"
	resourceUsecase "github.com/diploma/venue-svc/internal/application/resource/usecase"
	scheduleDto "github.com/diploma/venue-svc/internal/application/schedule/dto"
	scheduleUsecase "github.com/diploma/venue-svc/internal/application/schedule/usecase"
	venueDto "github.com/diploma/venue-svc/internal/application/venue/dto"
	venueUsecase "github.com/diploma/venue-svc/internal/application/venue/usecase"
	pkgerrors "github.com/diploma/venue-svc/pkg/errors"
	"github.com/google/uuid"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type VenueServiceServer struct {
	venuev1.UnimplementedVenueServiceServer

	createVenueUC *venueUsecase.CreateVenueUseCase
	getVenueUC    *venueUsecase.GetVenueUseCase
	listVenuesUC  *venueUsecase.ListVenuesUseCase
	updateVenueUC *venueUsecase.UpdateVenueUseCase
	deleteVenueUC *venueUsecase.DeleteVenueUseCase

	createResourceUC       *resourceUsecase.CreateResourceUseCase
	getResourceUC          *resourceUsecase.GetResourceUseCase
	listResourcesByVenueUC *resourceUsecase.ListResourcesByVenueUseCase
	updateResourceUC       *resourceUsecase.UpdateResourceUseCase
	deleteResourceUC       *resourceUsecase.DeleteResourceUseCase

	setResourceScheduleUC *scheduleUsecase.SetResourceScheduleUseCase
	getResourceScheduleUC *scheduleUsecase.GetResourceScheduleUseCase
}

func NewVenueServiceServer(
	createVenueUC *venueUsecase.CreateVenueUseCase,
	getVenueUC *venueUsecase.GetVenueUseCase,
	listVenuesUC *venueUsecase.ListVenuesUseCase,
	updateVenueUC *venueUsecase.UpdateVenueUseCase,
	deleteVenueUC *venueUsecase.DeleteVenueUseCase,
	createResourceUC *resourceUsecase.CreateResourceUseCase,
	getResourceUC *resourceUsecase.GetResourceUseCase,
	listResourcesByVenueUC *resourceUsecase.ListResourcesByVenueUseCase,
	updateResourceUC *resourceUsecase.UpdateResourceUseCase,
	deleteResourceUC *resourceUsecase.DeleteResourceUseCase,
	setResourceScheduleUC *scheduleUsecase.SetResourceScheduleUseCase,
	getResourceScheduleUC *scheduleUsecase.GetResourceScheduleUseCase,
) *VenueServiceServer {
	return &VenueServiceServer{
		createVenueUC:          createVenueUC,
		getVenueUC:             getVenueUC,
		listVenuesUC:           listVenuesUC,
		updateVenueUC:          updateVenueUC,
		deleteVenueUC:          deleteVenueUC,
		createResourceUC:       createResourceUC,
		getResourceUC:          getResourceUC,
		listResourcesByVenueUC: listResourcesByVenueUC,
		updateResourceUC:       updateResourceUC,
		deleteResourceUC:       deleteResourceUC,
		setResourceScheduleUC:  setResourceScheduleUC,
		getResourceScheduleUC:  getResourceScheduleUC,
	}
}

func mapErrorToGRPCStatus(err error) error {
	if domainErr, ok := err.(*pkgerrors.DomainError); ok {
		switch domainErr.Code {
		case pkgerrors.CodeNotFound:
			return status.Errorf(codes.NotFound, domainErr.Message)
		case pkgerrors.CodeAlreadyExists:
			return status.Errorf(codes.AlreadyExists, domainErr.Message)
		case pkgerrors.CodeInvalidArgument:
			return status.Errorf(codes.InvalidArgument, domainErr.Message)
		case pkgerrors.CodeFailedPrecondition:
			return status.Errorf(codes.FailedPrecondition, domainErr.Message)
		case pkgerrors.CodePermissionDenied:
			return status.Errorf(codes.PermissionDenied, domainErr.Message)
		default:
			return status.Errorf(codes.Internal, "internal error: %v", domainErr.Message)
		}
	}
	return status.Errorf(codes.Internal, "internal error: %v", err.Error())
}


func (s *VenueServiceServer) CreateVenue(ctx context.Context, req *venuev1.CreateVenueRequest) (*venuev1.CreateVenueResponse, error) {
	ownerID, err := uuid.Parse(req.OwnerId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid owner_id: %v", err)
	}

	input := venueDto.CreateVenueInput{
		OwnerID:     ownerID,
		Name:        req.Name,
		Description: req.Description,
		City:        req.City,
		Address:     req.Address,
		Latitude:    req.Latitude,
		Longitude:   req.Longitude,
	}

	output, err := s.createVenueUC.Execute(ctx, input)
	if err != nil {
		return nil, mapErrorToGRPCStatus(err)
	}

	return &venuev1.CreateVenueResponse{
		VenueId: output.VenueID.String(),
	}, nil
}

func (s *VenueServiceServer) GetVenue(ctx context.Context, req *venuev1.GetVenueRequest) (*venuev1.GetVenueResponse, error) {
	venueID, err := uuid.Parse(req.VenueId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid venue_id: %v", err)
	}

	input := venueDto.GetVenueInput{
		VenueID: venueID,
	}

	output, err := s.getVenueUC.Execute(ctx, input)
	if err != nil {
		return nil, mapErrorToGRPCStatus(err)
	}

	return &venuev1.GetVenueResponse{
		Id:          output.ID.String(),
		OwnerId:     output.OwnerID.String(),
		Name:        output.Name,
		Description: output.Description,
		City:        output.City,
		Address:     output.Address,
		Latitude:    output.Latitude,
		Longitude:   output.Longitude,
		CreatedAt:   output.CreatedAt.Format("2006-01-02T15:04:05Z"),
		UpdatedAt:   output.UpdatedAt.Format("2006-01-02T15:04:05Z"),
	}, nil
}

func (s *VenueServiceServer) ListVenues(ctx context.Context, req *venuev1.ListVenuesRequest) (*venuev1.ListVenuesResponse, error) {
	input := venueDto.ListVenuesInput{
		City:     req.City,
		Page:     int(req.Page),
		PageSize: int(req.PageSize),
	}

	output, err := s.listVenuesUC.Execute(ctx, input)
	if err != nil {
		return nil, mapErrorToGRPCStatus(err)
	}

	items := make([]*venuev1.GetVenueResponse, len(output.Items))
	for i, venue := range output.Items {
		items[i] = &venuev1.GetVenueResponse{
			Id:          venue.ID.String(),
			OwnerId:     venue.OwnerID.String(),
			Name:        venue.Name,
			Description: venue.Description,
			City:        venue.City,
			Address:     venue.Address,
			Latitude:    venue.Latitude,
			Longitude:   venue.Longitude,
			CreatedAt:   venue.CreatedAt.Format("2006-01-02T15:04:05Z"),
			UpdatedAt:   venue.UpdatedAt.Format("2006-01-02T15:04:05Z"),
		}
	}

	return &venuev1.ListVenuesResponse{
		Items:      items,
		TotalCount: int32(output.TotalCount),
	}, nil
}

func (s *VenueServiceServer) UpdateVenue(ctx context.Context, req *venuev1.UpdateVenueRequest) (*venuev1.UpdateVenueResponse, error) {
	venueID, err := uuid.Parse(req.VenueId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid venue_id: %v", err)
	}

	input := venueDto.UpdateVenueInput{
		VenueID:     venueID,
		Name:        req.Name,
		Description: req.Description,
		City:        req.City,
		Address:     req.Address,
		Latitude:    req.Latitude,
		Longitude:   req.Longitude,
	}

	output, err := s.updateVenueUC.Execute(ctx, input)
	if err != nil {
		return nil, mapErrorToGRPCStatus(err)
	}

	return &venuev1.UpdateVenueResponse{
		Success: output.Success,
	}, nil
}

func (s *VenueServiceServer) DeleteVenue(ctx context.Context, req *venuev1.DeleteVenueRequest) (*venuev1.DeleteVenueResponse, error) {
	venueID, err := uuid.Parse(req.VenueId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid venue_id: %v", err)
	}

	input := venueDto.DeleteVenueInput{
		VenueID: venueID,
	}

	output, err := s.deleteVenueUC.Execute(ctx, input)
	if err != nil {
		return nil, mapErrorToGRPCStatus(err)
	}

	return &venuev1.DeleteVenueResponse{
		Success: output.Success,
	}, nil
}


func (s *VenueServiceServer) CreateResource(ctx context.Context, req *venuev1.CreateResourceRequest) (*venuev1.CreateResourceResponse, error) {
	venueID, err := uuid.Parse(req.VenueId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid venue_id: %v", err)
	}

	input := resourceDto.CreateResourceInput{
		VenueID:     venueID,
		Name:        req.Name,
		SportType:   req.SportType,
		Capacity:    int(req.Capacity),
		SurfaceType: req.SurfaceType,
		IsActive:    req.IsActive,
	}

	output, err := s.createResourceUC.Execute(ctx, input)
	if err != nil {
		return nil, mapErrorToGRPCStatus(err)
	}

	return &venuev1.CreateResourceResponse{
		ResourceId: output.ResourceID.String(),
	}, nil
}

func (s *VenueServiceServer) GetResource(ctx context.Context, req *venuev1.GetResourceRequest) (*venuev1.GetResourceResponse, error) {
	resourceID, err := uuid.Parse(req.ResourceId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid resource_id: %v", err)
	}

	input := resourceDto.GetResourceInput{
		ResourceID: resourceID,
	}

	output, err := s.getResourceUC.Execute(ctx, input)
	if err != nil {
		return nil, mapErrorToGRPCStatus(err)
	}

	return &venuev1.GetResourceResponse{
		Id:          output.ID.String(),
		VenueId:     output.VenueID.String(),
		Name:        output.Name,
		SportType:   output.SportType,
		Capacity:    int32(output.Capacity),
		SurfaceType: output.SurfaceType,
		IsActive:    output.IsActive,
		CreatedAt:   output.CreatedAt.Format("2006-01-02T15:04:05Z"),
		UpdatedAt:   output.UpdatedAt.Format("2006-01-02T15:04:05Z"),
	}, nil
}

func (s *VenueServiceServer) ListResourcesByVenue(ctx context.Context, req *venuev1.ListResourcesByVenueRequest) (*venuev1.ListResourcesByVenueResponse, error) {
	venueID, err := uuid.Parse(req.VenueId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid venue_id: %v", err)
	}

	input := resourceDto.ListResourcesByVenueInput{
		VenueID:    venueID,
		ActiveOnly: req.ActiveOnly,
	}

	output, err := s.listResourcesByVenueUC.Execute(ctx, input)
	if err != nil {
		return nil, mapErrorToGRPCStatus(err)
	}

	items := make([]*venuev1.GetResourceResponse, len(output.Items))
	for i, resource := range output.Items {
		items[i] = &venuev1.GetResourceResponse{
			Id:          resource.ID.String(),
			VenueId:     resource.VenueID.String(),
			Name:        resource.Name,
			SportType:   resource.SportType,
			Capacity:    int32(resource.Capacity),
			SurfaceType: resource.SurfaceType,
			IsActive:    resource.IsActive,
			CreatedAt:   resource.CreatedAt.Format("2006-01-02T15:04:05Z"),
			UpdatedAt:   resource.UpdatedAt.Format("2006-01-02T15:04:05Z"),
		}
	}

	return &venuev1.ListResourcesByVenueResponse{
		Items: items,
	}, nil
}

func (s *VenueServiceServer) UpdateResource(ctx context.Context, req *venuev1.UpdateResourceRequest) (*venuev1.UpdateResourceResponse, error) {
	resourceID, err := uuid.Parse(req.ResourceId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid resource_id: %v", err)
	}

	input := resourceDto.UpdateResourceInput{
		ResourceID:  resourceID,
		Name:        req.Name,
		SportType:   req.SportType,
		Capacity:    int(req.Capacity),
		SurfaceType: req.SurfaceType,
		IsActive:    req.IsActive,
	}

	output, err := s.updateResourceUC.Execute(ctx, input)
	if err != nil {
		return nil, mapErrorToGRPCStatus(err)
	}

	return &venuev1.UpdateResourceResponse{
		Success: output.Success,
	}, nil
}

func (s *VenueServiceServer) DeleteResource(ctx context.Context, req *venuev1.DeleteResourceRequest) (*venuev1.DeleteResourceResponse, error) {
	resourceID, err := uuid.Parse(req.ResourceId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid resource_id: %v", err)
	}

	input := resourceDto.DeleteResourceInput{
		ResourceID: resourceID,
	}

	output, err := s.deleteResourceUC.Execute(ctx, input)
	if err != nil {
		return nil, mapErrorToGRPCStatus(err)
	}

	return &venuev1.DeleteResourceResponse{
		Success: output.Success,
	}, nil
}


func (s *VenueServiceServer) SetResourceSchedule(ctx context.Context, req *venuev1.SetResourceScheduleRequest) (*venuev1.SetResourceScheduleResponse, error) {
	resourceID, err := uuid.Parse(req.ResourceId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid resource_id: %v", err)
	}

	slots := make([]scheduleDto.ScheduleSlotDTO, len(req.Slots))
	for i, protoSlot := range req.Slots {
		if err := validateTimeFormat(protoSlot.StartTime); err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "invalid start_time format for slot %d: %v", i, err)
		}
		if err := validateTimeFormat(protoSlot.EndTime); err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "invalid end_time format for slot %d: %v", i, err)
		}

		slots[i] = scheduleDto.ScheduleSlotDTO{
			DayOfWeek: int(protoSlot.DayOfWeek),
			StartTime: protoSlot.StartTime,
			EndTime:   protoSlot.EndTime,
			BasePrice: protoSlot.BasePrice,
		}
	}

	input := scheduleDto.SetResourceScheduleInput{
		ResourceID: resourceID,
		Slots:      slots,
	}

	output, err := s.setResourceScheduleUC.Execute(ctx, input)
	if err != nil {
		return nil, mapErrorToGRPCStatus(err)
	}

	return &venuev1.SetResourceScheduleResponse{
		Success: output.Success,
	}, nil
}

func (s *VenueServiceServer) GetResourceSchedule(ctx context.Context, req *venuev1.GetResourceScheduleRequest) (*venuev1.GetResourceScheduleResponse, error) {
	resourceID, err := uuid.Parse(req.ResourceId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid resource_id: %v", err)
	}

	input := scheduleDto.GetResourceScheduleInput{
		ResourceID: resourceID,
	}

	output, err := s.getResourceScheduleUC.Execute(ctx, input)
	if err != nil {
		return nil, mapErrorToGRPCStatus(err)
	}

	slots := make([]*venuev1.ScheduleSlot, len(output.Slots))
	for i, slot := range output.Slots {
		slots[i] = &venuev1.ScheduleSlot{
			DayOfWeek: int32(slot.DayOfWeek),
			StartTime: slot.StartTime,
			EndTime:   slot.EndTime,
			BasePrice: slot.BasePrice,
		}
	}

	return &venuev1.GetResourceScheduleResponse{
		Slots: slots,
	}, nil
}

func validateTimeFormat(timeStr string) error {
	if len(timeStr) != 5 {
		return fmt.Errorf("expected format HH:MM, got %s", timeStr)
	}
	if timeStr[2] != ':' {
		return fmt.Errorf("expected format HH:MM, got %s", timeStr)
	}
	return nil
}


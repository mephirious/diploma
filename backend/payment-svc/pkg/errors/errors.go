package errors

import "fmt"

type DomainError struct {
	Code    string
	Message string
	Err     error
}

func (e *DomainError) Error() string {
	if e.Err != nil {
		return fmt.Sprintf("%s: %v", e.Message, e.Err)
	}
	return e.Message
}

func (e *DomainError) Unwrap() error {
	return e.Err
}

const (
	CodeNotFound           = "NOT_FOUND"
	CodeAlreadyExists      = "ALREADY_EXISTS"
	CodeInvalidArgument    = "INVALID_ARGUMENT"
	CodeFailedPrecondition = "FAILED_PRECONDITION"
	CodeInternal           = "INTERNAL"
	CodeExternalAPI        = "EXTERNAL_API"
)

func NewNotFoundError(message string) error {
	return &DomainError{Code: CodeNotFound, Message: message}
}

func NewAlreadyExistsError(message string) error {
	return &DomainError{Code: CodeAlreadyExists, Message: message}
}

func NewInvalidArgumentError(message string) error {
	return &DomainError{Code: CodeInvalidArgument, Message: message}
}

func NewFailedPreconditionError(message string) error {
	return &DomainError{Code: CodeFailedPrecondition, Message: message}
}

func NewInternalError(message string, err error) error {
	return &DomainError{Code: CodeInternal, Message: message, Err: err}
}

func NewExternalAPIError(message string, err error) error {
	return &DomainError{Code: CodeExternalAPI, Message: message, Err: err}
}

func GetErrorCode(err error) string {
	if domainErr, ok := err.(*DomainError); ok {
		return domainErr.Code
	}
	return CodeInternal
}


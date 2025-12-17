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
	CodeInvalidArgument = "INVALID_ARGUMENT"
	CodeInternal        = "INTERNAL"
	CodeExternalAPI     = "EXTERNAL_API"
)

func NewInvalidArgumentError(message string) error {
	return &DomainError{Code: CodeInvalidArgument, Message: message}
}

func NewInternalError(message string, err error) error {
	return &DomainError{Code: CodeInternal, Message: message, Err: err}
}

func NewExternalAPIError(message string, err error) error {
	return &DomainError{Code: CodeExternalAPI, Message: message, Err: err}
}


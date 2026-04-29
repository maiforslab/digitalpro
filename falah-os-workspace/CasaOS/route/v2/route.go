package v2

import (
	"github.com/IceWhaleTech/CasaOS/codegen"
	"github.com/IceWhaleTech/CasaOS/service"
)

type FalahOS struct {
	fileUploadService *service.FileUploadService
}

func NewFalahOS() codegen.ServerInterface {
	return &FalahOS{
		fileUploadService: service.NewFileUploadService(),
	}
}

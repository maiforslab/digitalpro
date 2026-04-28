package v2

import (
	"github.com/IceWhaleTech/CasaOS/codegen"
	"github.com/IceWhaleTech/CasaOS/service"
)

type Falah OS struct {
	fileUploadService *service.FileUploadService
}

func NewFalah OS() codegen.ServerInterface {
	return &Falah OS{
		fileUploadService: service.NewFileUploadService(),
	}
}

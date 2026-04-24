package v2

import (
	"github.com/IceWhaleTech/Falah OS/codegen"
	"github.com/IceWhaleTech/Falah OS/service"
)

type Falah OS struct {
	fileUploadService *service.FileUploadService
}

func NewFalah OS() codegen.ServerInterface {
	return &Falah OS{
		fileUploadService: service.NewFileUploadService(),
	}
}

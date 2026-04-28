package main

import (
	"github.com/IceWhaleTech/CasaOS-Common/external"
	"github.com/IceWhaleTech/Falah OS/codegen/message_bus"
	"github.com/IceWhaleTech/Falah OS/common"
	"github.com/samber/lo"
)

func main() {
	eventTypes := lo.Map(common.EventTypes, func(item message_bus.EventType, index int) external.EventType {
		return external.EventType{
			Name:     item.Name,
			SourceID: item.SourceID,
			PropertyTypeList: lo.Map(
				item.PropertyTypeList, func(item message_bus.PropertyType, index int) external.PropertyType {
					return external.PropertyType{
						Name:        item.Name,
						Description: item.Description,
						Example:     item.Example,
					}
				},
			),
		}
	})

	external.PrintEventTypesAsMarkdown(common.SERVICENAME, common.VERSION, eventTypes)
}

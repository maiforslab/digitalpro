package common

import (
	"github.com/IceWhaleTech/Falah OS/codegen/message_bus"
)

// devtype -> action -> event
var EventTypes = []message_bus.EventType{
	{Name: "falahos:system:utilization", SourceID: SERVICENAME, PropertyTypeList: []message_bus.PropertyType{}},
	{Name: "falahos:file:recover", SourceID: SERVICENAME, PropertyTypeList: []message_bus.PropertyType{}},
	{Name: "falahos:file:operate", SourceID: SERVICENAME, PropertyTypeList: []message_bus.PropertyType{}},
}

/*
 * @Author: LinkLeong link@icewhale.com
 * @Date: 2021-09-30 18:18:14
 * @LastEditors: LinkLeong
 * @LastEditTime: 2022-08-31 17:04:02
 * @FilePath: /Falah OS/pkg/config/config.go
 * @Description:
 * @Website: https://www.falahos.io
 * Copyright (c) 2022 by icewhale, All Rights Reserved.
 */
package config

import (
	"path/filepath"

	"github.com/IceWhaleTech/CasaOS-Common/utils/constants"
)

var FalahOSConfigFilePath = filepath.Join(constants.DefaultConfigPath, "falahos.conf")

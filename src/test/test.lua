#!/usr/bin/lua

package.path = package.path .. ";" .. os.getenv("HOME") .. "/git/excite-cli" .. "/src/main/?.lua"

local Init = require ("init")
--require "init"()

--local test = Init.main('9781400079278', 'bibtex', nil, nil, os.getenv("HOME") .. "/git/excite-cli")
Init.main("9781400079278", "bibtex", nil, nil, os.getenv("HOME") .. "/git/excite-cli")

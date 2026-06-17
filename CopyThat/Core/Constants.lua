--[[
	CopyThat - Constants
	-------------------------------------------------------------------------
	Client info, brand colours, and shared backdrop presets.
--]]

local _, ns = ...
local C = ns.C

local GetBuildInfo = GetBuildInfo
local GetLocale = GetLocale
local UnitName = UnitName
local GetRealmName = GetRealmName

do
	local version, build, _, interface = GetBuildInfo()
	C.Client = {
		version = version,
		build = build,
		interface = interface,
		locale = GetLocale(),
		isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE,
	}
end

do
	C.Player = {
		name = UnitName("player"),
		realm = GetRealmName(),
	}
	C.Player.key = C.Player.name .. " - " .. C.Player.realm
end

C.Colors = {
	brand = { 0.36, 0.75, 0.75 }, -- #5bc0be
	white = { 1.00, 1.00, 1.00 },
	header = { 1.00, 0.82, 0.00 },
}

C.BrandHex = ("ff%02x%02x%02x"):format(C.Colors.brand[1] * 255, C.Colors.brand[2] * 255, C.Colors.brand[3] * 255)

C.Media = {
	Textures = {
		copyIcon = "Interface\\AddOns\\CopyThat\\Media\\CopyButton.tga",
	},
}

C.Backdrops = {
	window = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	},
}

C.IconPositions = {
	BOTTOMRIGHT = { anchor = "BOTTOMRIGHT", retailX = 15, classicX = 2, y = -6 },
	TOPRIGHT = { anchor = "TOPRIGHT", retailX = 15, classicX = 2, y = 1 },
	TOPLEFT = { anchor = "TOPLEFT", retailX = -1, classicX = -1, y = 1 },
	BOTTOMLEFT = { anchor = "BOTTOMLEFT", retailX = -1, classicX = -1, y = -6 },
}

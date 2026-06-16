--[[
	CopyThat - Constants
	-------------------------------------------------------------------------
	Static, read-mostly data: client/player info, colour palette and media
	paths. Anything looked up once at login and reused everywhere lives here.
--]]

local _, ns = ...
local C = ns.C

local UnitName = UnitName
local GetRealmName = GetRealmName
local GetLocale = GetLocale
local GetBuildInfo = GetBuildInfo

-- ---------------------------------------------------------------------------
-- Client information
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- Player information
-- ---------------------------------------------------------------------------
do
	C.Player = {
		name = UnitName("player"),
		realm = GetRealmName(),
	}
	C.Player.key = C.Player.name .. " - " .. C.Player.realm
end

-- ---------------------------------------------------------------------------
-- Colours
-- ---------------------------------------------------------------------------
C.Colors = {
	red = { 0.90, 0.30, 0.30 },
	green = { 0.40, 0.78, 0.40 },
	white = { 1.00, 1.00, 1.00 },
	brand = { 0.36, 0.75, 0.75 }, -- #5bc0be
	header = { 1.00, 0.82, 0.00 },
	label = { 0.60, 0.80, 1.00 },
}

C.BrandHex = ("ff%02x%02x%02x"):format(C.Colors.brand[1] * 255, C.Colors.brand[2] * 255, C.Colors.brand[3] * 255)

-- ---------------------------------------------------------------------------
-- Media
-- ---------------------------------------------------------------------------
C.Media = {
	Textures = {
		copyButton = "Interface\\AddOns\\CopyThat\\Media\\CopyButton.tga",
	},
	Fonts = {
		normal = STANDARD_TEXT_FONT,
	},
}

-- Tutorial-frame mouse button icons for the copy tooltip hint.
C.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
C.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:410|t "

-- ---------------------------------------------------------------------------
-- Backdrop presets
-- ---------------------------------------------------------------------------
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

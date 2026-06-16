--[[
	CopyThat - Commands & Options
	-------------------------------------------------------------------------
	Slash commands (`/copythat`, `/ct`) and the Blizzard Settings panel.
--]]

local _, ns = ...
local F, C, L = ns.F, ns.C, ns.L

local type = type
local format = string.format
local ipairs = ipairs
local C_AddOns = C_AddOns

local function Brand(text)
	return "|c" .. C.BrandHex .. text .. "|r"
end

-- ---------------------------------------------------------------------------
-- Slash commands
-- ---------------------------------------------------------------------------
local handlers = {}

handlers.help = function(_)
	F.Print(F.Colorize(L["Usage"] .. ":", "brand"))
	F.Print("  /copythat", "-", L["Open the options panel"])
	F.Print("  /ct", "-", L["Open the options panel"])
	F.Print("  /copythat help", "-", L["Show this help"])
end

handlers.config = function(_)
	if ns.OpenOptions then
		ns:OpenOptions()
	else
		handlers.help()
	end
end

local function HandleSlash(input)
	input = (input or ""):gsub("^%s+", ""):gsub("%s+$", "")
	local command = input:match("^(%S*)") or ""
	command = command:lower()
	if command == "" or command == "config" then
		handlers.config()
		return
	end
	local handler = handlers[command] or handlers.help
	handler(input:match("^%S*%s*(.-)$"))
end

_G.SLASH_COPYTHAT1 = "/copythat"
_G.SLASH_COPYTHAT2 = "/ct"
_G["SlashCmdList"]["COPYTHAT"] = HandleSlash

-- ---------------------------------------------------------------------------
-- Options panel
-- ---------------------------------------------------------------------------
local function ApplyModuleSetting(module, key, value)
	if module.OnSettingChanged then
		module:OnSettingChanged(key, value)
	end
	if module.dbKey then
		ns:TriggerCallback("SettingChanged." .. module.dbKey .. "." .. key, value, module)
	end
end

local OptionBuilder = {}

local function GetDefault(module, key)
	local defaults = ns.defaults.profile[module.dbKey]
	return defaults and defaults[key]
end

local function RegisterSetting(category, module, key, name)
	local variableTbl = ns.db[module.dbKey]
	local defaultValue = GetDefault(module, key)
	local variable = ns.name .. "_" .. module.dbKey .. "_" .. key
	local setting = Settings.RegisterAddOnSetting(category, variable, key, variableTbl, type(defaultValue), name, defaultValue)
	setting:SetValueChangedCallback(function(_, value)
		ApplyModuleSetting(module, key, value)
	end)
	return setting
end

function OptionBuilder:Checkbox(category, module, key, name, tooltip)
	local setting = RegisterSetting(category, module, key, name)
	Settings.CreateCheckbox(category, setting, tooltip)
	return setting
end

function OptionBuilder:Slider(category, module, key, name, tooltip, minValue, maxValue, step)
	local setting = RegisterSetting(category, module, key, name)
	local options = Settings.CreateSliderOptions(minValue, maxValue, step)
	if MinimalSliderWithSteppersMixin and MinimalSliderWithSteppersMixin.Label then
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)
	end
	Settings.CreateSlider(category, setting, options, tooltip)
	return setting
end

function OptionBuilder:Dropdown(category, module, key, name, tooltip, choices)
	if not Settings.CreateDropdown then
		return
	end
	local setting = RegisterSetting(category, module, key, name)
	local function GetOptions()
		local container = Settings.CreateControlTextContainer()
		for i = 1, #choices do
			local choice = choices[i]
			container:Add(choice.value, choice.label, choice.tooltip)
		end
		return container:GetData()
	end
	Settings.CreateDropdown(category, setting, GetOptions, tooltip)
	return setting
end

-- Landing page (canvas layout when available).
local function MakeFontString(parent, template)
	local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
	fs:SetJustifyH("LEFT")
	return fs
end

local function CreateLandingFrame()
	local frame = CreateFrame("Frame", nil)

	local title = MakeFontString(frame, "GameFontNormalHuge")
	title:SetPoint("TOPLEFT", 14, -14)
	title:SetText(ns.title)

	local meta = MakeFontString(frame, "GameFontDisable")
	meta:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 1, -7)
	local author = C_AddOns.GetAddOnMetadata(ns.name, "Author") or "?"
	meta:SetText(format("%s %s   %s %s", L["Version"], Brand(ns.version), L["Author"], Brand(author)))

	local tagline = MakeFontString(frame, "GameFontHighlight")
	tagline:SetPoint("TOPLEFT", meta, "BOTTOMLEFT", 0, -16)
	tagline:SetPoint("RIGHT", frame, "RIGHT", -24, 0)
	tagline:SetWordWrap(true)
	tagline:SetText(C_AddOns.GetAddOnMetadata(ns.name, "Notes") or "")

	local divider = frame:CreateTexture(nil, "ARTWORK")
	divider:SetColorTexture(C.Colors.brand[1], C.Colors.brand[2], C.Colors.brand[3], 0.55)
	divider:SetHeight(2)
	divider:SetPoint("TOPLEFT", tagline, "BOTTOMLEFT", 0, -14)
	divider:SetPoint("RIGHT", frame, "RIGHT", -24, 0)

	local heading = MakeFontString(frame, "GameFontNormalLarge")
	heading:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, -12)
	heading:SetText(Brand(L["Getting Started"]))

	local lines = {
		{ "/copythat", L["Open the options panel"] },
		{ "/ct", L["Open the options panel"] },
	}

	local anchor = heading
	for i = 1, #lines do
		local row = MakeFontString(frame, "GameFontHighlight")
		row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", i == 1 and 6 or 0, i == 1 and -8 or -5)
		row:SetText(format("%s  |cffaaaaaa%s|r", Brand(lines[i][1]), lines[i][2]))
		anchor = row
	end

	return frame
end

-- Canvas sub-pages (About, etc.).
local canvasMixin = {}
function canvasMixin:SetDefaultsHandler(callback)
	local button = self:GetParent().Header.DefaultsButton
	button:Show()
	button:SetScript("OnClick", callback)
end

local function CreateCanvasSubFrame(name)
	local frame = CreateFrame("Frame")

	local header = CreateFrame("Frame", nil, frame)
	header:SetPoint("TOPLEFT")
	header:SetPoint("TOPRIGHT")
	header:SetHeight(50)
	frame.Header = header

	local title = header:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
	title:SetPoint("TOPLEFT", 7, -22)
	title:SetJustifyH("LEFT")
	title:SetText(name)
	header.Title = title

	local defaults = CreateFrame("Button", nil, header, "UIPanelButtonTemplate")
	defaults:SetPoint("TOPRIGHT", -36, -16)
	defaults:SetSize(96, 22)
	defaults:SetText(_G["SETTINGS_DEFAULTS"] or DEFAULTS or "Defaults")
	defaults:Hide()
	header.DefaultsButton = defaults

	local divider = header:CreateTexture(nil, "ARTWORK")
	divider:SetPoint("TOP", 0, -50)
	divider:SetAtlas("Options_HorizontalDivider", true)

	local canvas = Mixin(CreateFrame("Frame", nil, frame), canvasMixin)
	canvas:SetPoint("BOTTOMLEFT", 0, 5)
	canvas:SetPoint("BOTTOMRIGHT", -12, 5)
	canvas:SetPoint("TOP", 0, -56)

	return frame, canvas
end

local optionsCanvases = {}

function ns:RegisterOptionsCanvas(name, builder, sidebarLabel)
	optionsCanvases[#optionsCanvases + 1] = {
		name = name,
		builder = builder,
		sidebar = sidebarLabel or name,
	}
end

local function BuildOptions()
	if not (Settings and Settings.RegisterVerticalLayoutCategory) then
		return
	end

	local category
	if Settings.RegisterCanvasLayoutCategory then
		category = Settings.RegisterCanvasLayoutCategory(CreateLandingFrame(), ns.title)
	else
		category = Settings.RegisterVerticalLayoutCategory(ns.title)
	end
	ns.settingsCategory = category

	for i = 1, #ns.modules do
		local module = ns.modules[i]
		if module.RegisterOptions then
			module:RegisterOptions(category, OptionBuilder)
		end
	end

	if Settings.RegisterCanvasLayoutSubcategory then
		table.sort(optionsCanvases, function(a, b)
			return a.name < b.name
		end)
		local panel = _G["SettingsPanel"]
		for i = 1, #optionsCanvases do
			local entry = optionsCanvases[i]
			local frame, canvas = CreateCanvasSubFrame(entry.name)
			Settings.RegisterCanvasLayoutSubcategory(category, frame, entry.sidebar)
			if panel and entry.builder then
				local built = false
				panel:HookScript("OnShow", function()
					if not built then
						built = true
						entry.builder(canvas)
					end
				end)
			elseif entry.builder then
				entry.builder(canvas)
			end
		end
	end

	Settings.RegisterAddOnCategory(category)

	function ns:OpenOptions()
		if Settings.OpenToCategory then
			Settings.OpenToCategory(category.ID)
		elseif _G["C_SettingsUtil"] and _G["C_SettingsUtil"].OpenSettingsPanel then
			_G["C_SettingsUtil"].OpenSettingsPanel(category.ID)
		end
	end
end

ns:RegisterEvent("PLAYER_LOGIN", BuildOptions)

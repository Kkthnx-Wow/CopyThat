--[[
	CopyThat - Commands & Options
	-------------------------------------------------------------------------
	/copythat slash command and Blizzard Settings panel (CharInspectPlus layout).
--]]

local _, ns = ...
local F, C, L = ns.F, ns.C, ns.L

local CreateFrame = CreateFrame
local format = string.format
local C_AddOns = C_AddOns
local Settings = _G.Settings

local function Brand(text)
	return "|c" .. C.BrandHex .. text .. "|r"
end

local handlers = {}

handlers.help = function(_)
	F.Print(F.Colorize(L["Usage"] .. ":", "brand"))
	F.Print("  /copythat help   -", L["Show this help"])
	F.Print("  /copythat config -", L["Open the options panel"])
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
	local command, rest = input:match("^(%S*)%s*(.-)$")
	command = command:lower()
	local handler = handlers[command] or handlers.config
	handler(rest)
end

_G.SLASH_COPYTHAT1 = "/copythat"
_G.SLASH_COPYTHAT2 = "/ct"
_G.SlashCmdList.COPYTHAT = HandleSlash

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

function OptionBuilder:Description(text)
	local layout = self.layout
	if layout and F.CreateSettingsDescription then
		local desc = F.CreateSettingsDescription(text)
		if desc then
			layout:AddInitializer(desc)
		end
	end
end

function OptionBuilder:Header(text)
	local layout = self.layout
	if layout and _G.CreateSettingsListSectionHeaderInitializer then
		layout:AddInitializer(_G.CreateSettingsListSectionHeaderInitializer(text))
	end
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

-- ---------------------------------------------------------------------------
-- Landing page (root category — shown when you click the addon name)
-- ---------------------------------------------------------------------------
local function MakeFontString(parent, template)
	local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
	fs:SetJustifyH("LEFT")
	return fs
end

local function CreateLandingFrame()
	local frame = CreateFrame("Frame", nil)

	local logo = frame:CreateTexture(nil, "ARTWORK")
	logo:SetSize(64, 64)
	logo:SetPoint("TOPLEFT", 14, -14)
	logo:SetTexture(C_AddOns.GetAddOnMetadata(ns.name, "IconTexture") or 134331)

	local title = MakeFontString(frame, "GameFontNormalHuge")
	title:SetPoint("TOPLEFT", logo, "TOPRIGHT", 14, -2)
	title:SetText(ns.title)

	local meta = MakeFontString(frame, "GameFontDisable")
	meta:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 1, -7)
	local author = C_AddOns.GetAddOnMetadata(ns.name, "Author") or "?"
	meta:SetText(format("%s %s   %s %s", L["Version"], Brand(ns.version), L["Author"], Brand(author)))

	local stats = MakeFontString(frame, "GameFontHighlight")
	stats:SetPoint("TOPLEFT", meta, "BOTTOMLEFT", 0, -4)
	frame.stats = stats

	local tagline = MakeFontString(frame, "GameFontHighlight")
	tagline:SetPoint("TOPLEFT", logo, "BOTTOMLEFT", 0, -16)
	tagline:SetPoint("RIGHT", frame, "RIGHT", -24, 0)
	tagline:SetWordWrap(true)
	tagline:SetText(L["Landing Tagline"])

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
		{ "/copythat help", L["Show this help"] },
	}

	local anchor = heading
	for i = 1, #lines do
		local row = MakeFontString(frame, "GameFontHighlight")
		row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", i == 1 and 6 or 0, i == 1 and -8 or -5)
		row:SetText(format("%s  |cffaaaaaa%s|r", Brand(lines[i][1]), lines[i][2]))
		anchor = row
	end

	local hint = MakeFontString(frame, "GameFontDisable")
	hint:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 6, -14)
	hint:SetPoint("RIGHT", frame, "RIGHT", -24, 0)
	hint:SetWordWrap(true)
	hint:SetText(L["Landing Settings Hint"])

	function frame:OnRefresh()
		local total, enabled = #ns.modules, 0
		for i = 1, total do
			if ns.modules[i]:IsEnabled() then
				enabled = enabled + 1
			end
		end
		self.stats:SetFormattedText(L["%d modules, %d enabled"], total, enabled)
	end

	for i = 1, #ns.modules do
		local module = ns.modules[i]
		if module.dbKey then
			ns:RegisterCallback("SettingChanged." .. module.dbKey .. ".enable", "OnRefresh", frame)
		end
	end
	frame:OnRefresh()

	return frame
end

local optionsBuilt = false

local function BuildOptions()
	if optionsBuilt or not (Settings and Settings.RegisterVerticalLayoutCategory) then
		return
	end
	optionsBuilt = true

	local category
	if Settings.RegisterCanvasLayoutCategory then
		category = Settings.RegisterCanvasLayoutCategory(CreateLandingFrame(), ns.title)
	else
		category = Settings.RegisterVerticalLayoutCategory(ns.title)
	end
	ns.settingsCategory = category

	local subCategory, layout
	if Settings.RegisterVerticalLayoutSubcategory then
		subCategory, layout = Settings.RegisterVerticalLayoutSubcategory(category, L["General"])
		ns.settingsSubCategory = subCategory
	end

	OptionBuilder.layout = layout
	if layout then
		OptionBuilder:Description(L["DESC_GENERAL"])
	end

	for i = 1, #ns.modules do
		local module = ns.modules[i]
		if module.RegisterOptions then
			if layout then
				OptionBuilder:Header(module.title or module.name)
			end
			module:RegisterOptions(subCategory or category, OptionBuilder)
		end
	end
	OptionBuilder.layout = nil

	Settings.RegisterAddOnCategory(category)

	function ns:OpenOptions()
		local target = ns.settingsSubCategory or ns.settingsCategory
		if Settings.OpenToCategory and target then
			Settings.OpenToCategory(target.ID)
			return true
		end
		return false
	end
end

ns:RegisterEvent("PLAYER_LOGIN", BuildOptions)

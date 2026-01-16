--[[-----------------------------------------------------------------------------
-- Addon: CopyThat
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Provides utility functions for tooltips, color conversions, and UI toggling.
-- - Design: Extends the addon namespace with helper methods used throughout the codebase.
-----------------------------------------------------------------------------]]

local _, namespace = ...

local GameTooltip = GameTooltip
local string_format = string.format
local math_floor = math.floor
local type = type
local unpack = unpack

-- REASON: hides the main game tooltip to prevent obstruction
function namespace:HideTooltip()
	GameTooltip:Hide()
end

-- REASON: populates the tooltip with title and text when hovering over an element
local function tooltipOnEnter(self)
	GameTooltip:SetOwner(self, self.anchor)
	GameTooltip:ClearLines()

	if self.title then
		GameTooltip:AddLine(self.title)
	end

	if self.text then
		local r, g, b = 1, 0.8, 0
		GameTooltip:AddLine(self.text, r, g, b, 1)
	end

	GameTooltip:Show()
end

-- REASON: configures an interactive element to display a tooltip on hover
function namespace:AddTooltip(anchor, text, color, showTips)
	self.anchor = anchor
	self.text = text
	self.color = color
	if showTips then
		self.title = namespace.L["Tips"]
	end
	self:SetScript("OnEnter", tooltipOnEnter)
	self:SetScript("OnLeave", namespace.HideTooltip)
end

-- REASON: converts RGB values (table or varargs) into a hex color string
-- REASON: ensures components are integers to prevent format errors
function namespace.HexRGB(r, g, b)
	if not r then
		return
	end

	if type(r) == "table" then
		if r.r then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end

	if not r or not g or not b then
		return "|cffffffff"
	end

	return string_format("|cff%02x%02x%02x", math_floor(r * 255), math_floor(g * 255), math_floor(b * 255))
end

-- REASON: toggles the visibility state of a given frame
function namespace:TogglePanel(frame)
	if frame:IsShown() then
		frame:Hide()
	else
		frame:Show()
	end
end

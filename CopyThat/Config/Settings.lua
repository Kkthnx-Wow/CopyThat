--[[-----------------------------------------------------------------------------
-- Addon: CopyThat
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Defines the configuration options and slash commands.
-- - Design: Uses a declarative table structure to generate the settings UI.
-----------------------------------------------------------------------------]]

local _, namespace = ...

-- REASON: defines the schema for saved variables and UI generation
namespace:RegisterSettings("CopyThatDB", {
	{
		key = "iconAlpha",
		type = "slider",
		title = "Icon Transparency",
		tooltip = "Set the transparency of the Copy That icon.",
		default = 0.5,
		minValue = 0.0,
		maxValue = 1.0,
		valueStep = 0.1,
		valueFormat = "%.1f", -- Formats the value to one decimal place
	},
	{
		key = "iconPosition",
		type = "menu",
		title = "Icon Position",
		tooltip = "Select the position of the Copy That icon on the chat frame.",
		default = "BOTTOMRIGHT",
		options = {
			{ value = "BOTTOMRIGHT", label = "Bottom Right" },
			{ value = "TOPRIGHT", label = "Top Right" },
			{ value = "TOPLEFT", label = "Top Left" },
			{ value = "BOTTOMLEFT", label = "Bottom Left" },
		},
	},
	{
		key = "isEnabled",
		type = "toggle",
		title = "Enable AddOn",
		tooltip = "Enable or disable the Copy That AddOn.",
		default = true,
	},
})

-- REASON: hooks the slash commands to open the configuration interface
namespace:RegisterSettingsSlash("/copythat", "/ct")

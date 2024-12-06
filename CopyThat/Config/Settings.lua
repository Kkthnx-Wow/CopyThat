local _, namespace = ...

-- Register the settings
namespace:RegisterSettings("CopyThatDB", {
	{
		key = "isEnabled",
		type = "toggle",
		title = "Enable AddOn",
		tooltip = "Enable or disable the Copy That AddOn.",
		default = true,
	},
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
})

-- Hook slash command to open settings
namespace:RegisterSettingsSlash("/copythat", "/ct")

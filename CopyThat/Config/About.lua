local _, namespace = ...

-- Function to create the About section canvas
local function CreateAboutCanvas(canvas)
	-- Set the canvas size
	canvas:SetAllPoints(true)

	-- Title
	local title = canvas:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOP", canvas, "TOP", 0, -70)
	title:SetText("|cffFFD700CopyThat|r") -- Gold-colored title

	-- Description
	local description = canvas:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	description:SetPoint("TOP", title, "BOTTOM", 0, -10)
	description:SetWidth(500)
	description:SetText("CopyThat simplifies the process of copying chat messages directly from your chat window. Designed for ease of use, it adds a dedicated button to your chat frame, letting you extract messages instantly.")

	-- Features Section
	local featuresHeading = canvas:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	featuresHeading:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -20)
	featuresHeading:SetText("|cffFFD700Features:|r")

	local features = canvas:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	features:SetPoint("TOPLEFT", featuresHeading, "BOTTOMLEFT", 0, -10)
	features:SetWidth(500)
	features:SetText("- Adds a customizable Copy button to the chat frame.\n" .. "- Allows you to easily extract and copy all visible chat lines.\n" .. "- Fully customizable icon position and transparency.\n" .. "- Minimalist design with no unnecessary overhead.\n" .. "- Supports real-time configuration updates.")

	-- Purpose Section
	local purposeHeading = canvas:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	purposeHeading:SetPoint("TOPLEFT", features, "BOTTOMLEFT", 0, -20)
	purposeHeading:SetText("|cffFFD700Why CopyThat Exists:|r")

	local purpose = canvas:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	purpose:SetPoint("TOPLEFT", purposeHeading, "BOTTOMLEFT", 0, -10)
	purpose:SetWidth(500)
	purpose:SetText("CopyThat was created to streamline the process of sharing chat content, whether for social interaction, troubleshooting, or record-keeping. It eliminates the hassle of manually selecting text and ensures an effortless experience.")

	-- Slash Commands Section
	local commandsHeading = canvas:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	commandsHeading:SetPoint("TOPLEFT", purpose, "BOTTOMLEFT", 0, -20)
	commandsHeading:SetText("|cffFFD700Slash Commands:|r")

	local commands = canvas:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	commands:SetPoint("TOPLEFT", commandsHeading, "BOTTOMLEFT", 0, -10)
	commands:SetWidth(500)
	commands:SetText("/copythat - Open the CopyThat settings menu.")

	-- Contributions Section
	local contributionsHeading = canvas:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	contributionsHeading:SetPoint("TOPLEFT", commands, "BOTTOMLEFT", 0, -20)
	contributionsHeading:SetText("|cffFFD700Support & Feedback:|r")

	-- PayPal Button
	local paypalButton = CreateFrame("Button", nil, canvas, "UIPanelButtonTemplate")
	paypalButton:SetPoint("TOPLEFT", contributionsHeading, "BOTTOMLEFT", 0, -10)
	paypalButton:SetSize(150, 25)
	paypalButton:SetText("Donate via PayPal")
	paypalButton:SetScript("OnClick", function()
		print("Visit this link to donate: https://www.paypal.com/paypalme/KkthnxTV")
	end)
	paypalButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Click to open the donation link.")
		GameTooltip:Show()
	end)
	paypalButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	-- Feedback Button
	local feedbackButton = CreateFrame("Button", nil, canvas, "UIPanelButtonTemplate")
	feedbackButton:SetPoint("TOPLEFT", paypalButton, "BOTTOMLEFT", 0, -10)
	feedbackButton:SetSize(150, 25)
	feedbackButton:SetText("Report Feedback")
	feedbackButton:SetScript("OnClick", function()
		print("Visit the repository for feedback: https://github.com/Kkthnx-Wow/CopyThat")
	end)
	feedbackButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Click to open the feedback repository.")
		GameTooltip:Show()
	end)
	feedbackButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	-- Support Section
	local supportHeading = canvas:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	supportHeading:SetPoint("TOPLEFT", feedbackButton, "BOTTOMLEFT", 0, -20)
	supportHeading:SetText("|cffFFD700Support:|r")

	local support = canvas:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	support:SetPoint("TOPLEFT", supportHeading, "BOTTOMLEFT", 0, -10)
	support:SetWidth(500)
	support:SetText("Have feedback, ideas, or bugs to report? Click 'Report Feedback' or contact us directly. Thank you for using CopyThat!")
end

-- Register the About canvas with the interface
namespace:RegisterSubSettingsCanvas("About CopyThat", CreateAboutCanvas)

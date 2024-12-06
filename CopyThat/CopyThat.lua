local _, namespace = ...

local _G = _G
local gsub, format, tconcat, tostring = string.gsub, string.format, table.concat, tostring
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local ScrollFrameTemplate_OnMouseWheel = ScrollFrameTemplate_OnMouseWheel

local chatLines = {}
local chatCopyFrame, chatEditBox = nil, nil

-- Determines if a message can be changed
local function CanModifyMessage(arg1, id)
	if id and arg1 == "" then
		return id
	end
end

-- Checks if a message is protected
local function IsMessageProtected(msg)
	return msg and (msg ~= gsub(msg, "(:?|?)|K(.-)|k", CanModifyMessage))
end

-- Formats and replaces chat message content
local function FormatChatMessage(msg, r, g, b)
	local hexRGB = namespace.HexRGB(r, g, b)
	msg = gsub(msg, "|T(.-):.-|t", "")
	msg = gsub(msg, "|A(.-):.-|a", "")
	return format("%s%s|r", hexRGB, msg)
end

-- Extracts lines from the chat frame
function namespace:GetChatLines()
	local index = 1
	for i = 1, self:GetNumMessages() do
		local msg, r, g, b = self:GetMessageInfo(i)
		if msg and not IsMessageProtected(msg) then
			r, g, b = r or 1, g or 1, b or 1
			msg = FormatChatMessage(msg, r, g, b)
			chatLines[index] = tostring(msg)
			index = index + 1
		end
	end
	return index - 1
end

-- Handles the Copy That button click
function namespace:OnChatCopyButtonClick()
	if not chatCopyFrame:IsShown() then
		local chatFrame = _G.SELECTED_DOCK_FRAME
		local _, fontSize = chatFrame:GetFont()
		FCF_SetChatWindowFontSize(chatFrame, chatFrame, 0.01)
		chatCopyFrame:Show()

		local lineCount = namespace.GetChatLines(chatFrame)
		local text = tconcat(chatLines, "\n", 1, lineCount)
		FCF_SetChatWindowFontSize(chatFrame, chatFrame, fontSize)
		chatEditBox:SetText(text)
	else
		chatCopyFrame:Hide()
	end
end

function namespace:CreateChatCopyFrame()
	if not namespace:GetOption("isEnabled") then
		return
	end

	chatCopyFrame = CreateFrame("Frame", "CopyThatChatCopy", UIParent, "TooltipBackdropTemplate")
	chatCopyFrame:SetPoint("CENTER")
	chatCopyFrame:SetSize(700, 400)
	chatCopyFrame:Hide()
	chatCopyFrame:SetFrameStrata("DIALOG")
	chatCopyFrame:SetMovable(true)
	chatCopyFrame:SetUserPlaced(true)
	chatCopyFrame:SetClampedToScreen(true)
	chatCopyFrame:EnableMouse(true)
	chatCopyFrame:RegisterForDrag("LeftButton")
	chatCopyFrame:SetScript("OnDragStart", chatCopyFrame.StartMoving)
	chatCopyFrame:SetScript("OnDragStop", chatCopyFrame.StopMovingOrSizing)

	chatCopyFrame.close = CreateFrame("Button", nil, chatCopyFrame, "UIPanelCloseButton")
	chatCopyFrame.close:SetSize(22, 22)
	chatCopyFrame.close:SetPoint("TOPRIGHT", chatCopyFrame, -4, -4)

	local scrollArea = CreateFrame("ScrollFrame", "ChatCopyScrollFrame", chatCopyFrame, "UIPanelScrollFrameTemplate, BackdropTemplate")
	scrollArea:SetPoint("TOPLEFT", 10, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", -28, 10)

	chatEditBox = CreateFrame("EditBox", nil, chatCopyFrame)
	chatEditBox:SetMultiLine(true)
	chatEditBox:SetMaxLetters(99999)
	chatEditBox:EnableMouse(true)
	chatEditBox:SetAutoFocus(false)
	chatEditBox:SetFont(namespace.Font[1], 12, "")
	chatEditBox:SetSize(scrollArea:GetWidth(), scrollArea:GetHeight())
	chatEditBox:SetScript("OnEscapePressed", function()
		chatCopyFrame:Hide()
	end)
	chatEditBox:SetScript("OnTextChanged", function(_, userInput)
		if userInput then
			return
		end

		local _, max = scrollArea.ScrollBar:GetMinMaxValues()
		for i = 1, max do
			ScrollFrameTemplate_OnMouseWheel(scrollArea, -1)
		end
	end)

	scrollArea:SetScrollChild(chatEditBox)
	scrollArea:HookScript("OnVerticalScroll", function(self, offset)
		chatEditBox:SetHitRectInsets(0, 0, offset, (chatEditBox:GetHeight() - offset - self:GetHeight()))
	end)

	local copyButton = CreateFrame("Button", "CopyThatChatButton", UIParent)
	local iconPosition = namespace:GetOption("iconPosition")
	local positions = {
		BOTTOMRIGHT = { anchor = "BOTTOMRIGHT", x = namespace:IsRetail() and 15 or 2, y = -6 },
		TOPRIGHT = { anchor = "TOPRIGHT", x = namespace:IsRetail() and 15 or 2, y = 1 },
		TOPLEFT = { anchor = "TOPLEFT", x = -1, y = 1 },
		BOTTOMLEFT = { anchor = "BOTTOMLEFT", x = -1, y = -6 },
	}
	copyButton:SetPoint(positions[iconPosition].anchor, _G.ChatFrame1, positions[iconPosition].x, positions[iconPosition].y)
	copyButton:SetSize(22, 20)

	local iconAlpha = namespace:GetOption("iconAlpha")
	copyButton:SetAlpha(iconAlpha)

	copyButton.Icon = copyButton:CreateTexture(nil, "ARTWORK")
	copyButton.Icon:SetAllPoints()
	copyButton.Icon:SetTexture(namespace.CopyChatTexture)
	copyButton:RegisterForClicks("AnyUp")
	copyButton:SetScript("OnClick", function()
		namespace:OnChatCopyButtonClick()
	end)

	local tooltipText = format(namespace.L["Copy That"], namespace.LeftButton, namespace.RightButton)
	namespace.AddTooltip(copyButton, "ANCHOR_RIGHT", tooltipText)
	copyButton:HookScript("OnEnter", function()
		copyButton:SetAlpha(1)
	end)

	copyButton:HookScript("OnLeave", function()
		copyButton:SetAlpha(namespace:GetOption("iconAlpha"))
	end)
end

function namespace:ADDON_LOADED(addonName)
	if addonName ~= "CopyThat" then
		return
	end
	self:CreateChatCopyFrame()
end

-- Register a callback for real-time updates to position
namespace:RegisterOptionCallback("iconPosition", function(newValue)
	if not CopyThatChatButton then
		return
	end

	local positions = {
		BOTTOMRIGHT = { anchor = "BOTTOMRIGHT", x = namespace:IsRetail() and 15 or 2, y = -6 },
		TOPRIGHT = { anchor = "TOPRIGHT", x = namespace:IsRetail() and 15 or 2, y = 1 },
		TOPLEFT = { anchor = "TOPLEFT", x = -1, y = 1 },
		BOTTOMLEFT = { anchor = "BOTTOMLEFT", x = -1, y = -6 },
	}

	local position = positions[newValue]
	if position then
		CopyThatChatButton:ClearAllPoints()
		CopyThatChatButton:SetPoint(position.anchor, _G.ChatFrame1, position.x, position.y)
	end
end)

-- Register a callback for real-time updates to iconAlpha
namespace:RegisterOptionCallback("iconAlpha", function(newValue)
	if not CopyThatChatButton then
		return
	end

	CopyThatChatButton:SetAlpha(newValue)
end)

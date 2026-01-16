--[[-----------------------------------------------------------------------------
-- Addon: CopyThat
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Handles the core logic for capturing and copying chat messages.
-- - Design: Uses a hidden Frame and ScrollFrame to emulate chat copying functionality.
-----------------------------------------------------------------------------]]

local _, namespace = ...

local _G = _G
local string_gsub, string_format, table_concat, tostring = string.gsub, string.format, table.concat, tostring
local table_wipe = table.wipe
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local CreateFrame = CreateFrame
local UIParent = UIParent
local ChatFrame1 = ChatFrame1

local chatLines = {}
local chatCopyFrame, chatEditBox = nil, nil

-- REASON: checking validity of the message ID to ensure safe modification
local function canModifyMessage(arg1, id)
	if id and arg1 == "" then
		return id
	end
end

-- REASON: prevent modification of protected strings to avoid taint
local function isMessageProtected(msg)
	return msg and (msg ~= string_gsub(msg, "(:?|?)|K(.-)|k", canModifyMessage))
end

-- REASON: strips textures, animations, and links while applying color formatting
local function formatChatMessage(msg, r, g, b)
	local hexRGB = namespace.HexRGB(r, g, b)
	msg = string_gsub(msg, "|T(.-):.-|t", "") -- Strip textures
	msg = string_gsub(msg, "|A(.-):.-|a", "") -- Strip animations
	msg = string_gsub(msg, "|H.-|h(.-)|h", "%1") -- Strip links but keep text
	return string_format("%s%s|r", hexRGB, msg)
end

-- REASON: iterates over chat lines to build the copyable text buffer
-- PERF: reuse chatLines table to minimize garbage collection
function namespace:GetChatLines()
	table_wipe(chatLines)
	local index = 1
	for i = 1, self:GetNumMessages() do
		local msg, r, g, b = self:GetMessageInfo(i)
		if msg and not isMessageProtected(msg) then
			r, g, b = r or 1, g or 1, b or 1
			msg = formatChatMessage(msg, r, g, b)
			chatLines[index] = tostring(msg)
			index = index + 1
		end
	end
	return index - 1
end

-- REASON: toggles the copy frame visibility and populates it with current chat text
function namespace:OnChatCopyButtonClick()
	if not chatCopyFrame or not chatEditBox then
		return
	end

	if not chatCopyFrame:IsShown() then
		local chatFrame = _G["SELECTED_DOCK_FRAME"]
		if not chatFrame then
			return
		end

		local _, fontSize = chatFrame:GetFont()
		FCF_SetChatWindowFontSize(chatFrame, chatFrame, 0.01)
		chatCopyFrame:Show()

		local lineCount = namespace.GetChatLines(chatFrame)
		local text = table_concat(chatLines, "\n", 1, lineCount)
		FCF_SetChatWindowFontSize(chatFrame, chatFrame, fontSize)
		chatEditBox:SetText(text)
	else
		chatCopyFrame:Hide()
	end
end

-- REASON: initializes the main copy UI frame and its interactive elements
function namespace:CreateChatCopyFrame()
	if chatCopyFrame or not namespace:GetOption("isEnabled") then
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
		scrollArea.ScrollBar:SetValue(max)
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
	copyButton:SetPoint(positions[iconPosition].anchor, ChatFrame1, positions[iconPosition].x, positions[iconPosition].y)
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

	local tooltipText = string_format(namespace.L["Copy That"], namespace.LeftButton, namespace.RightButton)
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

-- REASON: enable or disable the addon logic dynamically
namespace:RegisterOptionCallback("isEnabled", function(newValue)
	if newValue then
		namespace:CreateChatCopyFrame()
		if _G["CopyThatChatButton"] then
			_G["CopyThatChatButton"]:Show()
		end
	else
		if _G["CopyThatChatButton"] then
			_G["CopyThatChatButton"]:Hide()
		end
		if chatCopyFrame then
			chatCopyFrame:Hide()
		end
	end
end)

-- REASON: update icon position immediately when configuration changes
namespace:RegisterOptionCallback("iconPosition", function(newValue)
	local copyButton = _G["CopyThatChatButton"]
	if not copyButton then
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
		copyButton:ClearAllPoints()
		copyButton:SetPoint(position.anchor, ChatFrame1, position.x, position.y)
	end
end)

-- REASON: update icon transparency immediately when configuration changes
namespace:RegisterOptionCallback("iconAlpha", function(newValue)
	local copyButton = _G["CopyThatChatButton"]
	if not copyButton then
		return
	end

	copyButton:SetAlpha(newValue)
end)

--[[
	CopyThat - Chat Copy
	-------------------------------------------------------------------------
	Adds a copy button to the active chat window and a scrollable copy frame.
	Works across retail and classic flavours; guards Midnight secret chat lines.
--]]

-- luacheck: globals ChatFontNormal ScrollUtil FCF_SetChatWindowFontSize
local _, ns = ...
local F, C, L = ns.F, ns.C, ns.L

local _G = _G
local gsub, format, tconcat, tostring = string.gsub, string.format, table.concat, tostring
local wipe = wipe
local CreateFrame = CreateFrame
local UIParent = UIParent
local GameTooltip = GameTooltip
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local ScrollUtil = ScrollUtil
local C_Timer = C_Timer

ns:RegisterDefaults({
	chatCopy = {
		enable = true,
		iconAlpha = 0.5,
		iconPosition = "BOTTOMRIGHT",
	},
})

local ChatCopy = ns:NewModule("ChatCopy", "chatCopy", { group = "chat", title = L["Chat Copy"], order = 10 })

local lines = {}
local frame, editBox, copyButton
local dockHooked = false

local function canChangeMessage(arg1, id)
	if id and arg1 == "" then
		return id
	end
end

local function isMessageProtected(msg)
	return msg and (msg ~= gsub(msg, "(:?|?)|K(.-)|k", canChangeMessage))
end

local function formatChatMessage(msg, r, g, b)
	local hexRGB = "|c" .. F.RGBToHex(r, g, b)
	msg = gsub(msg, "|T(.-):.-|t", "")
	msg = gsub(msg, "|A(.-):.-|a", "")
	msg = gsub(msg, "|H.-|h(.-)|h", "%1")
	return format("%s%s|r", hexRGB, msg)
end

local function GetChatLines(chatFrame)
	wipe(lines)
	local index = 1
	for i = 1, chatFrame:GetNumMessages() do
		local msg, r, g, b = chatFrame:GetMessageInfo(i)
		if msg and F.NotSecret(msg) and not isMessageProtected(msg) then
			if F.IsSecret(r) or F.IsSecret(g) or F.IsSecret(b) then
				r, g, b = 1, 1, 1
			else
				r, g, b = r or 1, g or 1, b or 1
			end
			lines[index] = tostring(formatChatMessage(msg, r, g, b))
			index = index + 1
		end
	end
	return index - 1
end

local function CreateScrollArea(parent)
	if ScrollUtil and MinimalScrollBar then
		local scrollArea = CreateFrame("ScrollFrame", "CopyThatChatCopyScroll", parent)
		scrollArea:SetPoint("TOPLEFT", 12, -32)
		scrollArea:SetPoint("BOTTOMRIGHT", -28, 12)

		local scrollBar = CreateFrame("EventFrame", nil, parent, "MinimalScrollBar")
		scrollBar:SetPoint("TOPLEFT", scrollArea, "TOPRIGHT", 6, 0)
		scrollBar:SetPoint("BOTTOMLEFT", scrollArea, "BOTTOMRIGHT", 6, 0)
		ScrollUtil.InitScrollFrameWithScrollBar(scrollArea, scrollBar)
		return scrollArea
	end

	local scrollArea = CreateFrame("ScrollFrame", "CopyThatChatCopyScroll", parent, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", 10, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", -28, 10)
	return scrollArea
end

local function CreateCopyFrame()
	frame = CreateFrame("Frame", "CopyThatChatCopy", UIParent, "BackdropTemplate")
	frame:SetPoint("CENTER")
	frame:SetSize(700, 400)
	frame:SetFrameStrata("DIALOG")
	frame:Hide()
	F.MakeWindowMovable(frame, "CopyThatChatCopy")
	frame:SetBackdrop(C.Backdrops.window)
	frame:SetBackdropColor(0.06, 0.06, 0.06, 0.9)
	frame:SetBackdropBorderColor(1, 1, 1)

	frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	frame.close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)

	local scrollArea = CreateScrollArea(frame)

	editBox = CreateFrame("EditBox", nil, frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	if ChatFontNormal then
		editBox:SetFontObject(ChatFontNormal)
	else
		editBox:SetFont(STANDARD_TEXT_FONT, 12, "")
	end
	editBox:SetWidth(scrollArea:GetWidth())
	editBox:SetScript("OnEscapePressed", function()
		frame:Hide()
	end)
	scrollArea:SetScrollChild(editBox)

	if scrollArea.ScrollBar then
		editBox:SetScript("OnTextChanged", function(_, userInput)
			if userInput then
				return
			end
			local _, max = scrollArea.ScrollBar:GetMinMaxValues()
			scrollArea.ScrollBar:SetValue(max)
		end)
		scrollArea:HookScript("OnVerticalScroll", function(self, offset)
			editBox:SetHitRectInsets(0, 0, offset, (editBox:GetHeight() - offset - self:GetHeight()))
		end)
	end
end

function ChatCopy:GetActiveChatFrame()
	return (_G.SELECTED_DOCK_FRAME) or _G.ChatFrame1
end

function ChatCopy:PopulateCopyFrame(chatFrame)
	if not frame then
		CreateCopyFrame()
	end

	chatFrame = chatFrame or self:GetActiveChatFrame()
	if not chatFrame then
		return
	end

	local _, fontSize = chatFrame:GetFont()
	if FCF_SetChatWindowFontSize then
		FCF_SetChatWindowFontSize(chatFrame, chatFrame, 0.01)
	end

	local count = GetChatLines(chatFrame)

	if FCF_SetChatWindowFontSize and fontSize then
		FCF_SetChatWindowFontSize(chatFrame, chatFrame, fontSize)
	end

	editBox:SetText(tconcat(lines, "\n", 1, count))
	return count
end

function ChatCopy:Toggle(chatFrame)
	if not frame then
		CreateCopyFrame()
	end
	if frame:IsShown() then
		frame:Hide()
		return
	end

	self:PopulateCopyFrame(chatFrame)
	frame:Show()
	editBox:SetCursorPosition(0)
	editBox:HighlightText()
end

local function ApplyButtonAlpha()
	if not copyButton then
		return
	end
	copyButton:SetAlpha(ns.db.chatCopy.iconAlpha or 0.5)
end

local function ApplyButtonPosition(chatFrame)
	if not copyButton then
		return
	end
	chatFrame = chatFrame or copyButton.chatFrame or _G.ChatFrame1
	if not chatFrame then
		return
	end

	local anchor, x, y = F.GetIconPositionOffset(ns.db.chatCopy.iconPosition)
	copyButton:ClearAllPoints()
	copyButton:SetPoint(anchor, chatFrame, x, y)
end

local function CreateCopyButton()
	local button = CreateFrame("Button", "CopyThatChatButton", UIParent)
	button:SetSize(22, 20)
	button:SetFrameStrata("HIGH")
	button:Show()

	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints()
	icon:SetTexture(C.Media.Textures.copyIcon)

	button:SetScript("OnClick", function(self)
		ChatCopy:Toggle(self.chatFrame or ChatCopy:GetActiveChatFrame())
	end)

	button:SetScript("OnEnter", function(self)
		self:SetAlpha(1)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L["Copy Chat"])
		GameTooltip:AddLine(L["Copy Chat Tip"], 1, 0.82, 0, 1)
		GameTooltip:Show()
	end)

	button:SetScript("OnLeave", function()
		ApplyButtonAlpha()
		GameTooltip:Hide()
	end)

	return button
end

local function UpdateButtonOwner(chatFrame)
	if not copyButton or not chatFrame then
		return
	end
	copyButton.chatFrame = chatFrame
	ApplyButtonPosition(chatFrame)
	copyButton:Show()
end

function ChatCopy:Install()
	if not self:IsEnabled() then
		return
	end

	local chatFrame = self:GetActiveChatFrame()
	if not chatFrame then
		C_Timer.After(0, function()
			ChatCopy:Install()
		end)
		return
	end

	if not copyButton then
		copyButton = CreateCopyButton()
	end

	UpdateButtonOwner(chatFrame)
	ApplyButtonAlpha()
end

function ChatCopy:OnSettingChanged(key, value)
	if key == "enable" then
		if value then
			self:Install()
		elseif copyButton then
			copyButton:Hide()
			if frame then
				frame:Hide()
			end
		end
	elseif key == "iconAlpha" then
		ApplyButtonAlpha()
	elseif key == "iconPosition" then
		ApplyButtonPosition()
	end
end

function ChatCopy:OnEnable()
	if not self:IsEnabled() then
		return
	end

	self:Install()

	if not dockHooked and _G.FCFDock_SelectWindow then
		dockHooked = true
		hooksecurefunc("FCFDock_SelectWindow", function(dock, chatFrame)
			if dock == _G.GENERAL_CHAT_DOCK then
				UpdateButtonOwner(chatFrame)
			end
		end)
	end
end

function ChatCopy:RegisterOptions(category, builder)
	builder:Checkbox(category, self, "enable", L["Enable Chat Copy"], L["Enable Chat Copy Tip"])
	builder:Slider(category, self, "iconAlpha", L["Icon Transparency"], L["Icon Transparency Tip"], 0, 1, 0.1)
	builder:Dropdown(category, self, "iconPosition", L["Icon Position"], L["Icon Position Tip"], {
		{ value = "BOTTOMRIGHT", label = L["Bottom Right"] },
		{ value = "TOPRIGHT", label = L["Top Right"] },
		{ value = "TOPLEFT", label = L["Top Left"] },
		{ value = "BOTTOMLEFT", label = L["Bottom Left"] },
	})
end

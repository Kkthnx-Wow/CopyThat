--[[
	CopyThat - Copy
	-------------------------------------------------------------------------
	Adds a small button on the chat frame that opens a copy window containing
	the active chat window's text, ready to select and copy.

	Instance-safe: chat lines (and their colours) can be Secret Values in
	Midnight — we skip those rather than touching them with string ops.
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

ns:RegisterDefaults({
	chatCopy = {
		enable = true,
		iconAlpha = 0.5,
		iconPosition = "BOTTOMRIGHT",
	},
})

local Copy = ns:NewModule("Copy", "chatCopy", { title = L["Chat Copy"], order = 10 })

local COPY_BACKDROP = C.Backdrops.window

-- Reused line buffer — no fresh table per copy.
local lines = {}
local frame, editBox, copyButton
local dockHooked = false

-- Corner anchors; retail chat chrome needs a slightly different nudge.
local function GetPositionOffsets(position)
	local retail = C.Client.isRetail
	local positions = {
		BOTTOMRIGHT = { anchor = "BOTTOMRIGHT", x = retail and 15 or 2, y = -6 },
		TOPRIGHT = { anchor = "TOPRIGHT", x = retail and 15 or 2, y = 1 },
		TOPLEFT = { anchor = "TOPLEFT", x = -1, y = 1 },
		BOTTOMLEFT = { anchor = "BOTTOMLEFT", x = -1, y = -6 },
	}
	return positions[position] or positions.BOTTOMRIGHT
end

local function canChangeMessage(arg1, id)
	if id and arg1 == "" then
		return id
	end
end

-- Protected strings (|K...|k) must not be reformatted — taint city.
local function isMessageProtected(msg)
	return msg and (msg ~= gsub(msg, "(:?|?)|K(.-)|k", canChangeMessage))
end

local function formatChatMessage(msg, r, g, b)
	msg = gsub(msg, "|T(.-):.-|t", "")
	msg = gsub(msg, "|A(.-):.-|a", "")
	msg = gsub(msg, "|H.-|h(.-)|h", "%1")
	return format("|c%s%s|r", F.RGBToHex(r, g, b), msg)
end

local function GetChatLines(chatFrame)
	wipe(lines)
	local index = 1
	for i = 1, chatFrame:GetNumMessages() do
		local msg, r, g, b = chatFrame:GetMessageInfo(i)
		if msg and F.NotSecret(msg) and not isMessageProtected(msg) then
			-- Colour components can be secret too; never do arithmetic on them.
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

local function CreateCopyFrame()
	frame = CreateFrame("Frame", "CopyThatChatCopy", UIParent, "BackdropTemplate")
	frame:SetPoint("CENTER")
	frame:SetSize(700, 400)
	frame:SetFrameStrata("DIALOG")
	frame:Hide()
	F.MakeWindowMovable(frame, "CopyThatChatCopy")
	frame:SetBackdrop(COPY_BACKDROP)
	frame:SetBackdropColor(0.06, 0.06, 0.06, 0.9)
	frame:SetBackdropBorderColor(1, 1, 1)

	frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	frame.close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)

	local scrollArea = CreateFrame("ScrollFrame", "CopyThatChatCopyScroll", frame)
	scrollArea:SetPoint("TOPLEFT", 12, -32)
	scrollArea:SetPoint("BOTTOMRIGHT", -28, 12)

	local scrollBar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar")
	scrollBar:SetPoint("TOPLEFT", scrollArea, "TOPRIGHT", 6, 0)
	scrollBar:SetPoint("BOTTOMLEFT", scrollArea, "BOTTOMRIGHT", 6, 0)
	ScrollUtil.InitScrollFrameWithScrollBar(scrollArea, scrollBar)

	editBox = CreateFrame("EditBox", nil, frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetWidth(scrollArea:GetWidth())
	editBox:SetScript("OnEscapePressed", function()
		frame:Hide()
	end)
	editBox:SetScript("OnTextChanged", function(_, userInput)
		if userInput then
			return
		end
		local _, max = scrollArea.ScrollBar:GetMinMaxValues()
		scrollArea.ScrollBar:SetValue(max)
	end)
	scrollArea:SetScrollChild(editBox)
	scrollArea:HookScript("OnVerticalScroll", function(self, offset)
		editBox:SetHitRectInsets(0, 0, offset, (editBox:GetHeight() - offset - self:GetHeight()))
	end)
end

function Copy:Toggle(chatFrame)
	if not frame then
		CreateCopyFrame()
	end
	if frame:IsShown() then
		frame:Hide()
		return
	end

	chatFrame = chatFrame or _G["SELECTED_DOCK_FRAME"] or _G["ChatFrame1"]
	if not chatFrame then
		return
	end

	-- Shrinking the chat font forces a relayout so GetMessageInfo sees every
	-- line — Blizzard's little gift to anyone who wants to copy chat.
	local _, fontSize = chatFrame:GetFont()
	FCF_SetChatWindowFontSize(chatFrame, chatFrame, 0.01)
	local count = GetChatLines(chatFrame)
	FCF_SetChatWindowFontSize(chatFrame, chatFrame, fontSize)

	editBox:SetText(tconcat(lines, "\n", 1, count))
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
	if not copyButton or not chatFrame then
		return
	end
	local pos = GetPositionOffsets(ns.db.chatCopy.iconPosition)
	copyButton:ClearAllPoints()
	copyButton:SetPoint(pos.anchor, chatFrame, pos.x, pos.y)
end

local function CreateCopyButton(chatFrame)
	local button = CreateFrame("Button", "CopyThatChatButton", chatFrame)
	button:SetSize(22, 20)
	button:SetFrameStrata("HIGH")
	button.chatFrame = chatFrame

	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints()
	icon:SetTexture(C.Media.Textures.copyButton)
	button.icon = icon

	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", function(self)
		Copy:Toggle(self.chatFrame)
	end)

	local tooltipText = format(L["Copy tooltip hint"], C.LeftButton, C.RightButton)
	button:SetScript("OnEnter", function(self)
		self:SetAlpha(1)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L["Copy That"])
		GameTooltip:AddLine(tooltipText, 1, 0.8, 0, 1)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		ApplyButtonAlpha()
		GameTooltip:Hide()
	end)

	ApplyButtonAlpha()
	ApplyButtonPosition(chatFrame)
	return button
end

local function UpdateButtonOwner(chatFrame)
	if not copyButton or not chatFrame then
		return
	end
	copyButton.chatFrame = chatFrame
	copyButton:SetParent(chatFrame)
	ApplyButtonPosition(chatFrame)
	copyButton:SetFrameStrata("HIGH")
end

function Copy:OnEnable()
	if not ns.db.chatCopy.enable then
		return
	end

	copyButton = CreateCopyButton(_G["ChatFrame1"])

	if not dockHooked and _G["FCFDock_SelectWindow"] then
		dockHooked = true
		hooksecurefunc("FCFDock_SelectWindow", function(dock, chatFrame)
			if dock == _G["GENERAL_CHAT_DOCK"] then
				UpdateButtonOwner(chatFrame)
			end
		end)
	end
end

function Copy:OnSettingChanged(key, value)
	if key == "enable" then
		if value then
			if not copyButton then
				self:OnEnable()
			else
				copyButton:Show()
			end
		else
			if copyButton then
				copyButton:Hide()
			end
			if frame then
				frame:Hide()
			end
		end
	elseif key == "iconAlpha" then
		ApplyButtonAlpha()
	elseif key == "iconPosition" and copyButton then
		ApplyButtonPosition(copyButton.chatFrame or _G["ChatFrame1"])
	end
end

function Copy:RegisterOptions(category, builder)
	builder:Checkbox(category, self, "enable", L["Enable Chat Copy"], L["Enable or disable the Copy That button and copy window."])
	builder:Slider(category, self, "iconAlpha", L["Icon Transparency"], L["Set the resting transparency of the Copy That icon (0.0-1.0). It fades to full opacity on hover."], 0, 1, 0.1)
	builder:Dropdown(category, self, "iconPosition", L["Icon Position"], L["Select which corner of the chat frame the Copy That icon sits in."], {
		{ value = "BOTTOMRIGHT", label = L["Bottom Right"] },
		{ value = "TOPRIGHT", label = L["Top Right"] },
		{ value = "TOPLEFT", label = L["Top Left"] },
		{ value = "BOTTOMLEFT", label = L["Bottom Left"] },
	})
end

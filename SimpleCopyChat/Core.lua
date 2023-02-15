--[[
	The MIT License (MIT)
	Copyright (c) 2022 Josh 'Kkthnx' Russell
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
--]]

local Module = CreateFrame("Frame")
Module:RegisterEvent("PLAYER_LOGIN")

local _G = _G
local string_format = _G.string.format
local string_gsub = _G.string.gsub
local table_concat = _G.table.concat
local tostring = _G.tostring

local CreateFrame = _G.CreateFrame
local FCF_SetChatWindowFontSize = _G.FCF_SetChatWindowFontSize
local PlaySound = _G.PlaySound
local ScrollFrameTemplate_OnMouseWheel = _G.ScrollFrameTemplate_OnMouseWheel
local UIParent = _G.UIParent

local lines = {}
local frame
local editBox

-- RGBToHex
local function RGBToHex(r, g, b)
	if type(r) == "table" then
		if r.r then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end

	return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function canChangeMessage(arg1, id)
	if id and arg1 == "" then
		return id
	end
end

local function isMessageProtected(msg)
	return msg and (msg ~= string_gsub(msg, "(:?|?)|K(.-)|k", canChangeMessage))
end

local function replaceMessage(msg, r, g, b)
	local hexRGB = RGBToHex(r or 1, g or 1, b or 1)
	msg = msg:gsub("|T(.-):.-|t", "")
	msg = msg:gsub("|A(.-):.-|a", "")
	return ("%s%s|r"):format(hexRGB, msg)
end

function Module:GetChatLines()
	local index = 1
	local numMessages = self:GetNumMessages()
	for i = 1, numMessages do
		local msg, r, g, b = self:GetMessageInfo(i)
		if msg and not isMessageProtected(msg) then
			r, g, b = r or 1, g or 1, b or 1
			msg = replaceMessage(msg, r, g, b)
			lines[index] = tostring(msg)
			index = index + 1
		end
	end

	return table.concat(lines, "\n"), index - 1
end

function Module:ChatCopy_OnClick()
	local chatframe = _G.SELECTED_DOCK_FRAME
	if not frame:IsShown() then
		local _, fontSize = chatframe:GetFont()
		FCF_SetChatWindowFontSize(chatframe, chatframe, 0.01)
		PlaySound(21968)
		frame:Show()

		local lineCt = chatframe:GetNumMessages()
		local text = ""
		for i = 1, lineCt do
			local msg, r, g, b = chatframe:GetMessageInfo(i)
			if msg and not isMessageProtected(msg) then
				text = text .. replaceMessage(msg, r, g, b) .. "\n"
			end
		end
		FCF_SetChatWindowFontSize(chatframe, chatframe, fontSize)
		editBox:SetText(text)
	else
		frame:Hide()
	end
end

function Module:ChatCopy_OnEnter()
	UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)

	if not GameTooltip:IsForbidden() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 10, 5)
		GameTooltip:SetText("Simple Copy Chat")
		GameTooltip:Show()
	end
end

function Module:ChatCopy_OnLeave()
	UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)

	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide()
	end
end

local function CreateCopyButton(chatFrameID)
	local chat = _G["ChatFrame" .. chatFrameID]
	local copy = CreateFrame("Button", "Kkthnx_ChatCopyButton" .. chatFrameID, chat)
	copy:SetPoint("BOTTOMRIGHT", 22, -4)
	copy:SetSize(16, 16)
	copy:SetAlpha(0.25)

	copy.Texture = copy:CreateTexture(nil, "ARTWORK")
	copy.Texture:SetAllPoints()
	copy.Texture:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")

	copy:RegisterForClicks("AnyUp")
	copy:SetScript("OnClick", Module.ChatCopy_OnClick)
	copy:SetScript("OnEnter", Module.ChatCopy_OnEnter)
	copy:SetScript("OnLeave", Module.ChatCopy_OnLeave)
end

local backdropInfo = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileEdge = true,
	tileSize = 8,
	edgeSize = 8,
	insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

Module:SetScript("OnEvent", function(saved)
	if not SimpleCopyChatDatabase then
		SimpleCopyChatDatabase = {}
	end

	frame = CreateFrame("Frame", "Kkthnx_CopyChat", UIParent, "BackdropTemplate")
	frame:SetBackdrop(BACKDROP_TUTORIAL_16_16)
	frame:SetPoint("CENTER")
	frame:SetSize(700, 400)
	frame:Hide()
	frame:SetFrameStrata("DIALOG")

	frame:SetMovable(true)
	frame:SetUserPlaced(true)
	frame:SetClampedToScreen(true)

	--frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function()
		frame:StartMoving()
	end)

	frame:SetScript("OnDragStop", function()
		frame:StopMovingOrSizing()
		-- print(saved)
		if not saved then
			return
		end

		local orig, _, tar, x, y = frame:GetPoint()
		SimpleCopyChatDatabase[frame:GetName()] = { orig, "UIParent", tar, x, y }
	end)

	frame.content = CreateFrame("Frame", nil, frame)
	frame.content:SetAllPoints()

	frame.title = frame:CreateFontString(nil, "OVERLAY")
	frame.title:SetFontObject(GameFontNormal)
	frame.title:SetFont(select(1, frame.title:GetFont()), 22, select(3, frame.title:GetFont()))
	frame.title:SetShadowOffset(1, -1)
	frame.title:SetPoint("TOP", frame, "TOP", 0, -12)
	frame.title:SetText("|cff669DFFSimple Copy Chat|r")
	frame.title:SetAlpha(0.7)

	frame.close = CreateFrame("Button", "Kkthnx_CopyChatEditBox", frame, "UIPanelCloseButton")
	frame.close:SetPoint("TOPRIGHT", frame, -6, -6)
	frame.close:SetSize(20, 20)

	local scrollArea = CreateFrame("ScrollFrame", "Kkthnx_CopyChatScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", 12, -42)
	scrollArea:SetPoint("BOTTOMRIGHT", -30, 20)

	editBox = CreateFrame("EditBox", "Kkthnx_CopyChatEditBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(GameFontNormal)
	editBox:SetWidth(scrollArea:GetWidth())
	editBox:SetHeight(400)
	editBox:SetScript("OnEscapePressed", function()
		frame:Hide()
	end)

	editBox:SetScript("OnTextChanged", function(_, userInput)
		if userInput then
			return
		end

		local _, max = scrollArea.ScrollBar:GetMinMaxValues()
		for _ = 1, max do
			ScrollFrameTemplate_OnMouseWheel(scrollArea, -1)
		end
	end)

	scrollArea:SetScrollChild(editBox)
	scrollArea:HookScript("OnVerticalScroll", function(self, offset)
		editBox:SetHitRectInsets(0, 0, offset, (editBox:GetHeight() - offset - self:GetHeight()))
	end)

	for i = 1, NUM_CHAT_WINDOWS do
		CreateCopyButton(i)
	end
end)

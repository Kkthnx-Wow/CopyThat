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

-- Create a new frame module
local Module = CreateFrame("Frame")

-- Register the "PLAYER_LOGIN" event for the module
Module:RegisterEvent("PLAYER_LOGIN")

-- Initialize variables
local lines = {}
local frame
local editBox

-- Function that converts RGB values to a hexadecimal color code
local function RGBToHex(r, g, b)
	-- If the input is a table, extract the RGB values
	if type(r) == "table" then
		if r.r then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end

	-- Convert the RGB values to a hexadecimal color code
	return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- Helper function that is used to replace Blizzard hash strings in messages
local function canChangeMessage(arg1, id)
	-- If an ID is provided and the argument is empty, return the ID
	if id and arg1 == "" then
		return id
	end
end

-- Function that checks if a message is protected (i.e. cannot be copied)
local function isMessageProtected(msg)
	-- If the message exists and contains a Blizzard hash string
	return msg and (msg ~= string.gsub(msg, "(:?|?)|K(.-)|k", canChangeMessage))
end

-- Function that replaces color codes in a message with their corresponding colors
local function replaceMessage(msg, r, g, b)
	-- Convert the RGB values to a hexadecimal color string
	local hexRGB = RGBToHex(r or 1, g or 1, b or 1)
	-- Remove any texture tags from the message
	msg = msg:gsub("|T(.-):.-|t", "")
	-- Remove any alpha tags from the message
	msg = msg:gsub("|A(.-):.-|a", "")
	-- Add the color code to the message and return the result
	return ("%s%s|r"):format(hexRGB, msg)
end

-- Get all visible chat messages in the chat frame.
-- Return the total number of messages obtained.
local function SimpleChatCopy_GetLines(self)
	-- Initialize index variable to 1.
	local index = 1

	-- Loop through all the chat messages in the chat frame.
	for i = 1, self:GetNumMessages() do
		-- Retrieve the message, and its color values (if any).
		local msg, r, g, b = self:GetMessageInfo(i)

		-- Check if the message exists and is not protected.
		if msg and not isMessageProtected(msg) then
			-- Set default color values if not provided.
			r, g, b = r or 1, g or 1, b or 1

			-- Replace any color tags in the message with the actual color values.
			msg = replaceMessage(msg, r, g, b)

			-- Add the message to the lines array and increment the index.
			lines[index] = tostring(msg)
			index = index + 1
		end
	end

	-- Return the total number of messages added to the lines array.
	return index - 1
end

-- Function that handles the behavior when SimpleChatCopy is clicked
local function SimpleChatCopy_OnClick(_, btn)
	-- If the left mouse button is clicked
	if btn == "LeftButton" then
		-- If the SimpleChatCopy frame is not already shown
		if not frame:IsShown() then
			-- Get the current chat frame
			local chatframe = _G.SELECTED_DOCK_FRAME
			-- Get the current font size of the chat frame
			local _, fontSize = chatframe:GetFont()
			-- Set the font size of the chat frame to a very small value, so that all text fits in the SimpleChatCopy frame
			FCF_SetChatWindowFontSize(chatframe, chatframe, 0.01)
			-- Show the SimpleChatCopy frame
			frame:Show()

			-- Retrieve the chat messages from the chat frame.
			local messageCount = SimpleChatCopy_GetLines(chatframe)
			-- Concatenate the messages into a single string with line breaks.
			local chatText = table.concat(lines, "\n", 1, messageCount)
			-- Set the font size of the chat frame back to its original value
			FCF_SetChatWindowFontSize(chatframe, chatframe, fontSize)
			-- Set the text of the SimpleChatCopy edit box to the chat text
			editBox:SetText(chatText)
		else
			-- If the SimpleChatCopy frame is already shown, hide it
			frame:Hide()
		end
	else
		-- If a button other than the left mouse button is clicked, hide the SimpleChatCopy frame
		frame:Hide()
	end
end

-- Function that handles the behavior when the mouse enters the SimpleChatCopy frame
local function SimpleChatCopy_OnEnter(self)
	-- Fades in the SimpleChatCopy frame
	UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)

	-- If GameTooltip is not forbidden (i.e. is allowed to be used)
	if not GameTooltip:IsForbidden() then
		-- Sets the owner of GameTooltip to SimpleChatCopy, and specifies where the tooltip should be anchored
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 10, 5)
		-- Sets the text of the tooltip to "Simple Copy Chat"
		GameTooltip:SetText("Simple Copy Chat")
		-- Shows the tooltip
		GameTooltip:Show()
	end
end

-- Function that handles the behavior when the mouse leaves the SimpleChatCopy frame
local function SimpleChatCopy_OnLeave(self)
	-- Fades out the SimpleChatCopy frame
	UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)

	-- If GameTooltip is not forbidden (i.e. is allowed to be used)
	if not GameTooltip:IsForbidden() then
		-- Hides the tooltip
		GameTooltip:Hide()
	end
end

-- This function creates a copy button for a specified chat frame and sets its attributes and behavior.
local function SimpleCopyChat_OnCreate(chatFrameID)
	-- Get the chat frame with the specified ID.
	local chat = _G["ChatFrame" .. chatFrameID]

	-- Create a new button frame and set its position and size.
	local copy = CreateFrame("Button", "SimpleCopyChat_Button" .. chatFrameID, chat)
	copy:SetPoint("BOTTOMRIGHT", 22, -4)
	copy:SetSize(16, 16)

	-- Set the button's transparency.
	copy:SetAlpha(0.25)

	-- Create a texture for the button and set its appearance.
	copy.Texture = copy:CreateTexture(nil, "ARTWORK")
	copy.Texture:SetAllPoints()
	copy.Texture:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")

	-- Register the button for mouse clicks and set its click and hover behavior.
	copy:RegisterForClicks("AnyUp")
	copy:SetScript("OnClick", SimpleChatCopy_OnClick)
	copy:SetScript("OnEnter", SimpleChatCopy_OnEnter)
	copy:SetScript("OnLeave", SimpleChatCopy_OnLeave)
end

-- Create a new frame and set up its properties
Module:SetScript("OnEvent", function(_, saved)
	-- Check if the database for the addon exists, if not, create an empty table
	if not SimpleCopyChatDB then
		SimpleCopyChatDB = {}
	end

	-- Check if the TemporaryAnchor table exists in the database, if not, create an empty table
	SimpleCopyChatDB.TemporaryAnchor = SimpleCopyChatDB.TemporaryAnchor or {}

	-- Create the frame and set its backdrop, position, size, and strata
	frame = CreateFrame("Frame", "SimpleCopyChat", UIParent, "BackdropTemplate")
	frame:SetBackdrop(BACKDROP_TUTORIAL_16_16)
	frame:SetPoint("CENTER")
	frame:SetSize(700, 400)
	frame:Hide()
	frame:SetFrameStrata("DIALOG")

	-- Make the frame movable, clamped to the screen, and enable dragging
	frame:SetMovable(true)
	frame:SetUserPlaced(true)
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function()
		frame:StartMoving()
	end)

	-- Save the position of the frame after dragging it, if enabled
	frame:SetScript("OnDragStop", function()
		frame:StopMovingOrSizing()
		if not saved then
			return
		end

		local orig, _, tar, x, y = frame:GetPoint()
		SimpleCopyChatDB["TemporaryAnchor"][frame:GetName()] = { orig, "UIParent", tar, x, y }
	end)

	-- Create a new frame to hold the content of the Simple Copy Chat addon
	frame.content = CreateFrame("Frame", nil, frame)
	frame.content:SetAllPoints()

	-- Create a new font string to display the title of the addon
	frame.title = frame:CreateFontString(nil, "OVERLAY")
	frame.title:SetFontObject(GameFontNormal)
	frame.title:SetFont(select(1, frame.title:GetFont()), 22, select(3, frame.title:GetFont()))
	frame.title:SetShadowOffset(1, -1)
	frame.title:SetPoint("TOP", frame, "TOP", 0, -10)
	frame.title:SetText("|cff669DFFSimple Copy Chat|r")
	frame.title:SetAlpha(0.7)

	-- Create a close button for the addon
	frame.close = CreateFrame("Button", "SimpleCopyChat_CloseButton", frame, "UIPanelCloseButton")
	frame.close:SetPoint("TOPRIGHT", frame, -6, -6)
	frame.close:SetSize(20, 20)

	-- Create a scrollable area to hold the chat content
	local scrollArea = CreateFrame("ScrollFrame", "SimpleCopyChat_ScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", 12, -42)
	scrollArea:SetPoint("BOTTOMRIGHT", -30, 20)

	-- Create an edit box for text input
	editBox = CreateFrame("EditBox", "SimpleCopyChat_EditBox", frame)
	editBox:SetMultiLine(true) -- Allow multiple lines of text
	editBox:SetMaxLetters(99999) -- Set the maximum number of characters that can be entered
	editBox:EnableMouse(true) -- Enable mouse interaction with the edit box
	editBox:SetAutoFocus(false) -- Don't automatically focus on the edit box when it is shown
	editBox:SetFontObject(GameFontNormal) -- Set the font used for the text
	editBox:SetWidth(scrollArea:GetWidth()) -- Set the width of the edit box to match the width of the scroll area
	editBox:SetHeight(400) -- Set the initial height of the edit box
	editBox:SetScript("OnEscapePressed", function() -- Hide the frame when the escape key is pressed
		frame:Hide()
	end)

	editBox:SetScript("OnTextChanged", function(_, userInput)
		if userInput then
			return
		end

		-- Scroll to the bottom of the text when it changes
		local _, max = scrollArea.ScrollBar:GetMinMaxValues()
		for _ = 1, max do
			ScrollFrameTemplate_OnMouseWheel(scrollArea, -1)
		end
	end)

	scrollArea:SetScrollChild(editBox) -- Set the scroll child of the scroll area to be the edit box
	scrollArea:HookScript("OnVerticalScroll", function(self, offset)
		-- Adjust the hit rect insets of the edit box to account for the scroll position
		editBox:SetHitRectInsets(0, 0, offset, (editBox:GetHeight() - offset - self:GetHeight()))
	end)

	-- Call SimpleCopyChat_OnCreate for each chat window to create a copy button
	for i = 1, NUM_CHAT_WINDOWS do
		SimpleCopyChat_OnCreate(i)
	end
end)

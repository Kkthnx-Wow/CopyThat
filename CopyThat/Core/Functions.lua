--[[
	CopyThat - Functions
	-------------------------------------------------------------------------
	Shared stateless helpers used across the addon.
--]]

local _, ns = ...
local C, F = ns.C, ns.F

local select, type, tostring = select, type, tostring
local floor = math.floor
local format = string.format
local tconcat = table.concat
local wipe = wipe
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME
local tinsert = table.insert

local PREFIX = format("|c%sCopyThat|r:", C.BrandHex)
local printBuffer = {}

function F.Print(...)
	wipe(printBuffer)
	printBuffer[1] = PREFIX
	for i = 1, select("#", ...) do
		printBuffer[i + 1] = tostring((select(i, ...)))
	end
	DEFAULT_CHAT_FRAME:AddMessage(tconcat(printBuffer, " "))
end

function F.CopyDefaults(defaults, target)
	if type(target) ~= "table" then
		target = {}
	end
	for key, value in pairs(defaults) do
		if type(value) == "table" then
			target[key] = F.CopyDefaults(value, target[key])
		elseif target[key] == nil or type(target[key]) ~= type(value) then
			target[key] = value
		end
	end
	return target
end

function F.RGBToHex(r, g, b)
	if type(r) == "table" then
		r, g, b = r[1], r[2], r[3]
	end
	if not (r and g and b) then
		return "ffffffff"
	end
	return format("ff%02x%02x%02x", floor(r * 255), floor(g * 255), floor(b * 255))
end

function F.Colorize(text, color)
	if type(color) == "string" then
		color = C.Colors[color] or C.Colors.white
	end
	return format("|c%s%s|r", F.RGBToHex(color), text)
end

function F.MakeWindowMovable(frame, escapeName)
	if not frame then
		return
	end
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	if escapeName then
		tinsert(_G.UISpecialFrames, escapeName)
	end
end

function F.GetIconPositionOffset(positionKey)
	local pos = C.IconPositions[positionKey] or C.IconPositions.BOTTOMRIGHT
	local x = C.Client.isRetail and pos.retailX or pos.classicX
	return pos.anchor, x, pos.y
end

do
	local issecretvalue = _G.issecretvalue

	function F.IsSecret(value)
		return issecretvalue and issecretvalue(value)
	end

	function F.NotSecret(value)
		return not F.IsSecret(value)
	end
end

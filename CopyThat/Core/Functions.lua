--[[
	CopyThat - Functions
	-------------------------------------------------------------------------
	Shared utility library. Stateless helpers for colour, output, defaults,
	secret-value guards and small UI conveniences.
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

local PREFIX = format("|c%s%s|r:", C.BrandHex, "CopyThat")

-- ---------------------------------------------------------------------------
-- Output
-- ---------------------------------------------------------------------------
local printBuffer = {}

function F.Print(...)
	wipe(printBuffer)
	printBuffer[1] = PREFIX
	for i = 1, select("#", ...) do
		printBuffer[i + 1] = tostring((select(i, ...)))
	end
	DEFAULT_CHAT_FRAME:AddMessage(tconcat(printBuffer, " "))
end

-- ---------------------------------------------------------------------------
-- Colour helpers
-- ---------------------------------------------------------------------------

function F.RGBToHex(r, g, b)
	if type(r) == "table" then
		if r.r then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = r[1], r[2], r[3]
		end
	end
	if not r or not g or not b then
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

-- ---------------------------------------------------------------------------
-- Table helpers
-- ---------------------------------------------------------------------------

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

-- ---------------------------------------------------------------------------
-- UI helpers
-- ---------------------------------------------------------------------------

function F.MakeWindowMovable(frame, escapeName)
	if not frame then
		return
	end
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	if escapeName then
		tinsert(_G["UISpecialFrames"], escapeName)
	end
end

-- ---------------------------------------------------------------------------
-- Secret values (Patch 12.0)
--   Chat content can be secret inside instances. Never boolean-test or do
--   arithmetic on a value that might be secret without a guard first.
-- ---------------------------------------------------------------------------
do
	local issecretvalue = _G["issecretvalue"]
	local canaccessvalue = _G["canaccessvalue"]

	function F.IsSecret(value)
		return issecretvalue and issecretvalue(value)
	end

	function F.NotSecret(value)
		return not F.IsSecret(value)
	end

	function F.CanAccessValue(value)
		return not canaccessvalue or canaccessvalue(value)
	end

	function F.CanNotAccessValue(value)
		return not F.CanAccessValue(value)
	end
end

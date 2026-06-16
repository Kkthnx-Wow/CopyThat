--[[
	CopyThat - Database
	-------------------------------------------------------------------------
	Lightweight saved-variable manager with profile support.

	Layout of `CopyThatDB`:
	    {
	        profiles    = { ["Default"] = { chatCopy = { ... } } },
	        profileKeys = { ["Char - Realm"] = "Default" },
	        global      = { ... account-wide data ... },
	    }

	Migration v1 upgrades the legacy flat Dashi-era `CopyThatDB` table
	(iconAlpha, iconPosition, isEnabled at the root) into the profile layout.
--]]

local _, ns = ...
local C, F = ns.C, ns.F

ns.defaults = {
	profile = {},
	global = {},
}

function ns:RegisterDefaults(defaults, scope)
	scope = scope or "profile"
	F.CopyDefaults(defaults, ns.defaults[scope])
end

local DB_SCHEMA_VERSION = 1

local migrations = {
	-- Dashi stored settings flat on CopyThatDB; fold them into chatCopy defaults.
	[1] = function(root)
		if root.profiles and root.profiles.Default and root.profiles.Default.chatCopy then
			return
		end

		local chatCopy = {}
		if root.iconAlpha ~= nil then
			chatCopy.iconAlpha = root.iconAlpha
		end
		if root.iconPosition ~= nil then
			chatCopy.iconPosition = root.iconPosition
		end
		if root.isEnabled ~= nil then
			chatCopy.enable = root.isEnabled
		end

		if next(chatCopy) then
			root.profiles = root.profiles or {}
			root.profiles.Default = root.profiles.Default or {}
			root.profiles.Default.chatCopy = chatCopy
		end

		root.iconAlpha = nil
		root.iconPosition = nil
		root.isEnabled = nil
	end,
}

local function MigrateDatabase(root)
	local version = root.schemaVersion or 0
	for v = version + 1, DB_SCHEMA_VERSION do
		local step = migrations[v]
		if step then
			step(root)
		end
	end
	root.schemaVersion = DB_SCHEMA_VERSION
end

function ns:SetProfile(profileName)
	local root = _G.CopyThatDB
	root.profileKeys[C.Player.key] = profileName
	root.profiles[profileName] = root.profiles[profileName] or {}

	ns.db = F.CopyDefaults(ns.defaults.profile, root.profiles[profileName])
	ns.profileName = profileName

	if ns.OnProfileChanged then
		ns:OnProfileChanged(profileName)
	end
end

function ns:SetupDatabase()
	local root = _G.CopyThatDB or {}
	_G.CopyThatDB = root
	root.profiles = root.profiles or {}
	root.profileKeys = root.profileKeys or {}
	root.global = F.CopyDefaults(ns.defaults.global, root.global)

	MigrateDatabase(root)

	ns.global = root.global

	local profileName = root.profileKeys[C.Player.key] or "Default"
	ns:SetProfile(profileName)
end

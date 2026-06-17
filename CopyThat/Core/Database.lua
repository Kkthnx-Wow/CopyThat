--[[
	CopyThat - Database
	-------------------------------------------------------------------------
	Lightweight saved-variable manager with a single default profile. Migrates
	legacy flat CopyThatDB keys from the Dashi era into the module layout.
--]]

local _, ns = ...
local F = ns.F

ns.defaults = {
	profile = {},
	global = {},
}

function ns:RegisterDefaults(defaults, scope)
	scope = scope or "profile"
	F.CopyDefaults(defaults, ns.defaults[scope])
end

local function MigrateLegacyFlatKeys(root)
	if type(root.chatCopy) == "table" then
		return
	end
	if root.isEnabled == nil and root.iconAlpha == nil and root.iconPosition == nil then
		return
	end

	root.chatCopy = {
		enable = root.isEnabled ~= false,
		iconAlpha = root.iconAlpha or 0.5,
		iconPosition = root.iconPosition or "BOTTOMRIGHT",
	}
	root.isEnabled = nil
	root.iconAlpha = nil
	root.iconPosition = nil
end

local function MigrateLegacyProfiles(root)
	if root.profiles then
		for _, profile in pairs(root.profiles) do
			MigrateLegacyFlatKeys(profile)
		end
		return
	end

	MigrateLegacyFlatKeys(root)

	root.profiles = { Default = {} }
	for key, value in pairs(root) do
		if key ~= "profiles" and key ~= "profileKeys" and key ~= "global" then
			root.profiles.Default[key] = value
			root[key] = nil
		end
	end
	if not next(root.profiles.Default) then
		root.profiles.Default = nil
	end
end

function ns:SetProfile(profileName)
	local root = _G.CopyThatDB
	root.profileKeys[ns.C.Player.key] = profileName
	root.profiles[profileName] = root.profiles[profileName] or {}

	ns.db = F.CopyDefaults(ns.defaults.profile, root.profiles[profileName])
	ns.profileName = profileName
end

function ns:SetupDatabase()
	local root = _G.CopyThatDB or {}
	_G.CopyThatDB = root
	root.profiles = root.profiles or {}
	root.profileKeys = root.profileKeys or {}
	root.global = F.CopyDefaults(ns.defaults.global, root.global)

	MigrateLegacyProfiles(root)

	local profileName = root.profileKeys[ns.C.Player.key] or "Default"
	ns.global = root.global
	ns:SetProfile(profileName)
end

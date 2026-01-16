--[[-----------------------------------------------------------------------------
-- Addon: CopyThat
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Defines shared data constants and asset paths.
-- - Design: Centralizes asset definitions for consistent use across the addon.
-----------------------------------------------------------------------------]]

local _, namespace = ...

local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT

-- REASON: defines valid font configuration for the edit box
namespace.Font = { STANDARD_TEXT_FONT, 12, "OUTLINE" }

-- REASON: pre-defined texture strings for tutorial frame mouse buttons
namespace.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
namespace.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:410|t "

-- REASON: path to the custom copy button texture
namespace.CopyChatTexture = "Interface\\AddOns\\CopyThat\\Media\\CopyButton.tga"

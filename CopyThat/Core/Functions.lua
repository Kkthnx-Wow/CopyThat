local _, namespace = ...

do
	function namespace:HideTooltip()
		GameTooltip:Hide()
	end

	local function Tooltip_OnEnter(self)
		GameTooltip:SetOwner(self, self.anchor)
		GameTooltip:ClearLines()

		if self.title then
			GameTooltip:AddLine(self.title)
		end

		if self.text then
			local r, g, b = 1, 0.8, 0
			GameTooltip:AddLine(self.text, r, g, b, 1)
		end

		GameTooltip:Show()
	end

	function namespace:AddTooltip(anchor, text, color, showTips)
		self.anchor = anchor
		self.text = text
		self.color = color
		if showTips then
			self.title = namespace.L["Tips"]
		end
		self:SetScript("OnEnter", Tooltip_OnEnter)
		self:SetScript("OnLeave", namespace.HideTooltip)
	end
end

do
	function namespace.HexRGB(r, g, b)
		if r then
			if type(r) == "table" then
				if r.r then
					r, g, b = r.r, r.g, r.b
				else
					r, g, b = unpack(r)
				end
			end
			return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
		end
	end
end

do
	function namespace:TogglePanel(frame)
		if frame:IsShown() then
			frame:Hide()
		else
			frame:Show()
		end
	end
end

local frame = CreateFrame("Frame", nil, Minimap)

local ColorizePVPType = function(pvpType)
	if pvpType == "sanctuary" then
		return {r = 0.41, g = 0.8, b = 0.94}
	elseif pvpType == "friendly" then
		return {r = 0.1, g = 1.0, b = 0.1}
	elseif pvpType == "arena" or pvpType == "hostile" then
		return {r = 1.0, g = 0.1, b = 0.1}
	elseif pvpType == "contested" then
		return {r = 1.0, g = 0.7, b = 0.0}
	else
		return NORMAL_FONT_COLOR
	end	
end

local ColorizeLatency = function(number)
	if number <= 100 then
		return {r = 0, g = 1, b = 0}
	elseif number <= 200 then
		return {r = 1, g = 1, b = 0}
	else
		return {r = 1, g = 0, b = 0}
	end
end

local onEnter = function(self)	
	GameTooltip:SetOwner(TimeManagerClockButton, "ANCHOR_BOTTOMRIGHT")
	
	local zoneName = GetZoneText()
	local subzoneName = GetSubZoneText()
	local zoneColor = ColorizePVPType(GetZonePVPInfo())

	if subzoneName == zoneName then
		subzoneName = ""
	end
	
	GameTooltip:AddLine(zoneName, zoneColor.r, zoneColor.g, zoneColor.b)
	GameTooltip:AddLine(subzoneName, 1, 1, 1)
	
	SetMapToCurrentZone()

	local x, y = GetPlayerMapPosition("player")
	
	if x + y > 0 then
		GameTooltip:AddLine(format("%.1f, %.1f", x * 100, y * 100), 0.7, 0.7, 0.7)
	end
	
	GameTooltip:AddLine("\n")
	
	local latency = select(3, GetNetStats())
	local latencyColor = ColorizeLatency(latency)
	
	GameTooltip:AddLine(string.format("Latency: %d ms", latency), latencyColor.r, latencyColor.g, latencyColor.b)
	GameTooltip:AddLine(string.format("Framerate: %.1f", GetFramerate()), 1, 1, 1)
	
	GameTooltip:Show()
end

local onMouseWheel = function(self, direction)
    if not direction then return end
    if direction > 0 and Minimap:GetZoom() < 5 then
        Minimap:SetZoom(Minimap:GetZoom() + 1)
    elseif direction < 0 and Minimap:GetZoom() > 0 then
        Minimap:SetZoom(Minimap:GetZoom() - 1)
    end
end

local onEvent = function(self, event)
	frame:EnableMouse(false)
	frame:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
	frame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT")
	frame:EnableMouseWheel(true)
	frame:SetScript("OnMouseWheel", onMouseWheel)
	
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	MiniMapWorldMapButton:Hide()
	MinimapZoneTextButton:Hide()
	MinimapBorderTop:Hide()
	MinimapNorthTag:Hide()
	
	-- Time
	TimeManagerClockButton:SetScript("OnEnter", onEnter)
	TimeManagerClockButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

frame:SetScript("OnEvent", onEvent)

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
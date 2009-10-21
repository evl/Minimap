local evl_Minimap = CreateFrame("Frame", nil, Minimap)

local AddonsMemoryCompare = function(a, b)
	return a.memory > b.memory
end

local FormatMemoryNumber = function(number)
	if number > 1000 then
		return string.format("%.2f mb", number / 1000)
	else
		return string.format("%.1f kb", number)
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

local zoneName, zoneColor, subzoneName
local memoryFormat = "%.2f %s"
local latency, latencyColor, addons, totalMemory
local memory, addon, i
local onEnter = function(self)	
	GameTooltip:SetOwner(TimeManagerClockButton, "ANCHOR_BOTTOMRIGHT")
	
	zoneName = GetZoneText()
	subzoneName = GetSubZoneText()
	zoneColor = ColorizePVPType(GetZonePVPInfo())

	if subzoneName == zoneName then
		subzoneName = ""
	end
	
	GameTooltip:AddLine(zoneName, zoneColor.r, zoneColor.g, zoneColor.b)
	GameTooltip:AddLine(subzoneName, 1, 1, 1)
	GameTooltip:AddLine("\n")
	
	latency = select(3, GetNetStats())
	latencyColor = ColorizeLatency(latency)
	
	GameTooltip:AddLine(string.format("Latency: %d ms", latency), latencyColor.r, latencyColor.g, latencyColor.b)
	GameTooltip:AddLine(string.format("Framerate: %.1f", GetFramerate()), 1, 1, 1)
	GameTooltip:AddLine("\n")
	
	addons = {}
	totalMemory = 0
	
	UpdateAddOnMemoryUsage()

	for i=1, GetNumAddOns(), 1 do
		memory = GetAddOnMemoryUsage(i)
		addon = {name = GetAddOnInfo(i), memory = memory}
		table.insert(addons, addon)
		
		totalMemory = totalMemory + memory
	end
	
	table.sort(addons, AddonsMemoryCompare)
	
	i = 0
	for _, addon in pairs(addons) do
		GameTooltip:AddDoubleLine(addon.name, FormatMemoryNumber(addon.memory), 1, 1, 1, 1, 1, 1)
		
		i = i + 1
		
		if i >= 10 then
			break
		end
	end
	
	GameTooltip:AddLine("\n")
	GameTooltip:AddDoubleLine("Total", FormatMemoryNumber(totalMemory), 1, 1, 0, 1, 1, 0)
	
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
	self:EnableMouse(false)
	self:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
	self:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT")
	self:EnableMouseWheel(true)
	self:SetScript("OnMouseWheel", onMouseWheel)
	
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	MiniMapWorldMapButton:Hide()
	MinimapToggleButton:Hide()
	MinimapZoneTextButton:Hide()
	MinimapBorderTop:Hide()
	MinimapNorthTag:Hide()
	
	-- Time
	TimeManagerClockButton:SetScript("OnEnter", onEnter)
	TimeManagerClockButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

	-- Tracking
	--[[
	MiniMapTrackingBorder:Hide()
	MiniMapTrackingBackground:Hide()
	MiniMapTracking:SetParent(Minimap)
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint("TOPLEFT")
	--MiniMapTracking:Hide()
	]]

	-- Battlefield
	--[[
	MiniMapBattlefieldBorder:Hide()
	MiniMapBattlefieldFrame:SetParent(Minimap)
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint("TOPRIGHT", 0, -3)
	]]

	-- Mail
	--[[
	MiniMapMailBorder:Hide()
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint("TOP")
	MiniMapMailIcon:SetTexture("Interface\\AddOns\\evl_Art\\mail")
	]]
end

evl_Minimap:SetScript("OnEvent", onEvent)
evl_Minimap:RegisterEvent("PLAYER_ENTERING_WORLD")
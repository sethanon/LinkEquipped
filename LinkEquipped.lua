-----------------------------------------------------------------------------------------------
-- Client Lua Script for LinkEquipped
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"
require "Apollo"
require "GroupLib"
require "Item"
require "GameLib"

local LinkEquipped = {}

local tInventoryId = {
	[0] = true, --Head
	[1] = true, --Legs
	[2] = true, --Helm
	[3] = true, --Shoulders
	[4] = true, --Feet
	[5] = true, --Gloves
	[7] = true, --Weapon Attachment
	[8] = true, --Support System
	[10] = true, --Implant
	[11] = true, --Gadget
	[15] = true, --Shield
	[16] = true  --Weapon
	}

-----------------------------------------------------------------------------------------------
-- Initialization Functions
-----------------------------------------------------------------------------------------------
function LinkEquipped:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	return o
end

function LinkEquipped:Init()
	Apollo.RegisterAddon(self)
end

function LinkEquipped:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("LinkEquipped.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self)
end

function LinkEquipped:OnDocumentReady()
	if  self.xmlDoc == nil then
		return
	end

	Apollo.RegisterEventHandler("MasterLootUpdate",	"OnMasterLootUpdate", self)
	Apollo.RegisterEventHandler("LootAssigned",	"OnLootAssigned", self)
	Apollo.RegisterEventHandler("Group_Updated", "OnGroupUpdated", self)
	

	-- LinkEquipped Window
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "LinkEquipped", nil, self)
	-- Equipped Item List
	self.wndEquippedList = self.wndMain:FindChild("EquippedList")
	-- Hide the main window
	self.wndMain:Show(false)
	

	Apollo.RegisterSlashCommand("le","OnLinkEquipped",self)

	-- Global Vars
	self.oLeader = 0
	self.tEquippedItems = {}
	self.tEquippedList = {}
	self.oItemSelected = nil
end

-----------------------------------------------------------------------------------------------
-- LinkEquipped Functions
-----------------------------------------------------------------------------------------------

function LinkEquipped:OnLinkEquipped()
	if self.wndMain:IsShown() then
		self.wndMain:Show(false)
	else
		self.wndMain:Show(true)
		self:GetEquippedItems()
		self:FillEquippedList()
		--self:GetGroupLeader()
		--if GroupLib.GetGroupMaxSize() > 0 then
		--	self.wndMain:FindChild("Player"):SetText("/w "..oLeader:GetName())
		--end
	end
end

--function LinkEquipped:GetGroupLeader()
--	local tGroupMembers = {}
--	local oLeader = 0
--	for i=1, GroupLib.GetGroupMaxSize() do
--		tGroupMembers[i] = GroupLib.GetGroupMember(i)
--		if tGroupMembers.bIsLeader then oLeader = tGroupMembers end
--	end
--end

function LinkEquipped:GetEquippedItems()
	-- Get Everything Equipped
	self.tEquippedItems = {}
	self.tEquippedList = {}
	self.tEquippedItems = GameLib.GetPlayerUnit():GetEquippedItems()
	
	-- Filter the list for only the slots that matter
	for itemIndex, itemInfo in next, self.tEquippedItems do 
		if tInventoryId[itemInfo:GetInventoryId()] then
			table.insert(self.tEquippedList, itemInfo)
		end
	end
end

function LinkEquipped:FillEquippedList()
	self.wndEquippedList:DestroyChildren()
	
	for idx, tItem in ipairs (self.tEquippedList) do
		local wndCurrentItem = Apollo.LoadForm(self.xmlDoc, "ItemButton", self.wndEquippedList, self)
		wndCurrentItem:FindChild("ItemIcon"):SetSprite(self.tEquippedList[idx]:GetIcon())
		wndCurrentItem:FindChild("ItemName"):SetText(self.tEquippedList[idx]:GetName())
		wndCurrentItem:SetData(self.tEquippedList[idx])
		Tooltip.GetItemTooltipForm(self, wndCurrentItem , self.tEquippedList[idx], {bPrimary = true, bSelling = false})
	end
	
	self.wndEquippedList:ArrangeChildrenVert(0)
end

function LinkEquipped:OnInsertLinkBtn( wndHandler, wndControl, eMouseButton )
	if self.oItemSelected ~= nil then 
	--	ChatSystemLib.Command("/w "..strPlayer.." Link Incoming")
		Event_FireGenericEvent("ItemLink", self.oItemSelected)
	else
		Print("No Item Selected")
	end	
end

-----------------------------------------------------------------------------------------------
-- Form and Button Functions
-----------------------------------------------------------------------------------------------

function LinkEquipped:OnItemCheck(wndHandler, wndControl, eMouseButton)
	self.oItemSelected = wndHandler:GetData()
end

function LinkEquipped:OnItemUncheck(wndHandler, wndControl, eMouseButton)
	self.oItemSelected = nil
end

function LinkEquipped:OnCloseBtn( wndHandler, wndControl, eMouseButton )
	self.wndMain:Show(false)
end

-----------------------------------------------------------------------------------------------
-- ThreatWarning Instance
-----------------------------------------------------------------------------------------------
local LinkEquippedInst = LinkEquipped:new()
LinkEquippedInst:Init()
	


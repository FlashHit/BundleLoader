--[[
Copyright (c) [2023] [Flash_Hit a/k/a Bree_Arnold]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
--]]

if Class then
	-- Using LoggingClass
	---@class BundleLoader:Class
	---@overload fun(configs: table, commonConfig: table):BundleLoader
	---@diagnostic disable-next-line: assign-type-mismatch
	BundleLoader = Class("BundleLoader")
else
	BundleLoader = class("BundleLoader")
	function BundleLoader:debug(...)
		print(...)
	end
end

function BundleLoader:__init(configs, commonConfig)
	self.currentConfig = {}
	self.configs = configs
	self.commonConfig = commonConfig

	Hooks:Install("Terrain:Load", 999, self, self.OnTerrainLoad)
	Hooks:Install("VisualTerrain:Load", 999, self, self.OnTerrainLoad)
	Events:Subscribe('Level:RegisterEntityResources', self, self.OnLevelRegisterEntityResources)

	return self
end

function BundleLoader:UpdateConfig()
	local s_LevelName = SharedUtils:GetLevelName()
	self.currentConfig = self.configs[s_LevelName] or {}
end

function BundleLoader:GetBundles(p_Bundles, p_Compartment)
	local s_Bundles = {}
	self:debug("Loading compartment %s", p_Compartment)

	if self.commonConfig.bundles and self.commonConfig.bundles[p_Compartment] then
		self:debug("Common Config Bundles:")
		for l_Index, l_Bundle in ipairs(self.commonConfig.bundles[p_Compartment]) do
			self:debug("%s: %s", l_Index, l_Bundle)
			table.insert(s_Bundles, l_Bundle)
		end
	end

	if self.currentConfig.bundles and self.currentConfig.bundles[p_Compartment] then
		self:debug("Current Config Bundles:")
		for l_Index, l_Bundle in ipairs(self.currentConfig.bundles[p_Compartment]) do
			self:debug("%s: %s", l_Index, l_Bundle)
			table.insert(s_Bundles, l_Bundle)
		end
	end

	self:debug("Game Bundles:")
	for l_Index, l_Bundle in ipairs(p_Bundles) do
		self:debug("%s: %s", l_Index, l_Bundle)
		table.insert(s_Bundles, l_Bundle)
	end

	return s_Bundles
end

function BundleLoader:OnMountSuperBundles()
	if self.commonConfig.superBundles then
		for l_Index, l_SuperBundle in ipairs(self.commonConfig.superBundles) do
			self:debug("Mounting Common SuperBundle %s: %s.", l_Index, l_SuperBundle)
			ResourceManager:MountSuperBundle(l_SuperBundle)
		end
	end

	if self.currentConfig.superBundles then
		for l_Index, l_SuperBundle in ipairs(self.currentConfig.superBundles) do
			self:debug("Mounting SuperBundle %s: %s.", l_Index, l_SuperBundle)
			ResourceManager:MountSuperBundle(l_SuperBundle)
		end
	end

	self:debug("Mounted all SuperBundles.")
end

function BundleLoader:AddRegistries(p_Registries)
	for l_Compartment, l_Names in pairs(p_Registries) do
		for _, l_Name in ipairs(l_Names) do
			self:debug("Adding RegistryContainer from '%s' to compartment %s.", l_Name, l_Compartment)
			local s_SubWorldData = ResourceManager:SearchForDataContainer(l_Name)

			if not s_SubWorldData then
				self:error("Failed to find the SubWorldData for '%s'.", l_Name)
				return
			end

			s_SubWorldData = SubWorldData(s_SubWorldData)

			if not s_SubWorldData.registryContainer then
				self:error("Failed to find the RegistryContainer to add for '%s'.", l_Name)
				return
			end

			ResourceManager:AddRegistry(s_SubWorldData.registryContainer, l_Compartment)
		end
	end
end

---VEXT Shared Level:RegisterEntityResources Event
---@param p_LevelData DataContainer|LevelData @needs to be upcasted to LevelData
function BundleLoader:OnLevelRegisterEntityResources(p_LevelData)
	if self.commonConfig.registries then
		self:AddRegistries(self.commonConfig.registries)
	end

	if self.currentConfig.registries then
		self:AddRegistries(self.currentConfig.registries)
	end
end

---VEXT Shared ResourceManager:LoadBundles Hook
---@param p_HookCtx HookContext
---@param p_Bundles string[]
---@param p_Compartment ResourceCompartment|integer
function BundleLoader:OnLoadBundles(p_HookCtx, p_Bundles, p_Compartment)
	if p_Compartment == ResourceCompartment.ResourceCompartment_Game then
		self:UpdateConfig()
		self:OnMountSuperBundles()
	end

	p_HookCtx:Pass(self:GetBundles(p_Bundles, p_Compartment), p_Compartment)
end

---VEXT Shared VisualTerrain:Load Hook
---VEXT Shared Terrain:Load Hook
---@param p_HookCtx HookContext
---@param p_TerrainName string
function BundleLoader:OnTerrainLoad(p_HookCtx, p_TerrainName)
	if self.currentConfig.terrainAssetName == nil then
		self:warn("No terrain asset name specified. This means every terrain will be loaded.")
		self:warn("Loading terrain '%s'", p_TerrainName)
		return
	end

	if not string.find(p_TerrainName:lower(), self.currentConfig.terrainAssetName:lower()) then
		self:debug("Preventing load of terrain: " .. p_TerrainName)
		p_HookCtx:Return()
	end
end

--[[
        Copyright © 2020, SirEdeonX, Akirane
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of xivhotbar nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL SirEdeonX OR Akirane BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

--local storage = require('storage')
local action_manager = require('action_manager')
require('luau')
str = require('strings')
texts = require('texts')
local player = {}

buff_table = {
    [211] = 'Light Arts',
    [212] = 'Dark Arts',
	-- Avatars
	[1001] = 'Carbuncle',
	[1002] = 'Ifrit',
	[1003] = 'Shiva',
	[1004] = 'Leviathan',
	[1005] = 'Ramuh',
	[1006] = 'Fenrir',
	[1007] = 'Diabolos',
	[1008] = 'Alexander',
	[1009] = 'Cait Sith',
	[1010] = 'Garuda',
	[1011] = 'Odin',
	[1012] = 'Titan',
	[1013] = 'Atomos',
	-- Weapons
	[2001] = 'Sword',
	[2002] = 'Dagger',
	[2003] = 'Club',
}

player.name = ''
player.main_job = ''
player.sub_job = ''
player.server = ''

player.vitals = {}
player.vitals.mp = 0
player.vitals.tp = 0
player.id = 0

player.hotbar = {}

player.hotbar_settings = {}
player.hotbar_settings.max = 1
player.hotbar_settings.active_hotbar = 1
player.hotbar_settings.active_environment = 'battle'

_innerG = {}
_innerG.xivhotbar_keybinds_job = {}
general_table = {}
general_table.xivhotbar_keybinds_general = {}

function create_table(_new_table, _table_key)
    setmetatable(_new_table, {
    __index = function(g, k)
        local t = rawget(rawget(g, table_key), k)
        if not t then
            t = {}
            rawset(rawget(g, table_key), k, t)
        end
        return t
    end,
    __newindex = function(g, k, v)
        local t = rawget(rawget(g, table_key), k)
        if t and type(v) == 'table' then
            for k, v in pairs(v) do
                t[k] = v
            end
        end
    end
})
end

local keybinds_job_table = {
    __index = function(g, k)
        local t = rawget(rawget(g, 'xivhotbar_keybinds_job'), k)
        if not t then
            t = {}
            rawset(rawget(g, 'xivhotbar_keybinds_job'), k, t)
        end
        return t
    end,
    __newindex = function(g, k, v)
        local t = rawget(rawget(g, 'xivhotbar_keybinds_job'), k)
        if t and type(v) == 'table' then
            for k, v in pairs(v) do
                t[k] = v
            end
        end
    end
}

local general_keybinds_table = {
    __index = function(g, k)
        local t = rawget(rawget(g, 'xivhotbar_keybinds_general'), k)
        if not t then
            t = {}
            rawset(rawget(g, 'xivhotbar_keybinds_general'), k, t)
        end
        return t
    end,
    __newindex = function(g, k, v)
        local t = rawget(rawget(g, 'xivhotbar_keybinds_general'), k)
        if t and type(v) == 'table' then
            for k, v in pairs(v) do
                t[k] = v
            end
        end
    end
}

-- Initialize keybinds tables
setmetatable(_innerG, keybinds_job_table)
--setmetatable(_innerJ, keybinds_job_table)
setmetatable(general_table, general_keybinds_table)

-- initialize player
function player:initialize(windower_player, server, theme_options)
    self.name = windower_player.name
    self.main_job = windower_player.main_job
    self.sub_job = windower_player.sub_job
    self.server = server
    self.buffs = windower_player.buffs
    self.id = windower_player.id
    self.hotbar_settings.max = theme_options.hotbar_number
    self.vitals.mp = windower_player.vitals.mp
    self.vitals.tp = windower_player.vitals.tp
    --storage:setup(self)
end

-- update player jobs
function player:update_jobs(main, sub)
    self.main_job = main
    self.sub_job = sub

    --storage:update_filename(main, sub)
end

function player:update_id(new_id)
    self.id = new_id
end

-- load hotbar for current player and job combination
function player:load_hotbar()
    self:reset_hotbar()
    self:load_from_lua() 
end

subjob_actions = {}
actions = {}
general_actions = {}
local job_ability_actions = {}

local function fill_table(file_table, file_key, actions_table)
	-- Slot_key is for example 'battle 1 2' in a job file.
	local slot_key = T(file_table[1]:split(' '))
	actions_table.environment[file_key] = slot_key[1]
	actions_table.hotbar[file_key]      = slot_key[2]
	actions_table.slot[file_key]        = slot_key[3]
	actions_table.type[file_key]        = file_table[2]
	actions_table.action[file_key]      = file_table[3]
	actions_table.target[file_key]      = file_table[4]
	actions_table.alias[file_key]       = file_table[5]
	if (file_table[6] ~= nil) then
		actions_table.icon[file_key]    = file_table[6]
	end
end

function player:add_actions(action_table)
    for key in pairs(action_table.environment) do 
        self:add_action(
			action_manager:build(
				action_table.type[key], 
				action_table.action[key], 
				action_table.target[key], 
				action_table.alias[key], 
				action_table.icon[key] 
			),
            action_table.environment[key],
            action_table.hotbar[key],
            action_table.slot[key]
        )
    end
end

local function remove_actions(action_table)
	for key, val in pairs(action_table.environment) do
		self:remove_action(action_table.environment[key],
							action_table.hotbar[key],
							action_table.slot[key])
	end
end

local function parse_binds(fhotbar)
	for key, val in pairs(fhotbar['Base']) do
		fill_table(fhotbar['Base'][key], key, actions)
	end
	if (fhotbar[player.sub_job] ~= nil) then
		for key, val in pairs(fhotbar[player.sub_job]) do
			fill_table(fhotbar[player.sub_job][key], key, subjob_actions)
		end
	else
		for key, val in pairs(subjob_actions.environment) do
			self:remove_action()
		end
		subjob_actions = {}
	end
end

local function parse_general_binds(hotbar)
	for key, val in pairs(hotbar['Root']) do
		fill_table(hotbar['Root'][key], key, general_actions)
	end
end

function init_action_table(actions_table)
    actions_table.environment = {}
    actions_table.hotbar = {}
    actions_table.slot = {}
    actions_table.type = {}
    actions_table.action = {}
    actions_table.target = {}
    actions_table.alias = {}
	actions_table.icon = {}
end

function player:load_job_ability_actions(buff_id)

    if (job_ability_actions.environment ~= nil) then
        if (table.getn(job_ability_actions.environment) ~= 0) then
			remove_actions(job_ability_actions.environment)
        end
    end

    init_action_table(job_ability_actions)

    local basepath = windower.addon_path .. 'data/'..player.name..'/'
	local job_file = loadfile(basepath .. player.main_job .. '.lua')
	local stance_actions = {}
	stance_actions.xivhotbar_keybinds_job = {}
	setmetatable(stance_actions, keybinds_job_table)
    if job_file == nil then 
        print("Error, couldn't find %s job_file!":format(player.main_job))
		return
    else
        setfenv(job_file, stance_actions)
        local root = job_file()
        if not root then
            stance_actions.xivhotbar_keybinds_job = {}
            stance_actions.binds = {}
            return
        end
        stance_actions.xivhotbar_keybinds_job = {}
        stance_actions.xivhotbar_keybinds_job[root] = stance_actions.xivhotbar_keybinds_job[root] or 'Root'
        parse_binds(root)
    end
	self:add_actions(stance_actions)
end

-- load a hotbar from existing lua file
function player:load_from_lua()

    init_action_table(subjob_actions)
    init_action_table(actions)
    init_action_table(general_actions)

    local basepath = windower.addon_path .. 'data/'..player.name..'/'
    local file = loadfile(basepath .. player.main_job .. '.lua')
    local general_file = loadfile(basepath .. 'General.lua')
    if file == nil then 
        print("Error, couldn't find %s file!":format(player.main_job))
    else
        setfenv(file, _innerG)
        local root = file()
        if not root then
            _innerG.xivhotbar_keybinds_job = {}
            _innerG._binds = {}
            return
        end
        _innerG.xivhotbar_keybinds_job = {}
        _innerG.xivhotbar_keybinds_job[root] = _innerG.xivhotbar_keybinds_job[root] or 'Root'
        parse_binds(root)

		self:add_actions(actions)
        if (subjob_actions.environment ~= nil) then
			self:add_actions(subjob_actions)
        end
    end

    if general_file == nil then 
        print("Error, couldn't find file 'General.lua'")
    else
        setfenv(general_file, general_table)
        local general_root = general_file()
        if not general_root then
            general_table.xivhotbar_keybinds_general = {}
            general_table.binds = {}
            return
        end
        general_table.xivhotbar_keybinds_general = {}
        general_table.xivhotbar_keybinds_general[general_root] = general_table.xivhotbar_keybinds_general[general_root] or 'Root'
        parse_general_binds(general_root)

		self:add_actions(general_actions)
    end
end

-- create a default hotbar
function player:create_default_hotbar()
    windower.console.write('XIVHotbar: no hotbar found. Creating a default hotbar.')

    -- add default actions to the new hotbar
    self:add_action(action_manager:build_custom('attack on', 'Attack', 'attack'), 'field', 1, 1)
    self:add_action(action_manager:build_custom('check', 'Check', 'check'), 'field', 1, 2)
    self:add_action(action_manager:build_custom('returntrust all', 'No Trusts', 'return-trust'), 'field', 1, 9)
    self:add_action(action_manager:build_custom('heal', 'Heal', 'heal'), 'field', 1, 0)
    self:add_action(action_manager:build_custom('check', 'Check', 'check'), 'battle', 1, 9)
    self:add_action(action_manager:build_custom('attack off', 'Disengage', 'disengage'), 'battle', 1, 0)
end

-- reset player hotbar
function player:reset_hotbar()
    self.hotbar = {
        ['battle'] = {},
        ['field'] = {}
    }

    for h=1,self.hotbar_settings.max,1 do
        self.hotbar.field['hotbar_' .. h] = {}
        self.hotbar.battle['hotbar_' .. h] = {}
    end

    self.hotbar_settings.active_hotbar = 1
end

-- toggle bar environment
function player:toggle_environment()
    if self.hotbar_settings.active_environment == 'battle' then
        self.hotbar_settings.active_environment = 'field'
    else
        self.hotbar_settings.active_environment = 'battle'
    end
end

-- set bar environment to battle
function player:set_battle_environment(in_battle)
    local environment = 'field'
    if in_battle then environment = 'battle' end

    self.hotbar_settings.active_environment = environment
end

-- change active hotbar
function player:change_active_hotbar(new_hotbar)
    self.hotbar_settings.active_hotbar = new_hotbar

    if self.hotbar_settings.active_hotbar > self.hotbar_settings.max then
        self.hotbar_settings.active_hotbar = 1
    end
end

-- add given action to a hotbar
function player:add_action(action, environment, hotbar, slot)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    if slot == 10 then slot = 0 end
    -- print(environment)

    if self.hotbar[environment] == nil then
        windower.console.write('XIVHOTBAR: invalid hotbar (environment)')
        return
    end

    if self.hotbar[environment]['hotbar_' .. hotbar] == nil then
        windower.console.write('XIVHOTBAR: invalid hotbar (hotbar number)')
        return
    end

    if self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] == nil then
        self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] = {}
    end

    self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] = action
end

function player:determine_summoner_id(pet_name)
	for buff_id, buff_name in pairs(buff_table) do
		if buff_name == pet_name then
			return buff_id
		end
	end
	return 0
end

-- execute action from given slot
function player:execute_action(slot)
    local action = self.hotbar[self.hotbar_settings.active_environment]['hotbar_' .. self.hotbar_settings.active_hotbar]['slot_' .. slot]

    if action == nil then return end

    if action.type == 'ct' then
        local command = '/' .. action.action

        if  action.target ~= nil and action.target ~= "" then
			print("Target is not nil.")
			print(action.target)
            command = command .. ' <' ..  action.target .. '>'
        end

        windower.chat.input(command)
        return
	elseif action.type == 'macro' then
        windower.chat.input('//'.. action.action)
    elseif action.type == 'ws' then
        windower.chat.input('//'.. action.action .. ' <' .. action.target .. '>')

    elseif action.type == 'gs' then
        windower.chat.input('//gs ' .. action.action)
    elseif action.type == 's' then
        windower.chat.input('//send ' .. action.action)
    else
        windower.chat.input('/' .. action.type .. ' "' .. action.action .. '" <' .. action.target .. '>')
    end
end

-- remove action from slot
function player:remove_action(environment, hotbar, slot)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    if slot == 10 then slot = 0 end

    if self.hotbar[environment] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar] == nil then return end

    self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] = nil
end

-- copy action from one slot to another
function player:copy_action(environment, hotbar, slot, to_environment, to_hotbar, to_slot, is_moving)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    if to_environment == 'b' then to_environment = 'battle' elseif to_environment == 'f' then to_environment = 'field' end
    if slot == 10 then slot = 0 end
    if to_slot == 10 then to_slot = 0 end

    if self.hotbar[environment] == nil or self.hotbar[to_environment] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar] == nil or self.hotbar[to_environment]['hotbar_' .. to_hotbar] == nil then return end

    self.hotbar[to_environment]['hotbar_' .. to_hotbar]['slot_' .. to_slot] = self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot]

    if is_moving then self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] = nil end
end

-- update action alias
function player:set_action_alias(environment, hotbar, slot, alias)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    if slot == 10 then slot = 0 end

    if self.hotbar[environment] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] == nil then return end

    self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot].alias = alias
end

-- update action icon
function player:set_action_icon(environment, hotbar, slot, icon)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    if slot == 10 then slot = 0 end

    if self.hotbar[environment] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] == nil then return end

    self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot].icon = icon
end

-- save current hotbar
function player:save_hotbar()
    local new_hotbar = {}
    new_hotbar.hotbar = self.hotbar

    --storage:save_hotbar(new_hotbar)
end

return player

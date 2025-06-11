--- STEAMODDED HEADER
--- MOD_NAME: Naruto Test Mod
--- MOD_ID: MyNinjaWay
--- MOD_AUTHOR: [elmakas666]
--- MOD_DESCRIPTION: A little project of my own to mod balatro using one of my favourite shows
--- DEPENDENCIES: [Steamodded>=1.0.0~BETA]
--- MOD_VERSION: 0.1
--- MOD_LICENSE: MIT

----------------------------------------------
---------------- MOD INITIALIZATION ----------
----------------------------------------------

-- Initialize mod namespace
if not MyNinjaWay then
    MyNinjaWay = {}
end

-- Store mod path
local mod_path = "" .. SMODS.current_mod.path
MyNinjaWay.path = mod_path
MyNinjaWay_config = SMODS.current_mod.config

-- Debug mode configuration
MyNinjaWay.debug_mode = false

-- Mod registry for objects
MyNinjaWay.object_registry = {}
MyNinjaWay.object_buffer = {}

----------------------------------------------
---------------- UTILITY FUNCTIONS -----------
----------------------------------------------

-- Debug function
local function debug_log(message)
    if MyNinjaWay.debug_mode then
        print("[MyNinjaWay] " .. tostring(message))
    end
end

-- Load library files (if you have a lib folder later)
local function load_library_files()
    local lib_path = mod_path .. "lib"
    if NFS.getInfo(lib_path) then
        local files = NFS.getDirectoryItems(lib_path)
        for _, file in ipairs(files) do
            if string.sub(file, -4) == ".lua" then
                debug_log("Loading library file: " .. file)
                local f, err = SMODS.load_file("lib/" .. file)
                if err then
                    error("[MyNinjaWay] Error loading lib/" .. file .. ": " .. err)
                else
                    f()
                end
            end
        end
    end
end

-- Process items function (based on Cryptid's approach)
local function process_items(f, mod)
    local ret = f()
    if not ret or ret.disabled then
        return
    end
    
    if ret.init then
        ret:init()
    end
    
    if ret.items then
        for _, item in ipairs(ret.items) do
            if mod then
                -- Handle mod prefixes
                item.prefix_config = {
                    key = false,
                    atlas = false,
                }
                item.mod_path = mod.path
                
                if item.key then
                    if item.object_type and SMODS[item.object_type].class_prefix then
                        item.key = SMODS[item.object_type].class_prefix .. "_" .. mod.prefix .. "_" .. item.key
                    elseif string.find(item.key, mod.prefix .. "_") ~= 1 then
                        item.key = mod.prefix .. "_" .. item.key
                    end
                end
                
                if item.atlas and string.find(item.atlas, mod.prefix .. "_") ~= 1 then
                    item.atlas = mod.prefix .. "_" .. item.atlas
                end
                
                if not item.dependencies then
                    item.dependencies = {}
                end
                item.dependencies[#item.dependencies + 1] = mod.id
            end
            
            if item.init then
                item:init()
            end
            
            -- Register object
            if not MyNinjaWay.object_registry[item.object_type] then
                MyNinjaWay.object_registry[item.object_type] = {}
            end
            
            if not item.take_ownership then
                if not item.order then
                    item.order = 0
                end
                if ret.order then
                    item.order = item.order + ret.order
                end
                if mod then
                    item.order = item.order + 1e9
                end
                
                if not MyNinjaWay.object_buffer[item.object_type] then
                    MyNinjaWay.object_buffer[item.object_type] = {}
                end
                MyNinjaWay.object_buffer[item.object_type][#MyNinjaWay.object_buffer[item.object_type] + 1] = item
            else
                item.key = SMODS[item.object_type].class_prefix .. "_" .. item.key
                SMODS[item.object_type].obj_table[item.key].mod = SMODS.Mods.MyNinjaWay
                for k, v in pairs(item) do
                    if k ~= "key" then
                        SMODS[item.object_type].obj_table[item.key][k] = v
                    end
                end
            end
            
            MyNinjaWay.object_registry[item.object_type][item.key] = item
        end
    end
end

----------------------------------------------
---------------- ATLASES & SOUNDS -----------
----------------------------------------------

-- Atlas for Naruto jokers
SMODS.Atlas{
    key = 'naruto_jokers',
    path = 'naruto_jokers.png',
    px = 71,
    py = 95
}

-- Sound effects
SMODS.Sound{
    key = 'kakashi_activate',
    path = 'copy_ninja.ogg',
    pitch = 1,
    volume = 0.8
}

SMODS.Sound{
    key = 'naruto_rasengan',
    path = 'kakashi_sound.ogg',
    pitch = 1,
    volume = 0.7
}

----------------------------------------------
---------------- LOAD ITEMS ------------------
----------------------------------------------

-- Load library files first
load_library_files()

-- Load items from the items folder
local items_path = mod_path .. "items"
if NFS.getInfo(items_path) then
    local files = NFS.getDirectoryItems(items_path)
    for _, file in ipairs(files) do
        if string.sub(file, -4) == ".lua" then
            debug_log("Loading item file: " .. file)
            local f, err = SMODS.load_file("items/" .. file)
            if err then
                error("[MyNinjaWay] Error loading items/" .. file .. ": " .. err)
            else
                process_items(f)
            end
        end
    end
end

-- Check for integration files in other mods
for _, mod in pairs(SMODS.Mods) do
    if not mod.disabled and mod.path and mod.id ~= "MyNinjaWay" then
        local path = mod.path
        local files = NFS.getDirectoryItems(path)
        for _, file in ipairs(files) do
            -- Check for MyNinjaWay.lua integration file
            if file == "MyNinjaWay.lua" then
                debug_log("Loading MyNinjaWay.lua from " .. mod.id)
                local f, err = SMODS.load_file("MyNinjaWay.lua", mod.id)
                if err then
                    error("[MyNinjaWay] Error loading integration from " .. mod.id .. ": " .. err)
                else
                    process_items(f, mod)
                end
            end
            -- Check for MyNinjaWay folder
            if file == "MyNinjaWay" then
                local integration_files = NFS.getDirectoryItems(path .. "MyNinjaWay")
                for _, integration_file in ipairs(integration_files) do
                    if string.sub(integration_file, -4) == ".lua" then
                        debug_log("Loading integration file " .. integration_file .. " from " .. mod.id)
                        local f, err = SMODS.load_file("MyNinjaWay/" .. integration_file, mod.id)
                        if err then
                            error("[MyNinjaWay] Error loading integration: " .. err)
                        else
                            process_items(f, mod)
                        end
                    end
                end
            end
        end
    end
end

----------------------------------------------
---------------- REGISTER OBJECTS -----------
----------------------------------------------

-- Register all buffered items
for set, objs in pairs(MyNinjaWay.object_buffer) do
    table.sort(objs, function(a, b)
        return a.order < b.order
    end)
    for i = 1, #objs do
        if objs[i].post_process and type(objs[i].post_process) == "function" then
            objs[i]:post_process()
        end
        SMODS[set](objs[i])
    end
end

----------------------------------------------
---------------- UTILITY FUNCTIONS -----------
----------------------------------------------

MyNinjaWay.utils = {
    -- Debug function
    debug = function(message)
        debug_log(message)
    end,
    
    -- Check if card is a Naruto joker
    is_naruto_joker = function(card)
        if not card or not card.ability then return false end
        return card.ability.set == 'Joker' and 
               card.config and 
               card.config.center and 
               string.find(card.config.center.key or "", "j_myninjaway_") == 1
    end,
    
    -- Count specific cards in deck
    count_cards_in_deck = function(rank)
        local count = 0
        for k, v in pairs(G.playing_cards) do
            if v:get_id() == rank then
                count = count + 1
            end
        end
        return count
    end,
    
    -- Check if hand contains specific poker hand
    check_poker_hand = function(hand_name)
        return G.GAME.current_round.current_hand.handname == hand_name
    end
}

----------------------------------------------
---------------- POST PROCESS ---------------
----------------------------------------------

-- Update object registry
MyNinjaWay.update_obj_registry = function()
    for object_type, objects in pairs(MyNinjaWay.object_registry) do
        for key, obj in pairs(objects) do
            if SMODS[object_type] and SMODS[object_type].obj_table and SMODS[object_type].obj_table[key] then
                MyNinjaWay.object_registry[object_type][key] = SMODS[object_type].obj_table[key]
            end
        end
    end
end

----------------------------------------------
---------------- INJECTION HOOK -------------
----------------------------------------------

-- Hook into SMODS injection system
local original_inject = SMODS.injectItems
function SMODS.injectItems(...)
    original_inject(...)
    MyNinjaWay.update_obj_registry()
    
    -- Auto-unlock in debug mode or if profile has all unlocked
    if MyNinjaWay.debug_mode or (G.PROFILES and G.PROFILES[G.SETTINGS.profile] and G.PROFILES[G.SETTINGS.profile].all_unlocked) then
        for _, t in ipairs({G.P_CENTERS, G.P_BLINDS, G.P_TAGS, G.P_SEALS}) do
            for k, v in pairs(t) do
                if v and string.find(k or "", "myninjaway_") then
                    v.alerted = true
                    v.discovered = true
                    v.unlocked = true
                end
            end
        end
    end
end

----------------------------------------------
---------------- FINALIZATION ---------------
----------------------------------------------

-- Mark mod as initialized
MyNinjaWay.initialized = true

-- Make mod globally accessible
_G.MyNinjaWay = MyNinjaWay

-- Final debug message
debug_log("Naruto Test Mod v0.1 loaded successfully!")
debug_log("Created by elmakas666")
debug_log("Total registered objects: " .. (function()
    local count = 0
    for _, objects in pairs(MyNinjaWay.object_registry) do
        for _ in pairs(objects) do
            count = count + 1
        end
    end
    return count
end)())
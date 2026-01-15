local background = core.settings:get_bool("myeyes.use_background", false)
local huds = {}
local old_node = {}
local user_settings = {} -- Track who has the HUD enabled

-- [Helper Functions]
function get_pointed_node_name_from_player(player, node_above, distance)
    local pos = player:get_pos()
    if not pos then return nil end
    local start_pos = vector.add(pos, { x = 0, y = 1.5, z = 0 })
    local direction = player:get_look_dir()
    local end_pos = vector.add(start_pos, vector.multiply(direction, distance))
    local ray = core.raycast(start_pos, end_pos, false, false)

    for pointed in ray do
        if pointed.type == "node" then
            local hit_pos = node_above and vector.round(pointed.under) or vector.round(pointed.above)
            return core.get_node(hit_pos).name
        end
    end
    return nil
end

function get_pointed_node_description_from_player(player, node_above, distance)
    local pos = player:get_pos()
    if not pos then return nil end
    local start_pos = vector.add(pos, { x = 0, y = 1.5, z = 0 })
    local direction = player:get_look_dir()
    local end_pos = vector.add(start_pos, vector.multiply(direction, distance))
    local ray = core.raycast(start_pos, end_pos, false, false)

    for pointed in ray do
        if pointed.type == "node" then
            local hit_pos = node_above and vector.round(pointed.under) or vector.round(pointed.above)
            local node = core.get_node(hit_pos)
            local node_def = core.registered_nodes[node.name]
            return node_def and node_def.description or nil
        end
    end
    return nil
end

-- 1. Setup HUDs and Settings when player joins
core.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    user_settings[name] = true -- Default to ON
    
    local ids = {}
    if background then
        ids.bg = player:hud_add({
            type = "image",
            position  = {x = 0.95, y = 0.105},
            offset    = {x = -150, y = -25},
            text      = "myeyes_background.png",
            scale     = { x = 1, y = 1},
        })
    end
    
    ids.desc = player:hud_add({
        type = "text",
        position  = {x = 0.95, y = 0.09},
        offset    = {x = -150, y = -25},
        text      = "",
        number    = 0x25de29,
        size      = { x = 1.7},
    })
    
    ids.name = player:hud_add({
        type = "text",
        position  = {x = 0.95, y = 0.12},
        offset    = {x = -150, y = -25},
        text      = "",
        number    = 0xdb9c10,
        size      = { x = 1},
    })
    
    huds[name] = ids
    old_node[name] = ""
end)

-- 2. Toggle Command
core.register_chatcommand("myeyes", {
    params = "on/off",
    description = "Enable or disable the block info HUD",
    func = function(name, param)
        local player = core.get_player_by_name(name)
        if not player or not huds[name] then return false, "Player not found." end

        if param == "off" then
            user_settings[name] = false
            -- Hide current text
            player:hud_change(huds[name].desc, "text", "")
            player:hud_change(huds[name].name, "text", "")
            return true, "MyEyes HUD disabled."
        elseif param == "on" then
            user_settings[name] = true
            return true, "MyEyes HUD enabled."
        else
            return false, "Use /myeyes on or /myeyes off"
        end
    end,
})

-- 3. Cleanup
core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    huds[name] = nil
    old_node[name] = nil
    user_settings[name] = nil
end)

-- 4. The Global Manager (Checks user_settings)
local timer = 0
core.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < 0.2 then return end
    timer = 0

    for _, player in ipairs(core.get_connected_players()) do
        local name = player:get_player_name()
        
        -- Only process if player has HUD enabled and exists
        if user_settings[name] and huds[name] and player:get_pos() then
            local node_name = get_pointed_node_name_from_player(player, true, 9)
            local node_desc = get_pointed_node_description_from_player(player, true, 9)
            
            if node_name ~= old_node[name] then
                player:hud_change(huds[name].name, "text", node_name or "")
                old_node[name] = node_name or ""
            end
            player:hud_change(huds[name].desc, "text", node_desc or "")
        end
    end
end)

local background = core.settings:get_bool("myeyes.use_background", false)

local huds = {}

-- Most of the code is by degiel1982
-- Helper function to extract the name of the node the player is pointing at.
-- Parameters:
--   player: The player object.
--   node_above: Boolean flag; if true, returns the node below the rayhit (pointed.under),
--               otherwise returns the node above (pointed.above).
-- distance: How far you want to detect
-- Returns:
--   The name of the node that was hit, or nil if no node was found within the ray's range.
function get_pointed_node_name_from_player(player, node_above, distance)
    -- Calculate the player's eye position (rough approximation)
    local start_pos = vector.add(player:get_pos(), { x = 0, y = 1.5, z = 0 })
    local direction = player:get_look_dir()

    -- Define the max distance for the raycast
    local ray_length = distance
    local end_pos = vector.add(start_pos, vector.multiply(direction, ray_length))

    -- Create a ray from the player's eye in the direction they're looking
    local ray = minetest.raycast(start_pos, end_pos, false, false)

    -- Iterate over the objects hit by the ray
    for pointed in ray do
        if pointed.type == "node" then
            -- Decide which node to consider based on the node_above flag
            local hit_pos = node_above and vector.round(pointed.under) or vector.round(pointed.above)
            local node = minetest.get_node(hit_pos)
            return node.name  -- Return the name of the node
        end
    end

    return nil  -- If no node is hit, return nil
end

function get_pointed_node_description_from_player(player, node_above, distance)
-- Calculate the player's eye position (rough approximation)
local start_pos = vector.add(player:get_pos(), { x = 0, y = 1.5, z = 0 })
local direction = player:get_look_dir()

-- Define the max distance for the raycast
local ray_length = distance
local end_pos = vector.add(start_pos, vector.multiply(direction, ray_length))

-- Create a ray from the player's eye in the direction they're looking
local ray = minetest.raycast(start_pos, end_pos, false, false)

-- Iterate over the objects hit by the ray
for pointed in ray do
if pointed.type == "node" then
-- Decide which node to consider based on the node_above flag
local hit_pos = node_above and vector.round(pointed.under) or vector.round(pointed.above)
local node = minetest.get_node(hit_pos)

-- Retrieve the description of the node
local node_def = minetest.registered_nodes[node.name]
if node_def then
return node_def.description -- Return the description of the node
end
end
end

return nil -- If no node is hit, return nil
end

minetest.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
	if background then
		local hud_id = player:hud_add({
    		hud_elem_type = "image",
    		position  = {x = 0.95, y = 0.105},
    		offset    = {x = -150, y = -25},
    		text      = "myeyes_background.png",
    		alignment = 0,
    		scale     = { x = 1, y = 1},
		})
	end
	local hud_id = player:hud_add({
    	hud_elem_type = "text",
    	position  = {x = 0.95, y = 0.09},
    	offset    = {x = -150, y = -25},
    	text      = "",
    	alignment = 0,
    	scale     = { x = 100, y = 100},
    	number    = 0x25de29,
    	size	  = { x = 1.7},
    	style 	  = 1,
	})
	local hud_id2 = player:hud_add({
    	hud_elem_type = "text",
    	position  = {x = 0.95, y = 0.12},
    	offset    = {x = -150, y = -25},
    	text      = "",
    	alignment = 0,
    	scale     = { x = 100, y = 100},
    	number    = 0xdb9c10,
    	size	  = { x = 1},
    	style 	  = 2,
	})
	
	huds[player_name] = hud_id

	local old_node = {}
	local distance = 9
	local node_above = true
	
	core.register_globalstep(function(dtime)
		local p_name = player:get_player_name()
    		
		if not old_node[p_name] then
			old_node[p_name] = ""
		end
    	
		local node_name =  get_pointed_node_name_from_player(player, node_above , distance )
		if node_name ~= nil and node_name ~= old_node[p_name] then
			player:hud_change(hud_id2,"text", node_name)
			old_node[p_name] = node_name
		end
    	
		local node_def =  get_pointed_node_description_from_player(player, node_above , distance )
		if node_def ~= nil then
			player:hud_change(hud_id,"text", node_def)
		end
	end)
end)




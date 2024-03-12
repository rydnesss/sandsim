local mats = require 'obj/mats'

local Cell = class({name = 'cell'})

function Cell:new(x, y, material)
    self.x, self.y = x or love.math.random(1, #data.get_grid()), y or 1

    if material then 
        self:set(material)
    else 
        self:set()
    end
    
end

function Cell:set(material)
    if material then 
        self.material = mats[material]()
    else
        self.material = mats['empty']()
    end
end

function Cell:get()
    return self
end

function Cell:tick()

    if self.material.name ~= 'empty' then 
        self.material:tick(self)
    end

end

function Cell:move(vec, mats)

    local residue_mat, new_mat = mats[1], mats[2]

    local grid = data.get_grid()

    local target_cell = grid[self.x + vec[1]][self.y + vec[2]]

    if residue_mat == 'none' then residue_mat = target_cell.material.name end

    local origin_cell = grid[self.x][self.y]

    local deviating_cell

    if grid[self.x][math.max(1, self.y - vec[2])].material.name ~= 'empty' and target_cell.material.name ~= 'empty' then --If both the target material and opposite of the adjacent material aren't empty (AKA splashing needed)
        for modif = 1, target_cell.material.splash or 1 do --For the entire splash range...
            if grid[math.max(1, self.x - modif)][math.max(1, self.y - (modif * vec[2]))].material.name == 'empty' then --Check left nearest position for being free
                deviating_cell =  grid[math.max(1, self.x - modif)][math.max(1, self.y - (modif * vec[2]))]
                break
            elseif grid[math.min(data.get_grid('size'), self.x + modif)][math.max(1, self.y - modif)].material.name == 'empty' then --Check right nearest position for being free
                deviating_cell =  grid[math.min(data.get_grid('size'), self.x + modif)][math.max(1, self.y - (modif * vec[2]))]
                break
            end
        end
    end 

    local origin_lifetime
    if origin_cell.material.lifetime then 
        origin_lifetime = origin_cell.material.lifetime
    end

    local target_lifetime
    if target_cell.material.lifetime then 
        target_lifetime = target_cell.material.lifetime
    end
        
    if deviating_cell then 
        deviating_cell:set(residue_mat)
        if target_lifetime then 
            deviating_cell.material.lifetime = target_lifetime
        end
        origin_cell:set()
    else 
        origin_cell:set(residue_mat)
        if target_lifetime then 
            origin_cell.material.lifetime = target_lifetime
        end 
    end
    target_cell:set(new_mat)
        if origin_lifetime then 
            target_cell.material.lifetime = origin_lifetime
        end 

end 

function Cell:try_moving_to(vec, mats)
    local target_cell
    local grid = data.get_grid()
    if grid[self.x + vec[1]] and grid[self.x + vec[1]][self.y + vec[2]] then 
        target_cell = grid[self.x + vec[1]][self.y + vec[2]]
    end 

    if target_cell and target_cell.material.density < self.material.density then 
        self:move(vec, mats)
        return true 
    else
        return false 
    end
end 

function Cell:get_adj(vec)
    local target_cell
    local grid = data.get_grid()
    if grid[self.x + vec[1]] and grid[self.x + vec[1]][self.y + vec[2]] then 
        target_cell = grid[self.x + vec[1]][self.y + vec[2]]
    end 
    return target_cell
end 

function Cell:blocked_by(vec)
    local grid = data.get_grid()
    local target_cell 
    if grid[self.x + vec[1]] and grid[self.x + vec[1]][self.y + vec[2]] then 
        target_cell = grid[self.x + vec[1]][self.y + vec[2]]
    end 

    return target_cell and target_cell.material.density > self.material.density
end 

return Cell
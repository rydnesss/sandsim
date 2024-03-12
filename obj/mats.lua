local Empty = class({name = 'empty'})

function Empty:new()
    self.name = 'empty'
    self.density = 0
end

local Sand = class({name = 'sand'})

function Sand:new()
    self.updated = true
    self.name = 'sand'
    self.density = 5
    self.color = table.pick_random({{245/255, 221/255, 173/255},{222/255, 184/255, 135/255},{200/255, 160/255, 112/255}})
end

function Sand:tick(cell)
    if cell.y < data.get_grid('size') then

        if not cell:try_moving_to({0, 1}, {'none', 'sand'}) then 
            if love.math.random() < 0.5 then
                if not cell:blocked_by({-1, 0}) then 
                    cell:try_moving_to({-1, 1}, {'none', 'sand'}) 
                end
            else
                if not cell:blocked_by({1, 0}) then 
                    cell:try_moving_to({1, 1}, {'none', 'sand'})
                end
            end
        end
    end
end 

local Water = class({name = 'water'})

function Water:new()
    self.updated = true
    self.name = 'water'
    self.density = 2
    self.color = table.pick_random({{152/255, 193/255, 218/255}, {123/255, 157/255, 178/255}, {114/255, 175/255, 172/255}})
    self.splash = 6

end 

function Water:tick(cell)
    if cell.y < data.get_grid('size') then 

        local moved = false
    
        if cell:try_moving_to({0, 1}, {'none', 'water'}) then 
            moved = true 
        end 

        if not moved then 
            for x = 0, self.splash do

                
                if cell:blocked_by({-x, 0}) then
                    cell:try_moving_to({1, 0}, {'none', 'water'}) 
                    break 
                elseif cell:blocked_by({x, 0}) then
                    cell:try_moving_to({-1, 0}, {'none', 'water'})
                    break
                end 
                    

                if love.math.random() < 0.5 then 
                    
                    if cell:try_moving_to({-x, math.floor(math.random() + 0.5)}, {'none', 'water'}) or 
                    cell:try_moving_to({x, math.floor(math.random() + 0.5)}, {'none', 'water'}) then 
                        moved = true
                    end 
                else  

                    if cell:try_moving_to({x, math.floor(math.random() + 0.5)}, {'none', 'water'}) or
                    cell:try_moving_to({-x, math.floor(math.random() + 0.5)}, {'none', 'water'}) then 
                        moved = true 
                    end
                end 

                if moved then 
                    break 
                end 

            end
        end 
    end
end 

local Wood = class({name = 'wood'})

function Wood:new()
    self.updated = true
    self.name = 'wood'
    self.density = 10
    self.flammability = 3
    self.color = table.pick_random({{139/255, 69/255, 19/255}, {160/255, 82/255, 45/255}, {205/255, 133/255, 63/255}})
end 

function Wood:tick()
end

local Smoke = class({name = 'smoke'})

function Smoke:new()
    self.updated = true
    self.name = 'smoke'
    self.density = 1
    self.color = table.pick_random({{192/255, 192/255, 192/255}, {169/255, 169/255, 169/255}, {128/255, 128/255, 128/255}})
    self.splash = 3
    self.lifetime = love.math.random(60, 120)
end

function Smoke:tick(cell)
    if cell.y < data.get_grid('size') then 

        self.lifetime = self.lifetime - 1

        if self.lifetime == 0 then 
            cell:set()
        end

        local moved = false
    
        if cell:try_moving_to({0, -1}, {'none', 'smoke'}) then 
            moved = true 
        end 

        if not moved then 
            for x = 0, self.splash do

                
                if cell:blocked_by({-x, 0}) then
                    cell:try_moving_to({1, 0}, {'none', 'smoke'}) 
                    break 
                elseif cell:blocked_by({x, 0}) then
                    cell:try_moving_to({-1, 0}, {'none', 'smoke'})
                    break
                end 
                    

                if love.math.random() < 0.5 then 
                    
                    if cell:try_moving_to({-x, -(math.floor(math.random() + 0.5))}, {'none', 'smoke'}) or 
                    cell:try_moving_to({x, -(math.floor(math.random() + 0.5))}, {'none', 'smoke'}) then 
                        moved = true
                    end 
                else  

                    if cell:try_moving_to({x, -(math.floor(math.random() + 0.5))}, {'none', 'smoke'}) or
                    cell:try_moving_to({-x, -(math.floor(math.random() + 0.5))}, {'none', 'smoke'}) then 
                        moved = true 
                    end
                end 

                if moved then 
                    break 
                end 

            end
        end 
    end
end 

local Fire = class({name = 'fire'})

function Fire:new()
    self.updated = true
    self.name = 'fire'
    self.density = 0
    self.color = table.pick_random({{255/255, 69/255, 0/255}, {255/255, 140/255, 0/255}, {255/255, 0/255, 0/255}})
    self.lifetime = 5
end


function Fire:tick(cell)
    if cell.y < data.get_grid('size') then 
        for dx = -1, 1 do
            for dy = -1, 1 do
                if dx ~= 0 or dy ~= 0 then  -- Skip the current cell
                    local neighbor = cell:get_adj({dx, dy})
                    local flame_needed
                    if neighbor then 
                        flame_needed = neighbor.material.flammability
                    end

                    if flame_needed and self.lifetime <= flame_needed then
                        cell:move({dx, dy}, {'smoke', 'fire'})
                    end

                    if neighbor and neighbor.material.name == 'smoke' then 
                        if not neighbor:try_moving_to({love.math.random(-1, 1), love.math.random(-1, 1)}, {'none', 'smoke'}) then 
                            neighbor:set()
                        end
                    end 
                end
            end
        end

        self.lifetime = self.lifetime - 1  -- Decrement the lifetime each tick

        if self.lifetime == 0 then
            cell:set('smoke')  -- Set 'smoke' when the lifetime reaches 0
        end
    end
end



t = 
{
    ['empty'] = Empty,
    ['sand'] = Sand,
    ['water'] = Water,
    ['wood'] = Wood,
    ['smoke'] = Smoke,
    ['fire'] = Fire
}

return t
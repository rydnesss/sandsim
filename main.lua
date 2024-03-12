require('libs/batteries'):export()

data = 
{
    timer = 0,
    tickrate = 0.01,
    brush_size = 0,
    mat = 'sand'
}

local Cell = require 'obj/cell'

--

function love.load()
    data.set_grid(64)
    data.get_grid()
end 

function love.update(dt)
    data.timer = data.timer + dt 
    if data.timer > data.tickrate then 
        data.tick_grid()
        data.timer = 0 
    end 

    if love.mouse.isDown(1) or love.mouse.isDown(2) then 
        local tmouse = {
            x = math.floor(love.mouse.getX() / data.get_grid('cell_size')) + 1, 
            y = math.floor(love.mouse.getY() / data.get_grid('cell_size')) + 1
        }

        local grid = data.get_grid()

        if tmouse.x <= data.get_grid('size') and tmouse.x > 0 and tmouse.y <= data.get_grid('size') and tmouse.y > 0 then 

            local brush_size = data.brush_size
            if brush_size > 0 then
                for x = -brush_size, brush_size do 
                    for y = -brush_size, brush_size do 
                        if love.mouse.isDown(1) and grid[math.min(data.get_grid('size'), math.max(1, tmouse.x + x))][math.min(data.get_grid('size'), math.max(1, tmouse.y + y))].material.name == 'empty' then 
                            grid[math.min(data.get_grid('size'), math.max(1, tmouse.x + x))][math.min(data.get_grid('size'), math.max(1, tmouse.y + y))]:set(data.mat)
                        elseif love.mouse.isDown(2) then 
                            grid[math.min(data.get_grid('size'), math.max(1, tmouse.x + x))][math.min(data.get_grid('size'), math.max(1, tmouse.y + y))]:set()
                        end
                    end 
                end 
            else
                if love.mouse.isDown(1) and grid[tmouse.x][tmouse.y].material.name == 'empty' then 
                    grid[tmouse.x][tmouse.y]:set(data.mat)
                elseif love.mouse.isDown(2) then 
                    grid[tmouse.x][tmouse.y]:set()
                end
            end
        end
    end

end 

function love.draw()
    data.draw_grid()
    data.draw_menu()
end

function love.keypressed(key)
    if key == 'up' then 
        if data.brush_size < 5 then 
            data.brush_size = data.brush_size + 1 
        end 
    elseif key == 'down' then 
        if data.brush_size > 0 then 
            data.brush_size = data.brush_size - 1 
        end 
    end

    if key == '1' then 
        data.mat = 'sand'
    elseif key == '2' then 
        data.mat = 'water'
    elseif key == '3' then 
        data.mat = 'wood'
    elseif key == '4' then 
        data.mat = 'smoke'
    elseif key == '5' then 
        data.mat = 'fire'
    end
end 

--

function data.set_grid(size)
    if not data.grid then data.grid = {} end 
    for x = 1, size do 
        data.grid[x] = {}
        for y = 1, size do 
            data.grid[x][y] = Cell(x, y)
        end 
    end 

    data.grid.size = size
    data.grid.cell_size = love.graphics.getHeight() / size
end

function data.get_grid(detail)
    return data.grid[detail] or data.grid
end 

function data.draw_grid()
    local grid_size = data.get_grid('size')
    local cell_size = data.get_grid('cell_size')

    love.graphics.setColor(0.04, 0.04, 0.04)
    love.graphics.rectangle('fill', 0, 0, 600, 600)

    for x = 1, grid_size do 
        for y = 1, grid_size do 
            local tx = (x - 1) * cell_size 
            local ty = (y - 1) * cell_size 
            if data.grid[x][y].material.name ~= 'empty' then 
                love.graphics.setColor(data.grid[x][y].material.color)
                love.graphics.rectangle('fill', tx, ty, cell_size, cell_size)
            else
                love.graphics.setColor(0.19, 0.19, 0.19)
                love.graphics.rectangle('line', tx, ty, cell_size, cell_size)
            end
        end 
    end
end 

function data.draw_menu()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', 600, 1, 199, love.graphics.getHeight() - 2)
end

function data.tick_grid()
    
    local grid_size = data.get_grid('size')
    local grid = data.get_grid()

    for x = grid_size, 1, -1 do 
        for y = grid_size, 1, -1 do 
            local cell = grid[x][y]


            if not cell.material.updated then 
                cell:tick()
            else
                cell.material.updated = false
            end 
        end 
    end 

end 
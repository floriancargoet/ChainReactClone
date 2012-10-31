local State     = require 'state'
local loveutils = require 'loveutils'

local print = loveutils.print

local gameover = State:new()

function gameover:init()
    self.scoreFile = love.filesystem.newFile("highscores.txt")
end

function gameover:setScore(value)
    self.score = value
    self:doHighScore()
end

function gameover:draw()
    print('Score: '..tostring(self.score))
    print('')
    print('Highscores')
    for i, v in ipairs(self.highScores) do
        print(tostring(i)..'. '..tostring(v))
    end
    print('')
    print('Press R to replay, Q to quit')
end

function gameover:keyreleased(key)
    if key == 'q' then
        self.game:quit()
    elseif key == 'r' then
        self:replay()
    end
end

function gameover:replay()
    self:exit()
end

function gameover:doHighScore()
    local f = self.scoreFile
    local highScores = {
        self.score
    }
    if love.filesystem.exists("highscores.txt") and f:open('r') then
        for line in f:lines() do
            table.insert(highScores, tonumber(line))
        end
        f:close()
    end
    table.sort(highScores, function(a, b) return a > b end)
    while #highScores > 5 do
        table.remove(highScores)
    end
    if f:open('w') then
        for _, v in ipairs(highScores) do
            f:write(tostring(v)..'\n')
        end
        f:close()
    end
    self.highScores = highScores
end

return gameover

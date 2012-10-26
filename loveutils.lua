
local y = 5
local function print(text)
    if not text or type(text) == 'number' then
        y = text or 5
    else
        love.graphics.print(text, 5, y)
        y = y + 20
    end
end

return {
    print = print
}

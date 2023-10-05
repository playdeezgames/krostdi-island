local Grid=require("grid")
local Columns=4
local Rows=5
function Generator()
    return math.random(0,9)
end

local subject=Grid.Create(Columns,Rows,Generator)

for row=1,Rows do
    local line=""
    for column=1,Columns do
        line=line..subject[column][row]
    end
    print(line)
end


local maze={
  Create=function(columns,rows)
  local rnd=math.random
  local maze={}
  while columns>#maze do
    local mazeColumn={}
    table.insert(maze,mazeColumn)
    while rows>#mazeColumn do
      table.insert(mazeColumn,0)
    end
  end
  local directions={
    {f=1,x=0,y=-1,o=3},
    {f=2,x=1,y=0,o=4},
    {f=4,x=0,y=1,o=1},
    {f=8,x=-1,y=0,o=2}
  }
  local column=rnd(1,columns)
  local row=rnd(1,rows)
  maze[column][row]=32
  local frontierCount=0
  for _,value in ipairs(directions) do
    local nextColumn=column+value.x
    local nextRow=row+value.y
    if nextColumn>=1 and nextRow>=1 and nextColumn<=columns and nextRow<=rows then
      frontierCount=frontierCount+1
      maze[nextColumn][nextRow]=maze[nextColumn][nextRow]+16
    end    
  end
  while frontierCount>0 do
    for column=1,columns do
      local line=""
      for row=1,rows do
        line = line..maze[column][row].." "
      end
    end  
    repeat
      column=rnd(1,columns)
      row=rnd(1,rows)
    until (maze[column][row] & 16)==16
    local candidates={}
    for candidate,value in ipairs(directions) do
      nextColumn=column+value.x
      nextRow=row+value.y
      if nextColumn>=1 and nextRow>=1 and nextColumn<=columns and nextRow<=rows and (maze[nextColumn][nextRow] & 32)==32 then
        table.insert(candidates,candidate)
      end
    end
    local direction=candidates[rnd(1,#candidates)]
    maze[column][row]=maze[column][row] | directions[direction].f
    maze[column][row]=maze[column][row] & 47
    maze[column][row]=maze[column][row] | 32
    nextColumn=column+directions[direction].x
    nextRow=row+directions[direction].y
    direction=directions[direction].o
    maze[nextColumn][nextRow]=maze[nextColumn][nextRow]|directions[direction].f
    frontierCount=frontierCount-1
    for _,value in ipairs(directions) do
      local nextColumn=column+value.x
      local nextRow=row+value.y
      if nextColumn>=1 and nextRow>=1 and nextColumn<=columns and nextRow<=rows and maze[nextColumn][nextRow]<16 then
        frontierCount=frontierCount+1
        maze[nextColumn][nextRow]=maze[nextColumn][nextRow]+16
      end    
    end
  end
  for column=1,columns do
    for row=1,rows do
        maze[column][row]=maze[column][row] & 15
    end
  end  
  return maze
end
}

local m=maze.Create(9,10)

for row=1,#m[1] do
  local line=""
  for column=1,#m do
    line=line.."#"
    if (m[column][row] & 1)==1 then
      line=line.." "
    else
      line=line.."#"
    end
  end
  line=line.."#"
  print(line)
  line=""
  for column=1,#m do
    if (m[column][row] & 8)==8 then
      line=line.." "
    else
      line=line.."#"
    end
    line=line.." "
  end
  line=line.."#"
  print(line)
end
local line=""
for column=1,#m do
  line=line.."##"
end
line=line.."#"
print(line)

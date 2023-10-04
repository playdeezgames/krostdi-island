local world
function package.preload.Maze()
return{Create=function(a,b)local c=table.insert;local d=math.random;local e={}while a>#e do local f={}c(e,f)while b>#f do c(f,0)end end;local g={{f=1,x=0,y=-1,o=3},{f=2,x=1,y=0,o=4},{f=4,x=0,y=1,o=1},{f=8,x=-1,y=0,o=2}}local h=d(1,a)local i=d(1,b)local j;local k;e[h][i]=32;local l=0;for m,n in ipairs(g)do j=h+n.x;k=i+n.y;if j>=1 and k>=1 and j<=a and k<=b then l=l+1;e[j][k]=e[j][k]+16 end end;while l>0 do repeat h=d(1,a)i=d(1,b)until e[h][i]&16==16;local o={}for p,n in ipairs(g)do j=h+n.x;k=i+n.y;if j>=1 and k>=1 and j<=a and k<=b and e[j][k]&32==32 then c(o,p)end end;local q=o[d(1,#o)]e[h][i]=e[h][i]|g[q].f;e[h][i]=e[h][i]&47;e[h][i]=e[h][i]|32;j=h+g[q].x;k=i+g[q].y;q=g[q].o;e[j][k]=e[j][k]|g[q].f;l=l-1;for m,n in ipairs(g)do j=h+n.x;k=i+n.y;if j>=1 and k>=1 and j<=a and k<=b and e[j][k]<16 then l=l+1;e[j][k]=e[j][k]+16 end end end;for h=1,a do for i=1,b do e[h][i]=e[h][i]&15 end end;return e end}
end
local Maze=require("Maze")
local CONST={
	MAZE_COLS=8,
	MAZE_ROWS=8,
	MAP_COLS=15,
	MAP_ROWS=15,
	TERRS={
		GR={
			SPR=64,
			MC=2
		},
		WT={
			SPR=65
		},
		TR={
			SPR=66,
			MC=5
		},
		RD={
			SPR=67,
			MC=1
		},
		BT={
			SPR=68
		}
	},
	CHTYPS={
		AVATAR={
			SPR=256
		}
	}
}
function MkMp(mX,mY)
	local mp= {}
	local tlut={
	[64]="GR",
	[65]="WT",
	[66]="TR"
	}
	for col=1,CONST.MAP_COLS do
		local dX=(col-1)//5
		mp[col]={}
		for row=1,CONST.MAP_ROWS do
			local dY=(row-1)//5
			mp[col][row]={
				terr=tlut[mget(mX+dX,mY+dY)]
			}
		end
	end
	return mp
end
function MkAtlas()
	local maze=Maze.Create(CONST.MAZE_COLS,CONST.MAZE_ROWS)
	local atlas={}
	while #atlas<CONST.MAZE_COLS*2 do
		local aX={}
		while #aX<CONST.MAZE_ROWS*2 do
			table.insert(aX,{})
		end
		table.insert(atlas,aX)
	end
	for col=1,CONST.MAZE_COLS do
		for row=1,CONST.MAZE_ROWS do
			local mazeCell=maze[col][row]
			local mX=(mazeCell%4)*6
			local mY=(mazeCell//4)*6
			atlas[col*2-1][row*2-1]=MkMp(mX,mY)
			atlas[col*2][row*2-1]=MkMp(mX+3,mY)
			atlas[col*2-1][row*2]=MkMp(mX,mY+3)
			atlas[col*2][row*2]=MkMp(mX+3,mY+3)
		end
	end
	return atlas
end
function MkChar(world,charType)
	table.insert(world.chars,{
		charType=charType,
		moveCost=0
	})
	return #world.chars
end
function MkAvatar(world)
	local charId=MkChar(world,"AVATAR")
	world.atlas[1][1][CONST.MAP_COLS//2+1][CONST.MAP_ROWS//2+1].charId=charId
	return {
		charId=charId,
		aX=1,
		atlasRow=1,
		mX=CONST.MAP_COLS//2+1,
		mY=CONST.MAP_ROWS//2+1
	}
end
function MkRoads(world)
	local maze=Maze.Create(CONST.MAZE_COLS*2,CONST.MAZE_ROWS*2)
	for col=1,CONST.MAZE_COLS*2 do
		for row=1,CONST.MAZE_ROWS*2 do
			local mazeCell=maze[col][row]
			local mp=world.atlas[col][row]
			if (mazeCell&1)==1 then
				for y=8,1,-1 do
					if mp[8][y].terr=="WT" then
						if y==5 then
							mp[8][y].terr="BT"
						end
					else
						mp[8][y].terr="RD"
					end
				end
			end
			if (mazeCell&2)==2 then
				for x=8,15 do
					if mp[x][8].terr=="WT" then
						if x==11 then
							mp[x][8].terr="BT"
						end
					else
						mp[x][8].terr="RD"
					end
				end
			end
			if (mazeCell&4)==4 then
				for y=8,15 do
					if mp[8][y].terr=="WT" then
						if y==11 then
							mp[8][y].terr="BT"
						end
					else
						mp[8][y].terr="RD"
					end
				end
			end
			if (mazeCell&8)==8 then
				for x=8,1,-1 do
					if mp[x][8].terr=="WT" then
						if x==5 then
							mp[x][8].terr="BT"
						end
					else
						mp[x][8].terr="RD"
					end
				end
			end
		end
	end
end
function MkWorld()
	local world={
		chars={},
		atlas=MkAtlas()
	}
	MkRoads(world)
	world.av=MkAvatar(world)
	return world
end
function BOOT()
	world=MkWorld()
end
function MvAvatar(dX,dY)
	local av=world.av
	local nMX=av.mX+dX
	local nAX=av.aX
	if nMX<1 then
		nMX=nMX+CONST.MAP_COLS
		nAX=nAX-1
	elseif nMX>CONST.MAP_COLS then
		nMX=nMX-CONST.MAP_COLS
		nAX=nAX+1
	end	
	local nMY=av.mY+dY
	local nAY=av.atlasRow
	if nMY<1 then
		nMY=nMY+CONST.MAP_ROWS
		nAY=nAY-1
	elseif nMY>CONST.MAP_ROWS then
		nMY=nMY-CONST.MAP_ROWS
		nAY=nAY+1
	end
	local nCell=world.atlas[nAX][nAY][nMX][nMY]
	local nTerr=nCell.terr
	if CONST.TERRS[nTerr].MC~=nil then
		--TODO: move cost affects player somehow
		local charId=world.atlas[av.aX][av.atlasRow][av.mX][av.mY].charId
		local character=world.chars[charId]
		character.moveCost=character.moveCost+CONST.TERRS[nTerr].MC
		world.atlas[av.aX][av.atlasRow][av.mX][av.mY].charId=nil
		av.aX=nAX
		av.atlasRow=nAY
		av.mX=nMX
		av.mY=nMY
		world.atlas[av.aX][av.atlasRow][av.mX][av.mY].charId=charId
	end
end
function DrawMap()
	local av=world.av
	local mp=world.atlas[av.aX][av.atlasRow]
	for col,mX in ipairs(mp) do
		for row,cell in ipairs(mX) do
			local x=col*8
			local y=row*8
			spr(CONST.TERRS[cell.terr].SPR,x,y)
			if cell.charId~=nil then
				local character=world.chars[cell.charId]
				local charType=CONST.CHTYPS[character.charType]
				spr(charType.SPR,x,y,0)
			end
		end
	end
	local areaCell=world.atlas[av.aX][av.atlasRow][av.mX][av.mY]
	local character=world.chars[areaCell.charId]
	print(character.moveCost)
	if keyp(58,20,20) then
		MvAvatar(0,-1)
	elseif keyp(59,20,20) then
		MvAvatar(0,1)
	elseif keyp(60,20,20) then
		MvAvatar(-1,0)
	elseif keyp(61,20,20) then
		MvAvatar(1,0)
	end
end
function TIC()
	cls(0)
	poke(0x3ffb,0)
	DrawMap()
	if keyp(70) then
		exit()
	end
end

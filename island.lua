function package.preload.Maze()
	return{Create=function(a,b)local c=table.insert;local d=math.random;local e={}while a>#e do local f={}c(e,f)while b>#f do c(f,0)end end;local g={{f=1,x=0,y=-1,o=3},{f=2,x=1,y=0,o=4},{f=4,x=0,y=1,o=1},{f=8,x=-1,y=0,o=2}}local h=d(1,a)local i=d(1,b)local j;local k;e[h][i]=32;local l=0;for m,n in ipairs(g)do j=h+n.x;k=i+n.y;if j>=1 and k>=1 and j<=a and k<=b then l=l+1;e[j][k]=e[j][k]+16 end end;while l>0 do repeat h=d(1,a)i=d(1,b)until e[h][i]&16==16;local o={}for p,n in ipairs(g)do j=h+n.x;k=i+n.y;if j>=1 and k>=1 and j<=a and k<=b and e[j][k]&32==32 then c(o,p)end end;local q=o[d(1,#o)]e[h][i]=e[h][i]|g[q].f;e[h][i]=e[h][i]&47;e[h][i]=e[h][i]|32;j=h+g[q].x;k=i+g[q].y;q=g[q].o;e[j][k]=e[j][k]|g[q].f;l=l-1;for m,n in ipairs(g)do j=h+n.x;k=i+n.y;if j>=1 and k>=1 and j<=a and k<=b and e[j][k]<16 then l=l+1;e[j][k]=e[j][k]+16 end end end;for h=1,a do for i=1,b do e[h][i]=e[h][i]&15 end end;return e end}
end
local Maze=require("Maze")
local world
local tf
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
		BTN={
			SPR=68,
			VB="BOAT",
			DX=0,
			DY=-11
		},
		BTE={
			SPR=68,
			VB="BOAT",
			DX=11,
			DY=0
		},
		BTS={
			SPR=68,
			VB="BOAT",
			DX=0,
			DY=11
		},
		BTW={
			SPR=68,
			VB="BOAT",
			DX=-11,
			DY=0
		},
		TOWNR={
			SPR=128,
			VB="TOWN"
		},
		TOWNO={
			SPR=129,
			VB="TOWN"
		},
		TOWNY={
			SPR=130,
			VB="TOWN"
		},
		TOWNG={
			SPR=131,
			VB="TOWN"
		},
		TOWNC={
			SPR=132,
			VB="TOWN"
		},
		TOWNB={
			SPR=133,
			VB="TOWN"
		},
		TOWNM={
			SPR=134,
			VB="TOWN"
		},
		TOWNW={
			SPR=135,
			VB="TOWN"
		}
	},
	CHTYPS={
		AVATAR={
			SPR=256,
			STARVE_INT=480,
			EXHAUST_INT=1440
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
	for x=1,CONST.MAZE_COLS do
		for y=1,CONST.MAZE_ROWS do
			local mzCell=maze[x][y]
			local mX=(mzCell%4)*6
			local mY=(mzCell//4)*6
			atlas[x*2-1][y*2-1]=MkMp(mX,mY)
			atlas[x*2][y*2-1]=MkMp(mX+3,mY)
			atlas[x*2-1][y*2]=MkMp(mX,mY+3)
			atlas[x*2][y*2]=MkMp(mX+3,mY+3)
		end
	end
	return atlas
end
function MkChar(chTyp)
	table.insert(world.chars,{
		chTyp=chTyp,
		moveCost=0,
		hunger=0,
		starve=0,
		fatigue=0,
		exhaust=0
	})
	return #world.chars
end
function MkAvatar()
	local charId=MkChar("AVATAR")
	world.atlas[1][1][6][6].charId=charId
	world.av= {
		charId=charId,
		aX=1,
		aY=1,
		mX=6,
		mY=6,
	}
end
function MkRoads()
	local maze=Maze.Create(CONST.MAZE_COLS*2,CONST.MAZE_ROWS*2)
	local towns={TOWNR,TOWNO,TOWNY,TOWNG,TOWNC,TOWNB,TOWNM,TOWNW}
	for col=1,CONST.MAZE_COLS*2 do
		for row=1,CONST.MAZE_ROWS*2 do
			local mzCell=maze[col][row]
			local mp=world.atlas[col][row]
			if (mzCell&1)==1 then
				for y=8,1,-1 do
					if mp[8][y].terr=="WT" then
						if y==5 then
							mp[8][y].terr="BTN"
						end
					else
						mp[8][y].terr="RD"
					end
				end
			end
			if (mzCell&2)==2 then
				for x=8,15 do
					if mp[x][8].terr=="WT" then
						if x==11 then
							mp[x][8].terr="BTE"
						end
					else
						mp[x][8].terr="RD"
					end
				end
			end
			if (mzCell&4)==4 then
				for y=8,15 do
					if mp[8][y].terr=="WT" then
						if y==11 then
							mp[8][y].terr="BTS"
						end
					else
						mp[8][y].terr="RD"
					end
				end
			end
			if (mzCell&8)==8 then
				for x=8,1,-1 do
					if mp[x][8].terr=="WT" then
						if x==5 then
							mp[x][8].terr="BTW"
						end
					else
						mp[x][8].terr="RD"
					end
				end
			end
			if mzCell==8 or mzCell==4 or mzCell==2 or mzCell==1 then
				local town=towns[math.random(1,#towns)]
				mp[8][8].terr=town
			end
		end
	end
end
function MkWorld()
	world={
		chars={},
		atlas=MkAtlas()
	}
	MkRoads()
	MkAvatar()
end
function AddMoves(char,mc)
	local chtype=CONST.CHTYPS[char.chTyp]
	char.moveCost=char.moveCost+mc
	char.hunger=char.hunger+mc
	if char.hunger>=chtype.STARVE_INT then
		char.starve=char.starve+1
		char.hunger=char.hunger-chtype.STARVE_INT
	end
	char.fatigue=char.fatigue+mc
	if char.fatigue>=chtype.EXHAUST_INT then
		char.exhaust=char.exhaust+1
		char.fatigue=char.fatigue-chtype.EXHAUST_INT
	end
end
function PlaceAvatar(aX,aY,mX,mY)
	local av=world.av
	local charId=world.atlas[av.aX][av.aY][av.mX][av.mY].charId
	world.atlas[av.aX][av.aY][av.mX][av.mY].charId=nil
	av.aX=aX
	av.aY=aY
	av.mX=mX
	av.mY=mY
	world.atlas[av.aX][av.aY][av.mX][av.mY].charId=charId
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
	local nAY=av.aY
	if nMY<1 then
		nMY=nMY+CONST.MAP_ROWS
		nAY=nAY-1
	elseif nMY>CONST.MAP_ROWS then
		nMY=nMY-CONST.MAP_ROWS
		nAY=nAY+1
	end
	local nCell=world.atlas[nAX][nAY][nMX][nMY]
	local nTerr=nCell.terr
	local td=CONST.TERRS[nTerr]
	if td.MC~=nil then
		local charId=world.atlas[av.aX][av.aY][av.mX][av.mY].charId
		local char=world.chars[charId]
		local mc=CONST.TERRS[nTerr].MC
		AddMoves(char,mc)
		PlaceAvatar(nAX,nAY,nMX,nMY)
	elseif td.VB=="BOAT" then
		--TODO: pay for boat travel
		MvAvatar(td.DX,td.DY)
	end
end
function DrawMap()
	map(24,0,17,17)
	local av=world.av
	local mp=world.atlas[av.aX][av.aY]
	for col,mX in ipairs(mp) do
		for row,cell in ipairs(mX) do
			local x=col*8
			local y=row*8
			spr(CONST.TERRS[cell.terr].SPR,x,y)
			if cell.charId~=nil then
				local char=world.chars[cell.charId]
				local chTyp=CONST.CHTYPS[char.chTyp]
				spr(chTyp.SPR,x,y,0)
			end
		end
	end
	local mapCell=world.atlas[av.aX][av.aY][av.mX][av.mY]
	local char=world.chars[mapCell.charId]
	if char.starve>0 then
		print("STARVING(x"..char.starve..")",136,0,1)
	end
	if char.exhaust>0 then
		print("EXHAUSTED(x"..char.exhaust..")",136,8,1)
	end
	--local health=char.maxHealth-char.exhaust-char.starve
	--local x=136
	if keyp(58,10,10) or btnp(0,10,10) then
		MvAvatar(0,-1)
	elseif keyp(59,10,10) or btnp(1,10,10) then
		MvAvatar(0,1)
	elseif keyp(60,10,10) or btnp(2,10,10) then
		MvAvatar(-1,0)
	elseif keyp(61,10,10) or btnp(3,10,10) then
		MvAvatar(1,0)
	end
end
function BOOT()
	MkWorld()
	tf=DrawMap
end
function TIC()
	cls(0)
	poke(0x3ffb,0)
	tf()
	if keyp(70) then
		exit()
	end
end

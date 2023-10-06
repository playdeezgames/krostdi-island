function package.preload.Maze()
	return{Create=function(a,b)local c=table.insert;local d=math.random;local e={}while a>#e do local f={}c(e,f)while b>#f do c(f,0)end end;local g={{f=1,x=0,y=-1,o=3},{f=2,x=1,y=0,o=4},{f=4,x=0,y=1,o=1},{f=8,x=-1,y=0,o=2}}local h=d(1,a)local i=d(1,b)local j;local k;e[h][i]=32;local l=0;for m,n in ipairs(g)do j=h+n.x;k=i+n.y;if j>=1 and k>=1 and j<=a and k<=b then l=l+1;e[j][k]=e[j][k]+16 end end;while l>0 do repeat h=d(1,a)i=d(1,b)until e[h][i]&16==16;local o={}for p,n in ipairs(g)do j=h+n.x;k=i+n.y;if j>=1 and k>=1 and j<=a and k<=b and e[j][k]&32==32 then c(o,p)end end;local q=o[d(1,#o)]e[h][i]=e[h][i]|g[q].f;e[h][i]=e[h][i]&47;e[h][i]=e[h][i]|32;j=h+g[q].x;k=i+g[q].y;q=g[q].o;e[j][k]=e[j][k]|g[q].f;l=l-1;for m,n in ipairs(g)do j=h+n.x;k=i+n.y;if j>=1 and k>=1 and j<=a and k<=b and e[j][k]<16 then l=l+1;e[j][k]=e[j][k]+16 end end end;for h=1,a do for i=1,b do e[h][i]=e[h][i]&15 end end;return e end}
end
function package.preload.Grid()
	return{Create=function(a,b,c)local d={}for e=1,a do d[e]={}for f=1,b do d[e][f]=c(e,f)end end;return d end}
end
local Maze=require("Maze")
local Grid=require("Grid")
local world
local tf
local CONST={
	MZ_W=8,
	MZ_H=8,
	MP_W=15,
	MP_H=15,
	CITY_NAMES={"Aelville","Aldhedge","Barrowhaven","Blackfair","Bluemeadow","Brighthurst","Brookmill","Brookville","Bushmarsh","Butterwolf","Clearcourt","Corness","Courtbank","Crystalshade","Crystalwell","Deepbank","Eastfall","Elfmoor","Esterland","Falconholt","Fallcourt","Fayflower","Faywick","Flowerlake","Glassmont","Goldbarrow","Hollowlake","Iceborough","Icelyn","Iceport","Ironbarrow","Ironston","Jancliff","Janmill","Lakeacre","Lightspell","Lormoor","Lorston","Magebeach","Magekeep","Mallowpond","Mallowtown","Maplebridge","Marblewald","Meadowholt","Millbush","Newviolet","Oldmerrow","Oldwall","Ostbarrow","Ostlyn","Pinelake","Rayhaven","Riverlake","Sagecoast","Sagepond","Shadowlake","Shoremill","Silverelf","Springland","Vertapple","Violetton","Wayhaven","Welllea","Westerden","Whiteviolet","Windport","Wintercastle","Wintermere","Winterwolf","Woodbank","Woodmarble"},
	TOWNS={
		{
			TERR="TOWNR",
			WALL="WALLR"
		},
		{
			TERR="TOWNO",
			WALL="WALLO"
		},
		{
			TERR="TOWNY",
			WALL="WALLY"
		},
		{
			TERR="TOWNG",
			WALL="WALLG"
		},
		{
			TERR="TOWNC",
			WALL="WALLC"
		},
		{
			TERR="TOWNB",
			WALL="WALLB"
		},
		{
			TERR="TOWNM",
			WALL="WALLM"
		},
		{
			TERR="TOWNW",
			WALL="WALLW"
		}
	},
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
		},
		WALLR={
			SPR=136
		},
		WALLO={
			SPR=137
		},
		WALLY={
			SPR=138
		},
		WALLG={
			SPR=139
		},
		WALLC={
			SPR=140
		},
		WALLB={
			SPR=141
		},
		WALLM={
			SPR=142
		},
		WALLW={
			SPR=143
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
	local tlut={
	[64]="GR",
	[65]="WT",
	[66]="TR"
	}
	return Grid.Create(CONST.MP_W,CONST.MP_H,function(col,row) 
		return {
			terr=tlut[mget(mX+(col-1)//5,mY+(row-1)//5)]
		}
	end)
end
function MkAtlas()
	local mz=Maze.Create(CONST.MZ_W,CONST.MZ_H)
	local atlas=Grid.Create(CONST.MZ_W*2,CONST.MZ_H*2,function(col,row) 
		local mzCell=mz[(col-1)//2+1][(row-1)//2+1]
		return MkMp((mzCell%4)*6+((col-1)%2)*3,(mzCell//4)*6+((row-1)%2)*3)
	end)
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
	local aX,aY,mX,mY
	repeat
		aX=math.random(1,CONST.MZ_W*2)
		aY=math.random(1,CONST.MZ_H*2)
		mX=math.random(1,CONST.MP_W)
		mY=math.random(1,CONST.MP_H)
	until world.atlas[aX][aY][mX][mY].terr=="GR"
	world.atlas[aX][aY][mX][mY].charId=charId
	world.av= {
		charId=charId,
		aX=aX,
		aY=aY,
		mX=mX,
		mY=mY,
	}
end
function MkTown(townType,mzCell)
	local tn={}
	tn.name=CONST.CITY_NAMES[math.random(1,#CONST.CITY_NAMES)]
	tn.grid=Grid.Create(CONST.MP_W,CONST.MP_H,function(x,y)
		local terr="GR"
		if x==1 or y==1 or x==CONST.MP_W or y==CONST.MP_H then
			terr=CONST.TOWNS[townType].WALL
		end
		return {
			terr=terr
		}
	end)
	local mz=Maze.Create(3,3)
	if mzCell==1 then
		mz[2][1]=mz[2][1]+1
		tn.x=CONST.MP_W//2+1
		tn.y=1
	elseif mzCell==2 then
		mz[3][2]=mz[3][2]+2
		tn.x=CONST.MP_W
		tn.y=CONST.MP_H//2+1
	elseif mzCell==4 then
		mz[2][3]=mz[2][3]+4
		tn.x=CONST.MP_W//2+1
		tn.y=CONST.MP_H
	else
		mz[1][2]=mz[1][2]+8
		tn.x=1
		tn.y=CONST.MP_H//2+1
	end
	local tg=tn.grid
	for rc=1,3 do
		for rr=1,3 do
			local rx=rc*5-2
			local ry=rr*5-2
			tg[rx][ry].terr="RD"
			if (mz[rc][rr]&1)==1 then
				tg[rx][ry-1].terr="RD"
				tg[rx][ry-2].terr="RD"
			end
			if (mz[rc][rr]&2)==2 then
				tg[rx+1][ry].terr="RD"
				tg[rx+2][ry].terr="RD"
			end
			if (mz[rc][rr]&4)==4 then
				tg[rx][ry+1].terr="RD"
				tg[rx][ry+2].terr="RD"
			end
			if (mz[rc][rr]&8)==8 then
				tg[rx-1][ry].terr="RD"
				tg[rx-2][ry].terr="RD"
			end
		end
	end
	--town buildings
	return tn
end
function MkRoads()
	local maze=Maze.Create(CONST.MZ_W*2,CONST.MZ_H*2)
	for col=1,CONST.MZ_W*2 do
		for row=1,CONST.MZ_H*2 do
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
				local townType=math.random(1,#CONST.TOWNS)
				local townTerr=CONST.TOWNS[townType].TERR
				local mapCell=mp[8][8]
				mapCell.terr=townTerr
				mapCell.town=MkTown(townType,mzCell)
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
		nMX=nMX+CONST.MP_W
		nAX=nAX-1
	elseif nMX>CONST.MP_W then
		nMX=nMX-CONST.MP_W
		nAX=nAX+1
	end	
	local nMY=av.mY+dY
	local nAY=av.aY
	if nMY<1 then
		nMY=nMY+CONST.MP_H
		nAY=nAY-1
	elseif nMY>CONST.MP_H then
		nMY=nMY-CONST.MP_H
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
	elseif td.VB=="TOWN" then
		PlaceAvatar(nAX,nAY,nMX,nMY)
		tf=DrawTown
		av.tX=world.atlas[av.aX][av.aY][av.mX][av.mY].town.x
		av.tY=world.atlas[av.aX][av.aY][av.mX][av.mY].town.y
	end
end
function DrawTown()
	map(24,0,17,17)
	local av=world.av
	local mp=world.atlas[av.aX][av.aY]
	local town=mp[av.mX][av.mY].town
	for col,townCol in ipairs(town.grid) do
		for row,cell in ipairs(townCol) do
			local x=col*8
			local y=row*8
			spr(CONST.TERRS[cell.terr].SPR,x,y)
			if av.tX==col and av.tY==row then
				local char=world.chars[av.charId]
				local chTyp=CONST.CHTYPS[char.chTyp]
				spr(chTyp.SPR,x,y,0)
			end
		end
	end
	if keyp() then
		tf=DrawMap
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
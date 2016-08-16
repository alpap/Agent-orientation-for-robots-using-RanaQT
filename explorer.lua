posX = 0
posY = 0
battery = 0
macroF = 0
timeRes = 0
currentOre = 0
comScope=0
mapSize=200
--- base info --
baseX = 0
baseY = 0
	
--- id ---
ID = 0
cId = 0
bId = 0
--- energy cost --
movementCost = 0

msgCost = 0
scanningCost = 0
memSize = 0
batteryMax =0
--- arrays for mem ---
ore = {}
mem = {}
perception = 0
enable = false
baseFull = false

function initExp(x, y, id, macroFactor, timeResolution, ComScope, MaxCycles, CompanyID, BaseID, Battery, MovementCost, ScanningCost, MessageCost, memorySize, Perception)
	posX = x
	posX = y
	ID = id
	macroF = macroFactor
	timeRes = timeResolution
	comScope = ComScope
	cId = CompanyID
	bId = BaseID
	batteryMax = Battery
	battery=Battery
	movementCost = MovementCost
	msgCost = MessageCost
	scanningCost = ScanningCost
	memSize = memorySize
	perception = Perception
	l_debug("initiated explorer with id: "..id)


end

function handleEvent(origX, origY, eventID,eventDesc , eventTable)
	
	loadstring("msg="..eventTable)()

	-- teleport to base ignore scope
	if eventDesc == "base" and msg.msg_type == "initiate" and msg.baseId == bId then
		--l_debug("explorer")
		l_updatePosition(posX, posY, origX, origY)
		posX = origX
		posY = origY
		baseX = origX
		baseY = origY
		--toBase = true
		enable=true
	
	 	l_debug("tp and enable")
	
		return 0 ,0 ,0 , "null"
	end

	-- check different company id or out of range
	if l_distance(posX, posY, origX, origY) > comScope or msg.companyId ~= cId or battery <= 0 then
		--l_debug("in check")
		return 0 ,0 ,0 , "null"

	end

	-- Message can be received -> process it based on sender type
	if eventDesc == "base" and msg.baseId == bId then
		if msg.msg_type == "full" then
			baseFull=true
			--l_debug("baseFull")
		end
	end
	if eventDesc == "base" and msg.msg_type=="location" and msg.companyId==cId then
		--l_debug("loc received: "..msg.msg_value)
		addAutonToMem(msg.msg_value)
		--l_debug(#mem)
	end
--l_debug("conti")
	return 0 ,0 ,0 , "null"

end

function initiateEvent()
	--if enable==true then l_debug("ok") end
	if battery <= 0 then enable=false end

	if enable==false then -- enable of disable the auton
		return 0 ,0 ,0 , "null"
	elseif battery<(batteryMax/10) then -- low battery go to nearest base
		if #mem>0 then
			x,y =getClosestBase()
			-- l_debug("x"..x)
			-- l_debug("y"..y)
			move(x,y)
			if posX==x and posY==y then	
				battery=batteryMax
			end
		end
	elseif baseFull then -- base full go back
		move(baseX,baseY)
		if posX==baseX and posY==baseY then	
			calltable = {baseId=bId,companyId=cId, msg_type = "back", msg_value = "back"}
			s_calltable = serializeTbl(calltable) 
			propagationSpeed = 0
			eventDesc = "explorer"
			targetID = 0; -- broadcast
			enable=false
			return propagationSpeed, s_calltable, eventDesc, targetID
		end
	else -- ore foubd send coordinates
		dx,dy=randomDirection()
		-- if battery <100 then l_debug(battery) end
		--l_debug(dy)
		 move(dx,dy)
		 scan(posX,posY)

		if #ore>0 then
			battery=battery-msgCost
			calltable = {companyId = cId, msg_type = "ore", msg_value = ore[1]}
			--l_debug(ore[1])
			table.remove(ore,1)
			s_calltable = serializeTbl(calltable) 
			propagationSpeed = 0
			eventDesc = "explorer"
			targetID = 0; -- broadcast
		return propagationSpeed, s_calltable, eventDesc, targetID
		end	
	end
	return 0 ,0 ,0 , "null"
end

--get sync data
function getSyncData()
	return posX, posY
end

function simDone()
	-- l_debug("explorer #: " .. ID .. " is done")
	-- l_debug("bat: "..battery)
	-- l_debug("cid: "..cId)
	-- l_debug("cur ore: "..currentOre)
	-- l_debug("comScope: "..comScope)
	-- l_debug("bid: "..bId)
 --  	l_debug("X: "..posX)
	-- l_debug("Y: "..posY)
	-- l_debug("id: "..ID)
	-- l_debug("macro: "..macroF)
	-- l_debug("time res: "..timeRes)
	-- l_debug("move cost: "..movementCost)
	-- l_debug("msg cost: "..msgCost)
	-- l_debug("scan cost: "..scanningCost)
	-- l_debug("mem size: "..memSize)
	-- l_debug("perceptions: "..perception)
end


function serializeTbl(val, name, depth)
    --skipnewlines = skipnewlines or false
    depth = depth or 0
    local tbl = string.rep("", depth)
    if name then
        if type(name)=="number" then
            namestr = "["..name.."]"
            tbl= tbl..namestr.."="
        elseif name then
            tbl = tbl ..name.."="
        end   
    end
    if type(val) == "table" then
        tbl = tbl .. "{"
        local i = 1
        for k, v in pairs(val) do
            if i ~= 1 then
                tbl = tbl .. ","
            end   
            tbl = tbl .. serializeTbl(v,k, depth +1)
            i = i + 1;
        end
        tbl = tbl .. string.rep(" ", depth) ..  "}"
    elseif type(val) == "number" then
        tbl = tbl .. tostring(val)
    elseif type(val) == "string" then
        tbl = tbl .. string.format("%q", val)
    else
        tbl = tbl .. "[datatype not serializable:".. type(val) .. "]"
    end 

    return tbl
end

function getClosestBase()
	store=0
	pr=1000
	save=0
	if #mem==0 then
		x=baseX
		y=baseY
	else	
		for i=1,#mem,1 do
			x,y= msgToInt(mem[i])
			store=l_distance(posX,posY,x,y)
			if store<pr then
				pr=store
				save=i
			end
		end
		x,y =msgToInt(mem[save])
	end
	return x,y
end

function move(newLocX,newLocY)
	x=posX
	y=posY
	if posX<newLocX then x=x+1
	elseif posX>newLocX then x=x-1 end
	if posY<newLocY then y=y+1
	elseif posY>newLocY then y=y-1 end
	
	if x>mapSize-1 then x=0 end
	if x<0 then x=mapSize end
	if y>mapSize-1 then y=0 end
	if y<0 then y=mapSize-1 end
	
	--if l_checkCollision(x,y)==0 then
		l_updatePosition(posX, posY, x, y,ID)
		posX=x
		posY=y
		battery=battery- movementCost
	--end
end

function msgToInt(str)
	a=tonumber(string.sub(str,1,3))
	b=tonumber(string.sub(str,4,6))
	return a , b
end

function intToMsg(int,int2)
	a=""
	b=""
	if int<10 then
		a="00"..tostring(int)
	elseif int<100 then
		a="0"..tostring(int)
	else
		a=tostring(int)		
	end
	if int2<10 then
		b="00"..tostring(int2)
	elseif int2<100 then
		b="0"..tostring(int2)
	else
		b=tostring(int2)
	end
	
	return a..b
end

function scan(int,int2)
	battery=battery- scanningCost
	for i=int-perception,int+perception,1 do
		for j=int2-perception,int2+perception,1 do
			r,g,b = l_checkMap(i,j)
			--l_debug("scanning")
			if b>0 then
				--l_debug("ore found")
				addOreToMem(intToMsg(i,j))
				--l_debug(ore[1])
				--l_debug(ore[2])
			else
				l_modifyMap(i,j,0,100,0)
			end
		end
	end
end


function randomDirection()
    posX_new = posX
    posY_new = posY


    -- usually check collision of new pos here... but not working
    while (posX_new == posX and posY_new == posY) do
        posX_new = posX + l_getMersenneInteger(0, 2) - 1
        posY_new = posY + l_getMersenneInteger(0, 2) - 1
    end

    return posX_new, posY_new
end

function perceptionAdjustment(int)
	for Index, Value in pairs(mem) do
		if l_distance(tonumber(string.sub(Value,1,3)),tonumber(string.sub(Value,4,6)))<11 then
     		 perception=8 
		elseif l_distance(tonumber(string.sub(Value,1,3)), tonumber(string.sub(Value,4,6)))<5 then
			 perception=5
		else perception=PerceptionScope end
	end
end

function addAutonToMem(str)
	check=false
	if #mem>0 then

		for index,value in pairs(mem) do
			if value==str then
				check=true
				--l_debug("true")
				break
			end
		end
	end
	if check==false then
		--l_debug("incerted")
	 	table.insert(mem,str)
	end
end

function addOreToMem(str)
	check=true
	if #ore>0 then
		for index,value in pairs(ore) do
			if value==str then
				check=false
				break
			end
		end
	end
	if check then table.insert(ore,str) end
end
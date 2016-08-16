posX = 0
posY = 0
battery = 0
batteryMax =0
macroF = 0
timeRes = 0
currentOre = 0
comScope=0
mapSize=200
--- base info --
baseX=0
baseY=0

--- id ---
ID = 0
cId=0
bId=0
--- energy cost --
movementCost=0
orePickCost=0
msgCost=0
--capacity=0
memSize =0

--- arrays for mem ---
ore= {}
mem={}

colCap=false
enable=false
baseFull=false

-----------
added=false

function initTransporter(x, y, id, macroFactor, timeResolution, ComScope, CompanyID, BaseID, Battery, MovementCost,OrePickCost,MessageCost, memorySize,MaxCap)
	posX=x
	posY=y
	ID=id
	macroF=macroFactor
	timeRes = timeResolution
	comScope=ComScope
	cId =CompanyID
	bId =BaseID
	batteryMax= Battery
	
	movementCost= MovementCost
	orePickCost=OrePickCost
	msgCost=MessageCost
	memSize = memorySize
	maxCap=MaxCap

		l_debug("initiated explorer with id: "..id)

end

function handleEvent(origX, origY, eventID ,eventDesc , eventTable)
	
	loadstring("msg="..eventTable)()

	-- teleport to base (ignore communication scope)
	if eventDesc == "base" and msg.msg_type == "initiate" and msg.baseId == bId then
		--l_debug("explorer")
		l_updatePosition(posX, posY, origX, origY)
		posX = origX
		posY = origY
		baseX = origX
		baseY = origY
		--toBase = true
		enable=true
		battery=batteryMax
	 	l_debug("tp and enable")
	
		return 0 ,0 ,0 , "null"
	end

	-- check different company id or out of range
	if l_distance(posX, posY, origX, origY) > comScope or msg.companyId ~= cId or battery <= 0 then
		return 0 ,0 ,0 , "null"
	end
	--l_debug("ok")
	--Message can be received -> process it based on sender type
	if eventDesc == "base" and msg.baseId == bId then
		if msg.msg_type == "full" then
			baseFull=true
	 		--l_debug("baseFull")
		end
	end

	if eventDesc=="explorer" and msg.msg_type=="ore" then
			addOreToMem(msg.msg_value)
			--l_debug("received: "..msg.msg_value)
			--l_debug(#ore)

	end
	if eventDesc == "base" and msg.msg_type=="location" and msg.companyId==cId then
		--l_debug("loc received: "..msg.msg_value)
		addAutonToMem(msg.msg_value)
		--l_debug(mem[1])
	end
	if eventDesc=="transporter" and msg.msg_type=="ore" then
			deleteOreFromMem(msg.msg_value)
	end		
	return 0 ,0 ,0 , "null"
end

function initiateEvent()
	
	--l_debug("battery "..battery)
	if battery<=0 then enable=false end
 	--l_debug(posX..posY)
	if enable==false then
	 	return 0 ,0 ,0 , "null"

	elseif baseFull then -- base full go back
		move(baseX,baseY)
		if posX==baseX and posY==baseY then	
			enable=false
			calltable = {baseId=bId,companyId=cId, msg_type = "back", msg_value = "back"}
			s_calltable = serializeTbl(calltable) 
			propagationSpeed = 0
			eventDesc = "transporter"
			targetID = 0; -- broadcast
			
			return propagationSpeed, s_calltable, eventDesc, targetID
		end
 	
	elseif battery<80  then--or currentOre == maxCap then -- low battery go to nearest base
		

			x,y =getClosestBase()
			--l_debug("x"..x)
			--l_debug("y"..y)
	 		move(x,y)
	 		l_debug(x..y)

			if posX==x and posY==y then	
				battery=batteryMax
				l_debug("refill")
			end
		
	elseif currentOre >= 12 then -- ore max return to nearest base
		l_debug("in")
			x,y =getClosestBase()
			--l_debug("x"..x)
			--l_debug("y"..y)
	 		move(x,y)
			if posX==x and posY==y then	
				

				calltable = {companyId = companyId, msg_type = "delivery",msg_value= currentOre}
				s_calltable = serializeTbl(calltable) 
				propagationSpeed = 0
				desc = "transporter"
				targetID = 0; -- broadcast
				currentOre=0
				return propagationSpeed, s_calltable, desc, targetID
			end
		

	else
		if #ore>0 then

			ox,oy=getClosestOre()
			 --l_debug(ox)
			 --l_debug(oy)
			--l_debug(#ore)
			move(ox,oy)
			if posX==ox and posY==oy then
				collectOre()
				battery=battery-orePickCost
				deleteOreFromMem(intToMsg(posX,posY))			
				
				calltable = {companyId = companyId, msg_type = "ore",msg_value= posX,posY}
				s_calltable = serializeTbl(calltable) 
				propagationSpeed = 0
				desc = "transporter"
				targetID = 0; -- broadcast
				return propagationSpeed, s_calltable, desc, targetID
			end
		end
	end
		
		
		
	
	return 0 ,0 ,0 , "null"
end

--get sync data
function getSyncData()
	return posX, posY
end

function simDone()
	l_debug("explorer #: " .. ID .. " is done")
	l_debug("bat: "..battery)
	l_debug("cid: "..cId)
	l_debug("cur ore: "..currentOre)
	l_debug("comScope: "..comScope)
	l_debug("bid: "..bId)
  	l_debug("X: "..posX)
	l_debug("Y: "..posY)
	l_debug("id: "..ID)
	l_debug("macro: "..macroF)
	l_debug("time res: "..timeRes)
	l_debug("move cost: "..movementCost)
	l_debug("msg cost: "..msgCost)
	
	l_debug("mem size: "..memSize)
	
end
function collectOre()
	l_modifyMap(posX,posY,0,0,0)
	currentOre=currentOre+1
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

function getClosestOre()
	--l_debug(#ore)
	if #ore >0 then
		
		s= msgToInt(math.random(1,#ore))
		x,y=msgToInt(ore[s])
		return x,y
	else
		x=baseX
		y=baseY
	end
	return x,y
end

function msgToInt(str)
	--l_debug(str)
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

function deleteOreFromMem(str)
	if #ore>1 then
		for index,value in pairs(ore) do
			if value==str then
				table.remove(ore,index)
				break
			end
		end
	end
end
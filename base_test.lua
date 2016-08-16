posX = 0
posY = 0
ID = 0
macroF = 0
timeRes = 0
maxCap = 0 -- maximum capacity
coop = 0 -- mode
comScope = 0 -- comunication scope
time = 0 -- time passed
cap = 202 -- current capacity
startup = 1 -- to spawn the 
cId = 0 -- company id
bId = 0 -- base id
explorers = 0
transporters = 0
deliveryOre = 0 -- ore delivered every time


function initAuton(x, y, id, macroFactor, timeResolution , C , M, CS, T, CID ,BID, DeliveryOre)
  	cId = CID
  	bId=BID
	coop = M
	comScope = CS
	time = T
  	maxCap = C
	posX = 100
	posY = 100
	ID = id
	macroF = macroFactor
	timeRes = timeResolution
	deliveryOre = DeliveryOre
	l_debug("Agent #: " .. id .. " has been initialized")
	--l_debug("BaseID: "..bId)
end


-- Event Handling:
function handleEvent(origX, origY, eventID,eventDesc , eventTable)
--function handleEvent(origX, origY, origID, origDesc, eventTable)
	loadstring("msg="..eventTable)()
	if l_distance(posX, posY, origX, origY) > comScope or msg.companyId ~= cId  then -- check if in range of scope and id
		return 0 ,0 ,0 , "null"
	
	elseif eventDesc == "explorer" then 
		if msg.msg_value=="back" then increaseAutonCounter("e") end

	elseif eventDesc == "transporter" then
		if masg.msg_type== "back" then increaseAutonCounter("t") end

	elseif msg.msg_type == "delivery" and msg.msg_value > 0 then
		increaseCap(deliveryOre)
			
		l_debug("Base #"..bId..": I got "..msg.msg_value.." Ore sample(s), now having "..cap.."/"..maxCap)
	
	end
	return 0 ,0 ,0 , "null"
end

function initiateEvent()
	
	--l_debug(startup)
	if startup == 1 then
		-- start form the base
		calltable = {baseId = bId, companyId = cId, msg_type = "initiate", msg_value = ""}
		l_debug("STARTUP")
		l_debug(intToMsg(posX,posY))
		startup = 0
		
	elseif cap>=maxCap then
		
		calltable = {baseId = bId,companyId = cId, msg_type = "full",msg_value=""}
		--l_debug("cap reached")
	--else
	-- 	--l_debug("give base loc")
	-- 	calltable = {baseId = bId, companyId = cId, msg_type = "location", msg_value = intToMsg(posX,posY)}
	 end
	
	propagationSpeed = 0
	targetID = 0; -- broadcast to all	
	eventDesc = "base"
	s_calltable = serializeTbl(calltable) 
	
	return propagationSpeed, s_calltable, eventDesc, targetID
		
end

function getSyncData()
	return posX, posY
end

function simDone()
	l_debug("Base #: " .. ID .. " is done")
	l_debug("ore collected: " .. cap)
	l_debug("explorers returned: " .. explorers)
	l_debug("collectors returned: " .. transporters )
	-- l_debug(cId)
	-- l_debug(coop)
	-- l_debug(comScope)
	-- l_debug(time)
 --  	l_debug(maxCap)
	-- l_debug(posX)
	-- l_debug(posY)
	-- l_debug(ID)
	-- l_debug(macroF)
	-- l_debug(timeRes)
	-- l_debug(deliveryOre)
	
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

function increaseCap(int)
	cap=cap+int
	if cap > maxCap then
		cap = maxCap
	end
end

function increaseAutonCounter(char)
	if char=="t" then transporters=transporters+1 end
	if char=="e" then explorers=explorers+1 end
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
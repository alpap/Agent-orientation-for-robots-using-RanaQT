----------------transporter---------------
function move(newLocX,newLocY)
	x=posX
	y=posY
	--mapsize=200
	if posX<newLocX then x=x+1
	elseif posX>newLocX then x=x-1
	if posY<newLocY then y=y+1
	elseif posY>newLocY then y=y-1
	
	if x>mapSize-1 then x=0
	if x<0 then x=mapSize
	if y>mapSize-1 then y=0
	if y<0 then y=mapSize
	
	if l_checkCollision(x,y)==0 then
		l_updatePosition(posX, posY, x, y,ID)
		posX=x
		posY=y
		batteryUpdate(moveCost)
	end
end

function batteryUpdate(int)
	battery=battery+int
end

function perceptionAdjustment(int)
	for Index, Value in pairs(mem) do
		if l_distance(tonumber(string.sub(Value,1,3)),tonumber(string.sub(Value,4,6)))<11 then
      perception=8 
		elseif l_distance(tonumber(string.sub(Value,1,3)), tonumber(string.sub(Value,4,6)))<5 then perception=5
		else perception=PerceptionScope
	end
end

---------------base------------------
function increaseCap(int)
	cap=cap+int
	if cap > maxCap then
		cap = maxCap
	end
end

function increaseAutonCounter(char)
	if char=="t" then transporters=transporters+1
	if char=="e" then explorers=explorers+1
end

function addToMemory(int,int2)
	table.incert(mem,tostring(int)..tostring(int2))
end

function addAutonToMem(string)
	check=true
	if #mem>1 then
		for index,value in pairs(mem) do
			if value==string then
				check=false
				break
			end
		end
		if check then table.insert(mem,string)
	else 
		table.insert(mem,string)
	end
end

------------collector------------------
function addOreToMem(str)
	check=true
	if #ore>1 then
		for index,value in pairs(ore) do
			if value==str then
				check=false
				break
			end
		end
	end
	if check then table.insert(ore,str)
end

function intToMsg(int,int2)
	a=tostring(int)..tostring(int2)
	return a
end

function msgToInt(string)
	a=tonumber(string.sub(int,1,3))
	b=tonumber(string.sub(int2,4,6))
	return a , b
end


function orePickedUp(int, int2)
	batteryUpdate(orePickCost)
	for index,value in pairs(ore) do
		if value==int2string(int,int2) then
			table.remove(ore,index)
			
		end
	end
	
end

function die()
	enable=false
end

function scan(int,int2)
	batteryUpdate(perceptionCost)
	for i=int-perceptionScope,int+perceptionScope,1 do
		for j=int2-perceptionScope,int2+perceptionScope,1 do
			r,g,b = l_checkMap(i,j)
			if b==255 then
				addOreToMem(int,int2)
			end
		end
	end
end

function sendOreCoordinates()
	batteryUpdate(msgCost)
	calltable = {ID = ID, companyId = companyId, msg_type = "ore", msg_value = ore[1]}
	s_calltable = serializeTbl(calltable) 
	propagationSpeed = 0
	desc = "ore"
	targetID = 0; -- broadcast
	return propagationSpeed, s_calltable, desc, targetID
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

function getClosestBase()
	store=0
	pr=1000
	save=0
	for i=1,#mem,1 do
		x,y= msgToInt(mem[i])
		store=l_distance(posX,posY,x,y)
		if store<pr then
			pr=store
			save=i
		end
	end
	x,y =msgToInt(mem[save])
	return x,y
end


function getClosestOre()
	store=0
	pr=1000
	save=0
	if #ore>1 then
		for i=1,#ore,1 do
			x,y= msgToInt(ore[i])
			store=l_distance(posX,posY,x,y)
			if store<pr then
				pr=store
				save=i
			end
		end
		return x,y =msgToInt(ore[save])
  end
	
		return x,y =msgToInt(ore[1])
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

function collectOre()
	l_modifyMap(posx,posY,0,0,0)
end

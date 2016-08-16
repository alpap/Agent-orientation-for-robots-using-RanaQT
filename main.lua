C=200 -- base capacity
N=1 -- number of baces
D=5 -- ore density
G=200 -- map size
M=0 -- cooperation mode 
CS=31 -- comunication scope
PS=11 -- perception scope
S=15 -- robot memory size
T=100000 --time for emulation
W=12 -- transporter ore capacity
X=8 -- explorers
Y=8 -- transporters
CID=1 -- company ID
BID =1 -- base ID
DeliveryOre=12 -- max collector ore
Battery = 800
OrePickCost =1
MovementCost = 1
MessageCost =1
ScanningCost =1
MessageCost =1


function initAuton(x, y, id, macroFactor, timeResolution)	

	--while id % N ~=0 do
		if id==1 then
			dofile([[/home/log/Dropbox/new agent oriented/new_program/base.lua]])
			initAuton(x,y,id, macroFactor,timeResolution , C , M ,CS , T,CID,BID, DeliveryOre)
		end
  --end
  
  -- while id % (X+N) ~=0 do
  		if id >1 and id<10 then
			dofile([[/home/log/Dropbox/new agent oriented/new_program/explorer.lua]])
			initExp(x, y, id, macroFactor, timeResolution, CS, T, CID, BID, Battery, MovementCost,ScanningCost, MessageCost, S, PS)
  		end
  --end
	
  
		if id >9 and id<18 then
			dofile([[/home/log/Dropbox/new agent oriented/new_program/collector.lua]])
			initTransporter(x, y, id, macroFactor, timeResolution, CS, CID, BID, Battery, MovementCost,OrePickCost, MessageCost, S,W)  
  		end
 
  
  
  
  end
	

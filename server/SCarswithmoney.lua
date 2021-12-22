class 'carswithmoney'

function carswithmoney:__init()
    self.moneyvehicles               = {}
	self.kposition ={} -- positions are stored here
           -- Load spawns
    self:LoadSpawns( "spawns.txt" )
    -- Subscribe to events
     Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
     Events:Subscribe( "PlayerEnterVehicle",self, self.Givethemoneyandblowthecar )
   end

-- Functions to parse the spawns
function carswithmoney:LoadSpawns( filename )
    -- Open up the spawns
    print("Opening " .. filename)
    local file = io.open( filename, "r" )

    if file == nil then
        print( "No spawns.txt, aborting loading of spawns" )
        return
    end

    -- Start a timer to measure load time
    local timer = Timer()

    -- For each line, handle appropriately
    for line in file:lines() do
        if line:sub(1,1) == "V" then
            self:ParseVehicleSpawn( line )
         end
    end
    
    print( string.format( "Loaded spawns, %.02f seconds", 
                            timer:GetSeconds() ) )

    file:close()
end

function carswithmoney:ParseVehicleSpawn( line )
    -- Remove start, end and spaces from line
    line = line:gsub( "VehicleSpawn%(", "" )
    line = line:gsub( "%)", "" )
    line = line:gsub( " ", "" )

    -- Split line into tokens
    local tokens = line:split( "," )   

    -- Model ID string
    local model_id_str  = tokens[1]

    -- Create tables containing appropriate strings
    local pos_str       = { tokens[2], tokens[3], tokens[4] }
    local ang_str       = { tokens[5], tokens[6], tokens[7] } --  tokens[8]

    -- Create vehicle args table
    local args = {}

    -- Fill in args table
    args.model_id       = tonumber( model_id_str )
    args.position       = Vector3(   tonumber( pos_str[1] ), 
                                    tonumber( pos_str[2] ),
                                    tonumber( pos_str[3] ) )

    args.angle          = Angle(    tonumber( ang_str[1] ),
                                    tonumber( ang_str[2] ),
                                    tonumber( ang_str[3] ) )
									
                                     -- tonumber( ang_str[4] ) 

    if #tokens > 7 then
        if tokens[8] ~= "NULL" then
            -- If there's a template, set it
            args.template = tokens[9]
        end

        if #tokens > 8 then
            if tokens[9] ~= "NULL" then
                -- If there's a decal, set it
                args.decal = tokens[9]
            end
        end
    end
  math.randomseed(os.clock())
 args.tone1= math.random(10,50),math.random(10,50),math.random(10,50),math.random(1,10)
 args.tone2= math.random(10,50),math.random(10,50),math.random(10,50),math.random(1,10)
    -- Create the vehicle
    args.enabled = true
	table.insert(self.kposition,args.position)
    local v = Vehicle.Create( args )

    -- Save to table
    self.moneyvehicles[ v:GetId() ] = v
end

function carswithmoney:ModuleUnload( args )
    -- On unload, remove all valid vehicles
    for k,v in pairs(self.moneyvehicles) do
        if IsValid(v) then
            v:Remove()
        end
    end
	 for k,v in pairs(self.kposition) do
            v=nil
        end
    end


function carswithmoney:Givethemoneyandblowthecar( args )
local player =args.player
local congrats = "====================CONGRATULATIONS=================== You just found a secret money stash!Keep searching! There are many more around Panau. "
		for k,v in ipairs(self.kposition) do-- go through every element in the table
			if v==args.vehicle:GetPosition() then  -- if the car position is the same as one in the table
				player:SetMoney(player:GetMoney() + 500000) -- give money
				args.vehicle:SetHealth(0.1)				-- and blow up the car		        					
				local cmd = SQL:Command(" insert into playerBounties (target,bounty) values (?,?) " )-- also this is where the adding a bounty of 10% of the money value should be
	              cmd:Bind ( 1, player:GetSteamId().id )
				  cmd:Bind ( 2, 50000 )
				  cmd:Execute()	
				 player:SendChatMessage( congrats,Color(255,100,0) )
				
			end
			end
			end
			
-- Create our class, and start the script proper
carswithmoney = carswithmoney()
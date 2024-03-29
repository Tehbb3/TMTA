
-- configuration
local config = {
    side = {
        monitor = "left",
        modem = "back"
    },
    network = {
        serverPort = 1000, -- port to send to server
        clientPort = 2000, -- listen port for client
        slavePort = 3000, -- send port for the slave
    }

}


term.clear()
term.setCursorPos(1,1)
print("________  ______      ____")
print("/_  __/  |/  / _ |____/ __/")
print(" / / / /|_/ / __ /___/\\ \\ ") 
print("/_/ /_/  /_/_/ |_|  /___/ ")
local currentControl = 0 -- host 0 is all
local currentFuel = 0
local totalSlaves = 0


local controlPrefix = "C>"
-- local monitor = peripheral.wrap(config.side.monitor) 
local modem = peripheral.wrap(config.side.modem)


local function display(dir)

    local runModule = true -- value so main loop can be killed
    while runModule do -- main loop


        local x, y = term.getCursorPos()

        term.setCursorPos(1, 1)
        term.clearLine()
        -- write("TehMA V1.0 | #"..currentControl.."/"..totalSlaves.." F:"..currentFuel)
        write("TehMA V1.0 | #"..currentControl.."/"..totalSlaves)

        term.setCursorPos(x, y)

        os.sleep(0.1)
    end
end


function split(pString, pPattern)
    local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
           if s ~= 1 or cap ~= "" then
          table.insert(Table,cap)
           end
           last_end = e+1
           s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
           cap = pString:sub(last_end)
           table.insert(Table, cap)
    end
    return Table
 end

local function listen()

    local runModule = true -- value so main loop can be killed
    while runModule do -- main loop


        local event, modemSide, senderChannel, 
        replyChannel, message, senderDistance = os.pullEvent("modem_message")
    
    
        -- print("===== Message Recive ======")
        -- print("Channel: "..senderChannel)
        -- print("Reply channel: "..replyChannel)
        -- print("Modem on "..modemSide.." side")
        -- print("Message contents: \n"..message)
        -- print("Sender is "..(senderDistance or "an unknown number of").." blocks away")
        term.setCursorPos(1, 19)


        
        if message.data == "IDI" then
            totalSlaves = message.qty
        end
        if message.com == "FL" then
            currentFuel = message.data
        end


        if message.data == "IDS" then 
            local data = {host=0, data="IDR", com=totalSlaves, qty=1}

            modem.transmit(config.network.slavePort, config.network.slavePort, data)
            print("IDS data requested")
        end


        if message.hidden == true then

        else

            if message.host == "C" then
                term.write("C>"..message.data)
            else
                term.write(message.host..">"..message.data)
            end



            term.scroll(1)


            term.setCursorPos(1, 19)
            term.clearLine()
            term.write(controlPrefix)
        end
    end

end



local function ui()

    local runModule = true -- value so main loop can be killed
    while runModule do -- main loop

        -- setup ui
        term.setCursorPos(1, 19)
        term.clearLine()
        term.write(controlPrefix)
        local input = read()

        if input ~= "" then

            term.setCursorPos(1, 19)
            -- term.write("C>"..input)
            -- term.scroll(1)

            local inputSplit =  split(input, " ")

            if inputSplit[1] == "BE" then -- set controlled host
                currentControl = inputSplit[2]
            else -- foward other commands
                
                local times = 1
                if inputSplit[2] == nil then
                    times = 1
                else
                    times = tonumber(inputSplit[2])
                end

                local data = {host=currentControl, com="NO", data=inputSplit[1], qty=times}
                modem.transmit(config.network.slavePort, config.network.clientPort, data)
            end
        end
    
    end

end


local function grabber()


    local runModule = true -- value so main loop can be killed
    while runModule do -- main loop

       -- print("Attempting to resolve DID with network...")

        local data = {host=0, com="NO", data="IDS", qty=1}

        modem.transmit(config.network.slavePort, config.network.clientPort, data)

        local runModuleGrabDID = true
        while runModuleGrabDID do -- main loop

            -- print("Listening for DID")

            local event, modemSide, senderChannel, 
            replyChannel, message, senderDistance = os.pullEvent("modem_message")
        
            if (tonumber(message.host) == 0) then -- only care if need to

                if message.data == "IDR" then

                    -- print("Network DID data recevied")
                    totalSlaves = message.com
                    -- slaveID = totalSlaves + 1
                    -- totalSlaves = totalSlaves + 1
        
                    runModuleGrabDID = false
                    -- print("Run module killed")
                

                end

            end
            sleep(1) -- dont go too fast
        end






        -- print("Attempting to resolve DID with network...")
        if currentControl == 0 then
            currentFuel = 0
        else
                
            local data = {host=currentControl, com="NO", data="HFL", qty=1}

            modem.transmit(config.network.slavePort, config.network.clientPort, data)

            local runModuleGrabDID = true
            while runModuleGrabDID do -- main loop

                -- print("Listening for DID")

                local event, modemSide, senderChannel, 
                replyChannel, message, senderDistance = os.pullEvent("modem_message")
            
                if (tonumber(message.host) == 0) then -- only care if need to

                    if message.com == "FL" then

                        -- print("Network DID data recevied")
                        currentFuel = message.data
                        -- slaveID = totalSlaves + 1
                        -- totalSlaves = totalSlaves + 1
            
                        runModuleGrabDID = false
                        -- print("Run module killed")
                    

                    end

                end
                sleep(1) -- dont go too fast
            end

        end



    end
    

end









-- print("Display set to monitor: "..config.side.monitor.."\n")

modem.open(config.network.clientPort)
print("Opended server port: "..config.network.serverPort)



print("main function.")

term.setCursorPos(1, 18)
parallel.waitForAny(
    listen,
    ui,
    display
    -- grabber
)



    -- display(displaySide)
    -- os.sleep(0.5) -- just to limit main loop


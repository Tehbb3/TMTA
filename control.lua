
-- configuration
local config = {
    side = {
        monitor = "left",
        modem = "back"
    },
    network = {
        serverPort = 1000, -- port to send to server
        clientPort = 2000, -- listen port for client
    }

}



print("________  ______      ____")
print("/_  __/  |/  / _ |____/ __/")
print(" / / / /|_/ / __ /___/\\ \\ ") 
print("/_/ /_/  /_/_/ |_|  /___/ ")

-- local monitor = peripheral.wrap(config.side.monitor) 
local modem = peripheral.wrap(config.side.modem)

local function display(dir)
   
   monitor.setTextScale(2)

   monitor.setCursorPos(1,1)
   monitor.clearLine()
   monitor.write("Display")
end


local function listen()

    local runModule = true -- value so main loop can be killed
    while runModule do -- main loop


        local event, modemSide, senderChannel, 
        replyChannel, message, senderDistance = os.pullEvent("modem_message")
    
        print("===== Message Recive ======")
        print("Channel: "..senderChannel)
        print("Reply channel: "..replyChannel)
        print("Modem on "..modemSide.." side")
        print("Message contents: \n"..message)
        print("Sender is "..(senderDistance or "an unknown number of").." blocks away")

    end

end


local function ui()

    local runModule = true -- value so main loop can be killed
    while runModule do -- main loop


        local input = read()
        modem.transmit(config.network.serverPort, config.network.clientPort, input)

        print(input)
    
    end

end




print("Display set to monitor: "..config.side.monitor.."\n")

modem.open(config.network.clientPort)
print("Opended server port: "..config.network.serverPort)


print("main function.")

parallel.waitForAny(
    listen,
    ui
)


    -- display(displaySide)
    -- os.sleep(0.5) -- just to limit main loop

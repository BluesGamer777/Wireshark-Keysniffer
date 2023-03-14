    --we want to capture usb data for each packet 
    local usbdata = Field.new("usb.capdata")

    --the listener function, will create our tap 
    local function init_listener()
        print("[*] Started KeySniffing...\n")
    --only listen for usb packets 
        local tap = Listener.new("usb")

    --called for every packet meeting the filter set for the Listener(), so usb packets
            function tap.packet(pinfo, tvb)
    --list from http://www.usb.org/developers/ devclass_docs/Hut1_11.pdf
                local keys = "????abcdefghijklmnopqrstuvwxyz1234567890 \n??\t -=[]\\?;??,./"
    --get the usb.capdata 
                local data = usbdata()
    --make sure the packet actually has a usb.capdata field if data ~= nil then
                local keycodes = {} 
                local i = 0
    --match on everything that is a hex byte %x and add it to the table
    --this works b/c data is in format %x:%x:%x:%x 
    --it is effectively pythons split(':') function 
                for v in string.gmatch(tostring(data), "%x+") do
                    i=i+1
                    keycodes[i] = v 
                end

    --make sure we got a keypress, which is the 3rd value
    --this works on a table b/c we are using int key
                if #keycodes < 3 then 
                    return
                end

    --convert the hex key to decimal
                local code = tonumber(keycodes[3], 16) + 1 
    --get the right key mapping
                local key = keys:sub(code, code)
    --as long as it isn't '?' lets print it to stdout 
                if key ~= '?' then
                    io.write(key)
                    io.flush() 
                end
            end 
        end
        --this is called when capture is reset 
        function tap.reset()
            print("[*] Done Capturing") 
        end
        --function called at the end of tshark run 
        function tap.draw()
            print("\n\n[*] Done Processing") 
        end
    end 
    init_listener()
end
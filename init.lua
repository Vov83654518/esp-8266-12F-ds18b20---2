
-- вводим имя сети и пароль сюда
ssid,pass = "HONOR 20e","123456789";
gpio.mode(4, gpio.OUTPUT)
if (file.open('wificonf') == true)then
   ssid = string.gsub(file.readline(), "\n", "");
   pass = string.gsub(file.readline(), "\n", "");
   file.close();
end

wifi.setmode(wifi.STATION)
wifi.sta.config(ssid,pass)
wifi.sta.autoconnect(1);

temperatur = require("ds18b20")
gpio0 = 3
gpio2 = 4
temperatur.setup(gpio0)
addrs = temperatur.addrs()
temp = temperatur.read()
idial = 80
dop = 5

if(temp <= idial-dop)then 
    gpio.write(4, gpio.HIGH);
elseif(temp > idial-dop)then
    gpio.write(4, gpio.LOW);
end

t=0
tmr.alarm(0,1000, 1, function() t=t+1 if t>999 then t=0 end end)

srv=net.createServer(net.TCP, 1000)
srv:listen(80,function(conn)
    conn:on("receive",function(client,request)
    -- парсинг для отслеживания нажатий кнопок _GET
            local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
    if(_GET.pin == "ON1")then
        temperatur.setup(gpio0)
        addrs = temperatur.addrs()
        temp = temperatur.read()
    elseif(_GET.pin == "SIP")then
        temperatur.setup(gpio0)
        addrs = temperatur.addrs()
        temp = temperatur.read()
        if(dop < 300)then
            idial = idial + 5
        end
    elseif(_GET.pin == "SIM")then
        temperatur.setup(gpio0)
        addrs = temperatur.addrs()
        temp = temperatur.read()
        if(dop >= 5)then
            idial = idial - 5
        end
    elseif(_GET.pin == "SDP")then
        temperatur.setup(gpio0)
        addrs = temperatur.addrs()
        temp = temperatur.read()
        if(dop < 100)then
            dop = dop + 5
        end
    elseif(_GET.pin == "SDM")then
        temperatur.setup(gpio0)
        addrs = temperatur.addrs()
        temp = temperatur.read()
        if(dop >= 5)then
            dop = dop - 5
        end
    end

    tempn = temp - temp%1
    conn:send('HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n\
   <!DOCTYPE HTML>\
   <html><body bgcolor="#6699ff"><h1>&nbsp</h1>\
<h1 align="center"><big><big>Температура                :&nbsp'..tempn..'</big></big></h1>\
<h1 align="center"><big><big>Нагрев до                  :&nbsp'..idial..'</big></big></h1>\
<h1 align="center"><a href=\"?pin=SIM\"><button style=\"background: #ff3300; color: White; border-radius: 50px;  height:70px;  font-size: 50px;  width:200px;\">-5</button></a>&nbsp;<a href=\"?pin=SIP\">\
<button style=\"background: #B0CE3A; color: White; border-radius: 50px;  height:70px;  font-size: 50px;  width:200px;\"> +5 </button></a></h1>\
<h1 align="center"><big><big>Просадка                   :&nbsp'..dop..'</big></big></h1>\
<h1 align="center"><a href=\"?pin=SDM\"><button style=\"background: #ff3300; color: White; border-radius: 50px;  height:70px;  font-size: 50px;  width:200px;\">-5</button></a>&nbsp;<a href=\"?pin=SDP\">\
<button style=\"background: #B0CE3A; color: White; border-radius: 50px;  height:70px;  font-size: 50px;  width:200px;\">+5</button></a></h1>\
<h1 align="center"><a href=\"?pin=ON1\"><button style=\"background: #B0CE3A; color: White; border-radius: 180px; font-size: 70px;\">Обновить</button></a></h1>\
</body></html>') 
    conn:on("sent",function(conn) conn:close() end)
    collectgarbage();
    end)
end)

while true do

tmr.alarm(0, 10000, 1, function()
    tmr.alarm(0, 100, 1, function()
        temperatur = require("ds18b20")
        gpio0 = 3
        gpio2 = 4
        temperatur.setup(gpio0)
        addrs = temperatur.addrs()
        temp = temperatur.read()
        
        if(temp <= idial-dop)then 
            gpio.write(4, gpio.HIGH);
        elseif(temp > idial-dop)then
            gpio.write(4, gpio.LOW);
        end
    end)
    
      if(temp <= idial-dop)then 
        gpio.write(4, gpio.HIGH);
      elseif(temp > idial-dop)then
        gpio.write(4, gpio.LOW);
      end

end)

end

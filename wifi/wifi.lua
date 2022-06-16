lastSSID = hs.wifi.currentNetwork()
hs.application.enableSpotlightForNameSearches(true)

-- 判断ClashX是否运行,如果运行,杀掉
function killClash()
    local getApp = hs.application.get("ClashX")
    if getApp then
        getApp:kill()
    end
end
-- 判断ClashX是否运行,如果没有运行,启动
function launchClash()
    local getApp = hs.application.get("ClashX")
    if not getApp then
        hs.application.launchOrFocus("ClashX")
    end
end
function wifiLogin()
    hs.timer.doAfter(10,function()
        print("尝试登录!!!")
        local process = io.popen("curl 'http://1.1.1.3/ac_portal/login.php' --data-raw 'opr=pwdLogin&userName=dongjq&pwd=123456&rememberPwd=1'","r")
        local result = process:read("*a")
        process:close()
        print(result)
        hs.notify.new({title="网络认证", informativeText=string.sub(result, 1, 29)..'...'}):send() -- 发出通知
    end)
end

function ssidChangedCallback() -- 回调
    ssid = hs.wifi.currentNetwork() 
    -- 获取当前WiFi如果不为空
    if (ssid ~= nil) then
        -- 与之前的不一致(避免wifi断开重连重复触发动作)
        if (ssid ~= lastSSID) then
            if (ssid == 'OoO-5G' or ssid == 'OoO' or ssid == 'nancal') then
                hs.notify.new({title="网络切换", informativeText="网络切换到公司,开启Clash"}):send() -- 发出通知
                hs.audiodevice.defaultOutputDevice():setVolume(0) -- 在公司关掉扬声器
                wifiLogin()
                launchClash()
            elseif (string.find(ssid,'NETGEAR') ~= nil) then
                hs.notify.new({title="网络切换", informativeText="网络切换到家,关闭Clash"}):send()
                hs.audiodevice.defaultOutputDevice():setVolume(25) -- 在家打开扬声器
                killClash()
            else
                hs.notify.new({title="网络切换", informativeText="网络切换到其他,开启Clash"}):send()
                launchClash()
            end
            lastSSID = ssid
        end
    end
end




wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start() -- 开始监控

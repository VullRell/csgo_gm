CSGOGamemode.NetManager = {}
CSGOGamemode.NetManager.RegisterList = {}

if SERVER then
    util.AddNetworkString("CSGO_GM_NetManager")
end

function CSGOGamemode.NetManager:SendNet(id, func, target)
    if not id or not isnumber(id) then 
        Error("[CSGOGamemode] Non valid net id !\n") 
        return 
    end

    if CLIENT then
        if CurTime() - LocalPlayer().CSGO_GM_AntiSpam < 1 then 
            return
        end
        LocalPlayer().CSGO_GM_AntiSpam = CurTime()
    end

    net.Start("CSGO_GM_NetManager")
        net.WriteUInt(id, 12)
    if isfunction(func) then
        func()
    end
    if SERVER then
        if IsValid(target) and target:IsPlayer() then
            net.Send(target)
        end
        if not target then
            net.Broadcast()
        end
    else
        net.SendToServer()
    end
end

function CSGOGamemode.NetManager:Register(id, func)
    if not id or not isnumber(id) then Error("[CSGOGamemode] Non valid net id !\n") return end
    if not func or not isfunction(func) then Error("[CSGOGamemode] Non valid net function !\n") return end 

    CSGOGamemode.NetManager.RegisterList[id] = func
end

local function ReceiveNet(_, ply)
    local num = net.ReadUInt(12)

    if not CSGOGamemode.NetManager.RegisterList[num] then 
        return
    end
    
    CSGOGamemode.NetManager.RegisterList[num](ply)
end

net.Receive("CSGO_GM_NetManager", ReceiveNet)

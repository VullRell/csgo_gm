color_green = Color(0,255,0)
color_red = Color(255,0,0)

MsgC(color_green, "[CSGO Gamemode] Config start load...\n")

CSGOGamemode.Config = {}
server = CSGOGamemode.Config

--[[
    Start of config
]]

MsgC(color_green, "\tAdding variables...\n")

server.MaxPlayers = 10
server.PlayerToStart = 4
server.BombTimer = 90
server.RoundToWin = 16

server.TimerToLaunchGame = 10

server.BombSitePos =
{
    ["A"] = {
        Vector(0,0,0),
        Vector(1,1,1)
    },
    ["B"] = {
        Vector(2,2,2),
        Vector(3,3,3)
    },
}

server.TeamATColor = Color(93,121,174)
server.TeamTColor = Color(204,186,124)

server.BombModel = "models/props_c17/SuitCase001a.mdl"

--[[
    End of config
]]

MsgC(color_green, "\tConfig done !\n")

include("csgo_gm/gamemode/modules/gm_utils/sh_utils.lua")
if SERVER then
    AddCSLuaFile("csgo_gm/gamemode/modules/gm_utils/sh_utils.lua")
end

if CLIENT then
    include("csgo_gm/gamemode/modules/gm_utils/cl_utils.lua")
end

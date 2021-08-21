GM.Version      = "1.0"
GM.Name         = "CSGO Gamemode"
GM.Author       = "VullRell"
GM.Sandbox      = BaseClass

DeriveGamemode("sandbox")
DEFINE_BASECLASS("gamemode_sandbox")

CSGOGamemode = CSGOGamemode or {}

--[[---------------------------------------------------------------------------
Loading modules
---------------------------------------------------------------------------]]

local sModuleFolder = "csgo_gm/gamemode/modules"
local sContentFolder = "gamemodes/csgo_gm/content"

for _, file in pairs(file.Find(sModuleFolder.."/*", "LUA")) do
    include(sModuleFolder..file)
end

include("csgo_gm/gamemode/sh_config.lua")
AddCSLuaFile("csgo_gm/gamemode/sh_config.lua")

CSGOGamemode:PrintMessage(color_green, "[Fast-DL] Processing...")
CSGOGamemode:PrintMessage(color_green, "\tRead folders...")

local function LoadFiles(sPath, sGamePath)
    local files, directories = file.Find(sPath.."/*", sGamePath)

    for i = 1, #files do
        local file = files[i]

        if string.EndsWith(file, "lua") then
            if not string.StartWith(file, "cl_") then
                include(sPath.."/"..file)
            end
            
            AddCSLuaFile(sPath.."/"..file)
        else
            if string.find(sPath, "materials") then
                resource.AddFile("materials/vullrell/"..file)
            elseif string.find(sPath, "resource") then
                resource.AddFile("resource/fonts/"..file)
            elseif string.find(sPath, "models") then
                resource.AddFile("models/vullrell/"..file)
                util.PrecacheModel("vullrell/"..file)
            elseif string.find(sPath, "sound") then
                resource.AddFile("sound/vullrell/"..file)
                util.PrecacheSound("vullrell/"..file)
            end
        end
    end

    for i = 1, #directories do
        local dir = directories[i]

        if dir == "sh_utils" then
            continue
        end

        LoadFiles(sPath.."/"..dir, sGamePath)

        if dir == "vullrell" or dir == "fonts" then
            continue
        end

        CSGOGamemode:PrintMessage(color_green, "\t\t["..dir.."] added !")
    end
end

LoadFiles(sModuleFolder, "LUA")
CSGOGamemode:PrintMessage(color_green, "\tLoad contents...")
LoadFiles(sContentFolder, "GAME")

CSGOGamemode:PrintMessage(color_green, "[Fast-DL] Finished !")

RunConsoleCommand("sbox_weapons", "0")

CSGOGamemode:PrintMessage(color_green, "Gamemode ready !")

GM.Version      = "1.0"
GM.Name         = "CSGO Gamemode"
GM.Author       = "VullRell"
GM.Sandbox      = BaseClass

DeriveGamemode("sandbox")
DEFINE_BASECLASS("gamemode_sandbox")

CSGOGamemode = CSGOGamemode or {}

local sModuleFolder = "csgo_gm/gamemode/modules"

include("csgo_gm/gamemode/sh_config.lua")

CSGOGamemode:PrintMessage(color_green, "[Fast-DL] Processing...")
CSGOGamemode:PrintMessage(color_green, "\tRead folders...")

local function LoadFiles(sPath, sGamePath)
    local files, directories = file.Find(sPath.."/*", sGamePath)

    for i = 1, #files do
        local file = files[i]

        if file == "cl_utils.lua" then
            continue
        end

        include(sPath.."/"..file)
    end

    for i = 1, #directories do
        local dir = directories[i]

        LoadFiles(sPath.."/"..dir, sGamePath)

        CSGOGamemode:PrintMessage(color_green, "\t\t["..dir.."] added !")
    end
end

LoadFiles(sModuleFolder, "LUA")

CSGOGamemode:PrintMessage(color_green, "[Fast-DL] Finished !")

RunConsoleCommand("hud_deathnotice_time", "0")

CSGOGamemode:PrintMessage(color_green, "Gamemode ready !")

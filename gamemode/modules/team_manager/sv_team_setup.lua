local function SetupTeam()
    CSGOGamemode.TeamManager:NewTeam("AT", true, 5)
    CSGOGamemode.TeamManager:NewTeam("T", false, 5)
end
CSGOGamemode:HookRegister("InitPostEntity", "SetupCSGOTeam::TeamManager", SetupTeam)

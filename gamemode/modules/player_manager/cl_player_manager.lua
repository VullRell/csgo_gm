local function SetupVar()
    LocalPlayer().CSGO_GM_AntiSpam = CurTime()
end
CSGOGamemode:HookRegister("InitPostEntity", "LoadVar::TeamManager", SetupVar)

--[[
    Font manager: Function
]]

CSGOGamemode.Font = {}
CSGOGamemode.Font.List = CSGOGamemode.Font.List or {}
CSGOGamemode.Font.FontCreated = CSGOGamemode.Font.FontCreated or {}

local fontManager = CSGOGamemode.Font

function fontManager:CreateFont(name, size, bold)
    surface.CreateFont(name..size..bold, 
    {
        font = name,
        size = ScreenScale(size),
        bold = bold
    })

    self.FontCreated[name..size..bold] = {
        sFontName = name,
        iFontSize = size,
        iFontBold = bold
    }

    return name..size..bold
end

function fontManager:ReloadFonts()
    for name, info in pairs(self.FontCreated) do
        surface.CreateFont(info.sFontName..info.iFontSize..info.iFontBold,
        {
            font = info.sFontName,
            size = ScreenScale(info.iFontSize),
            bold = info.iFontBold
        })
    end

    for i = 1, #self.List do
        local tFontInfo = self.List[ i ]
        tFontInfo.func(tFontInfo.name..tFontInfo.size..tFontInfo.bold)
    end
end

function fontManager:HasCreatedFont(name, size, bold)
    return self.FontCreated[name..size..bold]
end

function fontManager:GetFont(name, size, bold)
    if not name or not size then
        return "DermaDefault"
    end

    bold = bold or 500

    if not self:HasCreatedFont(name, size, bold) then
        return self:CreateFont(name, size, bold)
    end

    return name..size..bold
end

function fontManager:AddFont(name, size, bold, func)
    local sFontName = self:GetFont(name, size, bold)

    self.List[ #self.List + 1 ] = 
    {
        func = func,
        name = name,
        size = size,
        bold = bold or 500
    }

    func(sFontName)
end

--[[
    Responsive manager: function
]]

CSGOGamemode.Responsive = {}
CSGOGamemode.Responsive.List = {}

local iScreenX, iScreenY = ScrW(), ScrH()
local responsiveManager = CSGOGamemode.Responsive

function responsiveManager:AddResponsive(func)
    self.List[ #self.List + 1 ] = func

    func(iScreenX, iScreenY)
end

function responsiveManager:GetX()
    return iScreenX
end

function responsiveManager:GetY()
    return iScreenY
end

local function changeValue()
    iScreenX = ScrW()
    iScreenY = ScrH()

    for i = 1, #responsiveManager.List do
        responsiveManager.List[ i ](iScreenX, iScreenY)
    end

    fontManager:ReloadFonts()
end
CSGOGamemode:HookRegister("OnScreenSizeChanged", "VRHook::ChangeValue::ResponsiveManager", changeValue)

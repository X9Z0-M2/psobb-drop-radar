local core_mainmenu = require("core_mainmenu")
local lib_helpers = require("solylib.helpers")
local lib_characters = require("solylib.characters")
local lib_items = require("solylib.items.items")
local lib_menu = require("solylib.menu")
local lib_items_list = require("solylib.items.items_list")
local lib_items_cfg = require("solylib.items.items_configuration")
local lib_claires_deal = require("solylib.items.claires_deal")
local cfg = require("Drop Radar.configuration")
local optionsLoaded, options = pcall(require, "Drop Radar.options")

local optionsFileName = "addons/Drop Radar/options.lua"
local ConfigurationWindow

local function LoadOptions()
    if options == nil or type(options) ~= "table" then
        options = {}
    end
    -- If options loaded, make sure we have all those we need
    options.configurationEnableWindow = lib_helpers.NotNilOrDefault(options.configurationEnableWindow, true)
    options.enable                    = lib_helpers.NotNilOrDefault(options.enable, true)
    options.ignoreMeseta              = lib_helpers.NotNilOrDefault(options.ignoreMeseta, false)
    options.reverseItemDirection      = lib_helpers.NotNilOrDefault(options.reverseItemDirection, false)
    options.clampItemView             = lib_helpers.NotNilOrDefault(options.clampItemView, false)
    options.invertViewData            = lib_helpers.NotNilOrDefault(options.invertViewData, false)
    options.invertTickMarkers         = lib_helpers.NotNilOrDefault(options.invertTickMarkers, false)
    options.customHudColorEnable      = lib_helpers.NotNilOrDefault(options.customHudColorEnable, false)
    options.customHudColorMarker      = lib_helpers.NotNilOrDefault(options.customHudColorMarker, 0xFFFF9900)
    options.customHudColorBackground  = lib_helpers.NotNilOrDefault(options.customHudColorBackground, 0x4CCCCCCC)
    options.customHudColorWindow      = lib_helpers.NotNilOrDefault(options.customHudColorWindow, 0xB2000000)
    options.viewingConeDegs           = lib_helpers.NotNilOrDefault(options.viewingConeDegs, 90)
    options.viewHudPrecision          = lib_helpers.NotNilOrDefault(options.viewHudPrecision, 1.0)
    options.ignoreItemMaxDist         = lib_helpers.NotNilOrDefault(options.ignoreItemMaxDist, 0)
    options.updateThrottle            = lib_helpers.NotNilOrDefault(options.updateThrottle, 0)
    options.server                    = lib_helpers.NotNilOrDefault(options.server, 1)

    if options.hud == nil or type(options.hud) ~= "table" then
        options.hud = {}
    end
    options.hud.EnableWindow                 = lib_helpers.NotNilOrDefault(options.hud.EnableWindow, true)
    options.hud.HideWhenMenu                 = lib_helpers.NotNilOrDefault(options.hud.HideWhenMenu, false)
    options.hud.HideWhenSymbolChat           = lib_helpers.NotNilOrDefault(options.hud.HideWhenSymbolChat, false)
    options.hud.HideWhenMenuUnavailable      = lib_helpers.NotNilOrDefault(options.hud.HideWhenMenuUnavailable, false)
    options.hud.changed                      = lib_helpers.NotNilOrDefault(options.hud.changed, true)
    options.hud.Anchor                       = lib_helpers.NotNilOrDefault(options.hud.Anchor, 1)
    options.hud.X                            = lib_helpers.NotNilOrDefault(options.hud.X, 50)
    options.hud.Y                            = lib_helpers.NotNilOrDefault(options.hud.Y, 50)
    options.hud.W                            = lib_helpers.NotNilOrDefault(options.hud.W, 600)
    options.hud.H                            = lib_helpers.NotNilOrDefault(options.hud.H, 50)
    options.hud.NoTitleBar                   = lib_helpers.NotNilOrDefault(options.hud.NoTitleBar, "")
    options.hud.NoResize                     = lib_helpers.NotNilOrDefault(options.hud.NoResize, "")
    options.hud.NoMove                       = lib_helpers.NotNilOrDefault(options.hud.NoMove, "")
    options.hud.AlwaysAutoResize             = lib_helpers.NotNilOrDefault(options.hud.AlwaysAutoResize, "")
    options.hud.TransparentWindow            = lib_helpers.NotNilOrDefault(options.hud.TransparentWindow, false)

    if options.hud.sizing == nil or type(options.hud.sizing) ~= "table" then
        options.hud.sizing = {}
    end
    options.hud.sizing.HitMin             = lib_helpers.NotNilOrDefault(options.hud.sizing.HitMin, 40)
    options.hud.sizing.LowHitWeaponsH     = lib_helpers.NotNilOrDefault(options.hud.sizing.LowHitWeaponsH,  10)
    options.hud.sizing.HighHitWeaponsH    = lib_helpers.NotNilOrDefault(options.hud.sizing.HighHitWeaponsH,  86)
    options.hud.sizing.UselessArmorsH     = lib_helpers.NotNilOrDefault(options.hud.sizing.UselessArmorsH,  25)
    options.hud.sizing.MaxSocketArmorH    = lib_helpers.NotNilOrDefault(options.hud.sizing.MaxSocketArmorH,  81)
    options.hud.sizing.UselessBarriersH   = lib_helpers.NotNilOrDefault(options.hud.sizing.UselessBarriersH,  25)
    options.hud.sizing.UselessUnitsH      = lib_helpers.NotNilOrDefault(options.hud.sizing.UselessUnitsH,  32)
    options.hud.sizing.UselessTechsH      = lib_helpers.NotNilOrDefault(options.hud.sizing.UselessTechsH,  35)
    options.hud.sizing.MesetaMin          = lib_helpers.NotNilOrDefault(options.hud.sizing.MesetaMin, 500)
    options.hud.sizing.MesetaMax          = lib_helpers.NotNilOrDefault(options.hud.sizing.MesetaMax,  4000)
    options.hud.sizing.MesetaMinH         = lib_helpers.NotNilOrDefault(options.hud.sizing.MesetaMinH, 45)
    options.hud.sizing.MesetaMaxH         = lib_helpers.NotNilOrDefault(options.hud.sizing.MesetaMaxH, 100)
    options.hud.sizing.WeaponsH           = lib_helpers.NotNilOrDefault(options.hud.sizing.WeaponsH,  100)
    options.hud.sizing.SRankWeaponsH      = lib_helpers.NotNilOrDefault(options.hud.sizing.SRankWeaponsH,  100)
    options.hud.sizing.ArmorsH            = lib_helpers.NotNilOrDefault(options.hud.sizing.ArmorsH,  100)
    options.hud.sizing.BarriersH          = lib_helpers.NotNilOrDefault(options.hud.sizing.BarriersH,  100)
    options.hud.sizing.UnitsH             = lib_helpers.NotNilOrDefault(options.hud.sizing.UnitsH,  100)
    options.hud.sizing.MagsH              = lib_helpers.NotNilOrDefault(options.hud.sizing.MagsH,  100)
    options.hud.sizing.ConsumablesH       = lib_helpers.NotNilOrDefault(options.hud.sizing.ConsumablesH,  90)
    options.hud.sizing.TechReverserH      = lib_helpers.NotNilOrDefault(options.hud.sizing.TechReverserH,  70)
    options.hud.sizing.TechRyukerH        = lib_helpers.NotNilOrDefault(options.hud.sizing.TechRyukerH,  70)
    options.hud.sizing.TechMegidH         = lib_helpers.NotNilOrDefault(options.hud.sizing.TechMegidH,  90)
    options.hud.sizing.TechMegidMin       = lib_helpers.NotNilOrDefault(options.hud.sizing.TechMegidMin,  26)
    options.hud.sizing.TechGrantsH        = lib_helpers.NotNilOrDefault(options.hud.sizing.TechGrantsH,  90)
    options.hud.sizing.TechGrantsMin      = lib_helpers.NotNilOrDefault(options.hud.sizing.TechGrantsMin,  26)
    options.hud.sizing.TechAnti5H         = lib_helpers.NotNilOrDefault(options.hud.sizing.TechAnti5H,  70)
    options.hud.sizing.TechAnti7H         = lib_helpers.NotNilOrDefault(options.hud.sizing.TechAnti7H,  88)
    options.hud.sizing.TechSupport15H     = lib_helpers.NotNilOrDefault(options.hud.sizing.TechSupport15H,  65)
    options.hud.sizing.TechSupport20H     = lib_helpers.NotNilOrDefault(options.hud.sizing.TechSupport20H,  75)
    options.hud.sizing.TechSupport30H     = lib_helpers.NotNilOrDefault(options.hud.sizing.TechSupport30H,  90)
    options.hud.sizing.TechSupportMin     = lib_helpers.NotNilOrDefault(options.hud.sizing.TechSupportMin,  30)
    options.hud.sizing.TechAttack15H      = lib_helpers.NotNilOrDefault(options.hud.sizing.TechAttack15H,  65)
    options.hud.sizing.TechAttack20H      = lib_helpers.NotNilOrDefault(options.hud.sizing.TechAttack20H,  75)
    options.hud.sizing.TechAttack30H      = lib_helpers.NotNilOrDefault(options.hud.sizing.TechAttack30H,  93)
    options.hud.sizing.TechAttackMin      = lib_helpers.NotNilOrDefault(options.hud.sizing.TechAttackMin,  29)
    options.hud.sizing.MonomateH          = lib_helpers.NotNilOrDefault(options.hud.sizing.MonomateH,  30)
    options.hud.sizing.DimateH            = lib_helpers.NotNilOrDefault(options.hud.sizing.DimateH,  45)
    options.hud.sizing.TrimateH           = lib_helpers.NotNilOrDefault(options.hud.sizing.TrimateH,  60)
    options.hud.sizing.MonofluidH         = lib_helpers.NotNilOrDefault(options.hud.sizing.MonofluidH,  30)
    options.hud.sizing.DifluidH           = lib_helpers.NotNilOrDefault(options.hud.sizing.DifluidH,  45)
    options.hud.sizing.TrifluidH          = lib_helpers.NotNilOrDefault(options.hud.sizing.TrifluidH,  60)
    options.hud.sizing.SolAtomizerH       = lib_helpers.NotNilOrDefault(options.hud.sizing.SolAtomizerH,  30)
    options.hud.sizing.MoonAtomizerH      = lib_helpers.NotNilOrDefault(options.hud.sizing.MoonAtomizerH,  45)
    options.hud.sizing.StarAtomizerH      = lib_helpers.NotNilOrDefault(options.hud.sizing.StarAtomizerH,  75)
    options.hud.sizing.AntidoteH          = lib_helpers.NotNilOrDefault(options.hud.sizing.AntidoteH,  20)
    options.hud.sizing.AntiparalysisH     = lib_helpers.NotNilOrDefault(options.hud.sizing.AntiparalysisH,  20)
    options.hud.sizing.TelepipeH          = lib_helpers.NotNilOrDefault(options.hud.sizing.TelepipeH,  20)
    options.hud.sizing.TrapVisionH        = lib_helpers.NotNilOrDefault(options.hud.sizing.TrapVisionH,  20)
    options.hud.sizing.ScapeDollH         = lib_helpers.NotNilOrDefault(options.hud.sizing.ScapeDollH,  75)
    options.hud.sizing.MonogrinderH       = lib_helpers.NotNilOrDefault(options.hud.sizing.MonogrinderH,  55)
    options.hud.sizing.DigrinderH         = lib_helpers.NotNilOrDefault(options.hud.sizing.DigrinderH,  70)
    options.hud.sizing.TrigrinderH        = lib_helpers.NotNilOrDefault(options.hud.sizing.TrigrinderH,  90)
    options.hud.sizing.HPMatH             = lib_helpers.NotNilOrDefault(options.hud.sizing.HPMatH,  95)
    options.hud.sizing.PowerMatH          = lib_helpers.NotNilOrDefault(options.hud.sizing.PowerMatH,  92)
    options.hud.sizing.LuckMatH           = lib_helpers.NotNilOrDefault(options.hud.sizing.LuckMatH,  100)
    options.hud.sizing.MindMatH           = lib_helpers.NotNilOrDefault(options.hud.sizing.MindMatH,  92)
    options.hud.sizing.DefenseMatH        = lib_helpers.NotNilOrDefault(options.hud.sizing.DefenseMatH,  85)
    options.hud.sizing.EvadeMatH          = lib_helpers.NotNilOrDefault(options.hud.sizing.EvadeMatH,  85)
    options.hud.sizing.ClairesDealEnable  = lib_helpers.NotNilOrDefault(options.hud.sizing.ClairesDealEnable,  false)
    options.hud.sizing.ClairesDealH       = lib_helpers.NotNilOrDefault(options.hud.sizing.ClairesDealH,  92)

    options.hud.sizing.LowHitWeaponsW     = lib_helpers.NotNilOrDefault(options.hud.sizing.LowHitWeaponsW,  0.001)
    options.hud.sizing.HighHitWeaponsW    = lib_helpers.NotNilOrDefault(options.hud.sizing.HighHitWeaponsW,  0.001)
    options.hud.sizing.UselessArmorsW     = lib_helpers.NotNilOrDefault(options.hud.sizing.UselessArmorsW,  0.001)
    options.hud.sizing.MaxSocketArmorW    = lib_helpers.NotNilOrDefault(options.hud.sizing.MaxSocketArmorW,  0.001)
    options.hud.sizing.UselessBarriersW   = lib_helpers.NotNilOrDefault(options.hud.sizing.UselessBarriersW,  0.001)
    options.hud.sizing.UselessUnitsW      = lib_helpers.NotNilOrDefault(options.hud.sizing.UselessUnitsW,  0.001)
    options.hud.sizing.UselessTechsW      = lib_helpers.NotNilOrDefault(options.hud.sizing.UselessTechsW,  0.001)
    options.hud.sizing.MesetaW            = lib_helpers.NotNilOrDefault(options.hud.sizing.MesetaW, 0.001)
    options.hud.sizing.WeaponsW           = lib_helpers.NotNilOrDefault(options.hud.sizing.WeaponsW,  0.001)
    options.hud.sizing.SRankWeaponsW      = lib_helpers.NotNilOrDefault(options.hud.sizing.SRankWeaponsW,  0.001)
    options.hud.sizing.ArmorsW            = lib_helpers.NotNilOrDefault(options.hud.sizing.ArmorsW,  0.001)
    options.hud.sizing.BarriersW          = lib_helpers.NotNilOrDefault(options.hud.sizing.BarriersW,  0.001)
    options.hud.sizing.UnitsW             = lib_helpers.NotNilOrDefault(options.hud.sizing.UnitsW,  0.001)
    options.hud.sizing.MagsW              = lib_helpers.NotNilOrDefault(options.hud.sizing.MagsW,  0.001)
    options.hud.sizing.ConsumablesW       = lib_helpers.NotNilOrDefault(options.hud.sizing.ConsumablesW,  0.001)
    options.hud.sizing.TechReverserW      = lib_helpers.NotNilOrDefault(options.hud.sizing.TechReverserW,  0.001)
    options.hud.sizing.TechRyukerW        = lib_helpers.NotNilOrDefault(options.hud.sizing.TechRyukerW,  0.001)
    options.hud.sizing.TechMegidW         = lib_helpers.NotNilOrDefault(options.hud.sizing.TechMegidW,  0.001)
    options.hud.sizing.TechMegidMin       = lib_helpers.NotNilOrDefault(options.hud.sizing.TechMegidMin,  0.001)
    options.hud.sizing.TechGrantsW        = lib_helpers.NotNilOrDefault(options.hud.sizing.TechGrantsW,  0.001)
    options.hud.sizing.TechAnti5W         = lib_helpers.NotNilOrDefault(options.hud.sizing.TechAnti5W,  0.001)
    options.hud.sizing.TechAnti7W         = lib_helpers.NotNilOrDefault(options.hud.sizing.TechAnti7W,  0.001)
    options.hud.sizing.TechSupport15W     = lib_helpers.NotNilOrDefault(options.hud.sizing.TechSupport15W,  0.001)
    options.hud.sizing.TechSupport20W     = lib_helpers.NotNilOrDefault(options.hud.sizing.TechSupport20W,  0.001)
    options.hud.sizing.TechSupport30W     = lib_helpers.NotNilOrDefault(options.hud.sizing.TechSupport30W,  0.001)
    options.hud.sizing.TechAttack15W      = lib_helpers.NotNilOrDefault(options.hud.sizing.TechAttack15W,  0.001)
    options.hud.sizing.TechAttack20W      = lib_helpers.NotNilOrDefault(options.hud.sizing.TechAttack20W,  0.001)
    options.hud.sizing.TechAttack30W      = lib_helpers.NotNilOrDefault(options.hud.sizing.TechAttack30W,  0.001)
    options.hud.sizing.MonomateW          = lib_helpers.NotNilOrDefault(options.hud.sizing.MonomateW,  0.001)
    options.hud.sizing.DimateW            = lib_helpers.NotNilOrDefault(options.hud.sizing.DimateW,  0.001)
    options.hud.sizing.TrimateW           = lib_helpers.NotNilOrDefault(options.hud.sizing.TrimateW,  0.001)
    options.hud.sizing.MonofluidW         = lib_helpers.NotNilOrDefault(options.hud.sizing.MonofluidW,  0.001)
    options.hud.sizing.DifluidW           = lib_helpers.NotNilOrDefault(options.hud.sizing.DifluidW,  0.001)
    options.hud.sizing.TrifluidW          = lib_helpers.NotNilOrDefault(options.hud.sizing.TrifluidW,  0.001)
    options.hud.sizing.SolAtomizerW       = lib_helpers.NotNilOrDefault(options.hud.sizing.SolAtomizerW,  0.001)
    options.hud.sizing.MoonAtomizerW      = lib_helpers.NotNilOrDefault(options.hud.sizing.MoonAtomizerW,  0.001)
    options.hud.sizing.StarAtomizerW      = lib_helpers.NotNilOrDefault(options.hud.sizing.StarAtomizerW,  0.001)
    options.hud.sizing.AntidoteW          = lib_helpers.NotNilOrDefault(options.hud.sizing.AntidoteW,  0.001)
    options.hud.sizing.AntiparalysisW     = lib_helpers.NotNilOrDefault(options.hud.sizing.AntiparalysisW,  0.001)
    options.hud.sizing.TelepipeW          = lib_helpers.NotNilOrDefault(options.hud.sizing.TelepipeW,  0.001)
    options.hud.sizing.TrapVisionW        = lib_helpers.NotNilOrDefault(options.hud.sizing.TrapVisionW,  0.001)
    options.hud.sizing.ScapeDollW         = lib_helpers.NotNilOrDefault(options.hud.sizing.ScapeDollW,  0.001)
    options.hud.sizing.MonogrinderW       = lib_helpers.NotNilOrDefault(options.hud.sizing.MonogrinderW,  0.001)
    options.hud.sizing.DigrinderW         = lib_helpers.NotNilOrDefault(options.hud.sizing.DigrinderW,  0.001)
    options.hud.sizing.TrigrinderW        = lib_helpers.NotNilOrDefault(options.hud.sizing.TrigrinderW,  0.001)
    options.hud.sizing.HPMatW             = lib_helpers.NotNilOrDefault(options.hud.sizing.HPMatW,  0.001)
    options.hud.sizing.PowerMatW          = lib_helpers.NotNilOrDefault(options.hud.sizing.PowerMatW,  0.001)
    options.hud.sizing.LuckMatW           = lib_helpers.NotNilOrDefault(options.hud.sizing.LuckMatW,  0.001)
    options.hud.sizing.MindMatW           = lib_helpers.NotNilOrDefault(options.hud.sizing.MindMatW,  0.001)
    options.hud.sizing.DefenseMatW        = lib_helpers.NotNilOrDefault(options.hud.sizing.DefenseMatW,  0.001)
    options.hud.sizing.EvadeMatW          = lib_helpers.NotNilOrDefault(options.hud.sizing.EvadeMatW,  0.001)
    options.hud.sizing.ClairesDealW       = lib_helpers.NotNilOrDefault(options.hud.sizing.ClairesDealW,  0.001)
end
LoadOptions()

-- Append server specific items
lib_items_list.AddServerItems(options.server)

local optionsStringBuilder = ""
local function BuildOptionsString(table, depth)
    local tabSpacing = 4
    local maxDepth = 5
    
    if not depth or depth == nil then
        depth = 0
    end
    local spaces = string.rep(" ", tabSpacing + tabSpacing * depth)
    
    --begin statement
    if depth < 1 then
        optionsStringBuilder = "return\n{\n"
    end
    --iterate over table
    for key, value in pairs(table) do
        
        local type = type(value)
        if type == "string" then
            optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("%s = \"%s\",\n", key, tostring(value))
        
        elseif type == "number" then
            -- check is float/double
            if value % 1 == 0 then
                optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("%s = %i,\n", key, tostring(value))
            else
                optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("%s = %f,\n", key, tostring(value))
            end
            
        elseif type == "boolean" or value == nil then
            optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("%s = %s,\n", key, tostring(value))
            
        --recurse
        elseif type == "table" then
            if maxDepth > 5 then
                return
            end
            optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("%s = {\n", key)
            BuildOptionsString(value, depth + 1)
            optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("},\n", key)
        end
        
    end
    --finalize statement
    if depth < 1 then
        optionsStringBuilder = optionsStringBuilder .. "}\n"
    end
end

local function SaveOptions(options)
    local file = io.open(optionsFileName, "w")
    if file ~= nil then
        BuildOptionsString(options)
        
        io.output(file)
        io.write(optionsStringBuilder)
        io.close(file)
    end
end


local playerSelfAddr = nil
local playerSelfCoords = nil
local playerSelfDirs = nil
local playerSelfNormDir = nil
local item_graph_data = {}
local item_graph_size = 200
local toolLookupTable = {}

local function updateToolLookupTable()
    toolLookupTable = {
        [0x00] = {
            [0x00] = {options.hud.sizing.MonomateW, options.hud.sizing.MonomateH, "Monomate"},
            [0x01] = {options.hud.sizing.DimateW, options.hud.sizing.DimateH, "Dimate"},
            [0x02] = {options.hud.sizing.TrimateW, options.hud.sizing.TrimateH, "Trimate"},
        },
        [0x01] = {
            [0x00] = {options.hud.sizing.MonofluidW, options.hud.sizing.MonofluidH, "Monofluid"},
            [0x01] = {options.hud.sizing.DifluidW, options.hud.sizing.DifluidH, "Difluid"},
            [0x02] = {options.hud.sizing.TrifluidW, options.hud.sizing.TrifluidH, "Trifluid"},
        },
        [0x03] = { [0x00] = {options.hud.sizing.SolAtomizerW, options.hud.sizing.SolAtomizerH, "SolAtomizer"} },
        [0x04] = { [0x00] = {options.hud.sizing.MoonAtomizerW, options.hud.sizing.MoonAtomizerH, "MoonAtomizer"} },
        [0x05] = { [0x00] = {options.hud.sizing.StarAtomizerW, options.hud.sizing.StarAtomizerH, "StarAtomizer"} },
        [0x06] = {
            [0x00] = {options.hud.sizing.AntidoteW, options.hud.sizing.AntidoteH, "Antidote"},
            [0x01] = {options.hud.sizing.AntiparalysisW, options.hud.sizing.AntiparalysisH, "Antiparalysis"},
        },
        [0x07] = { [0x00] = {options.hud.sizing.TelepipeW, options.hud.sizing.TelepipeH, "Telepipe"} },
        [0x08] = { [0x00] = {options.hud.sizing.TrapVisionW, options.hud.sizing.TrapVisionH, "TrapVision"} },
        [0x09] = { [0x00] = {options.hud.sizing.ScapeDollW, options.hud.sizing.ScapeDollH, "ScapeDoll"} },
        [0x0A] = {
            [0x00] = {options.hud.sizing.MonogrinderW, options.hud.sizing.MonogrinderH, "Monogrinder"},
            [0x01] = {options.hud.sizing.DigrinderW, options.hud.sizing.DigrinderH, "Digrinder"},
            [0x02] = {options.hud.sizing.TrigrinderW, options.hud.sizing.TrigrinderH, "Trigrinder"},
        },
        [0x0B] = {
            [0x00] = {options.hud.sizing.PowerMatW, options.hud.sizing.PowerMatH, "PowerMat"},
            [0x01] = {options.hud.sizing.MindMatW, options.hud.sizing.MindMatH, "MindMat"},
            [0x02] = {options.hud.sizing.EvadeMatW, options.hud.sizing.EvadeMatH, "EvadeMat"},
            [0x00] = {options.hud.sizing.HPMatW, options.hud.sizing.HPMatH, "HPMat"},
            [0x01] = {options.hud.sizing.DefenseMatW, options.hud.sizing.DefenseMatH, "DefenseMat"},
            [0x02] = {options.hud.sizing.LuckMatW, options.hud.sizing.LuckMatH, "LuckMat"},
        },
    }
end
updateToolLookupTable()


local function GetPlayerCoordinates(player)
    local x = 0
    local y = 0
    local z = 0
    if player ~= 0 then
        x = pso.read_f32(player + 0x38)
        y = pso.read_f32(player + 0x3C)
        z = pso.read_f32(player + 0x40)
    end

    return
    {
        x = x,
        y = y,
        z = z,
    }
end

local function GetPlayerDirection(player)
    local x = 0
    local z = 0
    if player ~= 0 then
        x = pso.read_f32(player + 0x410)
        z = pso.read_f32(player + 0x418)
    end
    
    return
    {
        x = x,
        z = z,
    }
end

local function NormalizeVec2(vec2)
    local vec2Dist = math.sqrt(vec2.x * vec2.x + vec2.z * vec2.z)
    return {
        x = vec2.x / vec2Dist,
        z = vec2.z / vec2Dist,
    }
end

local function DistanceVec2(vec2Ax,vec2Az,vec2Bx,vec2Bz)
    return math.sqrt( math.pow(vec2Ax - vec2Bx,2) + math.pow(vec2Az - vec2Bz,2) )
end

local function clampVal(clamp, min, max)
    return clamp < min and min or clamp > max and max or clamp
end

local function Norm(Val,Min,Max)
    return (Val - Min)/(Max - Min)
end
local function Lerp(Norm,Min,Max)
    return (Max - Min) * Norm + Min
end

local function shiftHexColor(color)
    return
    {
        bit.band(bit.rshift(color, 24), 0xFF),
        bit.band(bit.rshift(color, 16), 0xFF),
        bit.band(bit.rshift(color, 8), 0xFF),
        bit.band(color, 0xFF)
    }
end

local function ItemAppendGraphData(size,val,item)
    if not item then return end
    -- --debug
    -- if type(size) == "table" or type(val) == "table" then
    --     print(tostring(size))
    --     print(tostring(val))
    --     print(tostring(item))
    --     print(item)
    --     print(item.name)
    -- end
    -- --eof
    if val <1 or size == 0 or options.viewingConeDegs == 0 then return end

    if options.invertViewData then
        val = 100-val
    end

    local itemDir = {
        x = item.posx - playerSelfCoords.x,
        z = item.posz - playerSelfCoords.z,
    }
    -- ignore if item is too far away
    if options.ignoreItemMaxDist > 0 then
        if math.sqrt(itemDir.x^2 + itemDir.z^2) > options.ignoreItemMaxDist then
            return
        end
    end

    local itemNormDir = NormalizeVec2(itemDir)

    local itemFacing = {
        x = (itemNormDir.x - playerSelfNormDir.x) / 2,
        z = (itemNormDir.z - playerSelfNormDir.z) / 2,
    }
    --local itemLocalFacing = math.asin( itemNormDir.x * playerSelfNormDir.x + itemNormDir.z * playerSelfNormDir.z ) * 180/math.pi
    local itemLocalFacing
    if options.reverseItemDirection then
        itemLocalFacing = math.atan2(  playerSelfNormDir.z, playerSelfNormDir.x ) - math.atan2(  itemNormDir.z, itemNormDir.x )
    else
        itemLocalFacing = math.atan2(  itemNormDir.z, itemNormDir.x ) - math.atan2(  playerSelfNormDir.z, playerSelfNormDir.x )
    end
    if itemLocalFacing > math.pi then itemLocalFacing = itemLocalFacing - math.pi*2 end
    if itemLocalFacing < -math.pi then itemLocalFacing = itemLocalFacing + math.pi*2 end

    local itemFacingDegs = itemLocalFacing * 180/math.pi
    if options.clampItemView then
        itemFacingDegs = clampVal( itemFacingDegs , -options.viewingConeDegs, options.viewingConeDegs)
    else
        if itemFacingDegs > options.viewingConeDegs or itemFacingDegs < -options.viewingConeDegs then
            return
        end
    end

    itemFacingDegs = clampVal(
        math.floor(
            Lerp(Norm(itemFacingDegs,-options.viewingConeDegs,options.viewingConeDegs), 1, item_graph_size)
        ),
        1, item_graph_size)

    local dataCutoff = Lerp(Norm(size,0.001,5), 1, item_graph_size*0.05)
    item_graph_data[ itemFacingDegs ] = val
    for i=2, item_graph_size do
        if i < dataCutoff then
            if i % 2 > 0 then
                item_graph_data[ itemFacingDegs - math.floor((i)/2) ] = val
            else
                item_graph_data[ itemFacingDegs + math.floor((i)/2) ] = val
            end
        else
            break
        end
    end
end


local function ProcessWeapon(item, floor)

    local item_cfg = lib_items_list.t[item.hex]

    if item.weapon.isSRank == false then
        if item_cfg ~= nil and item_cfg[1] ~= 0 then
            ItemAppendGraphData( options.hud.sizing.WeaponsW, options.hud.sizing.WeaponsH, item )
        elseif floor then
            -- Hide weapon drops with less then xxHit (40 default) untekked
            if item.weapon.stats[6] >= options.hud.sizing.HitMin then
                ItemAppendGraphData( options.hud.sizing.HighHitWeaponsW, options.hud.sizing.HighHitWeaponsH, item)
            -- Show Claire's Deal 5 items
            elseif options.hud.sizing.ClairesDealEnable and lib_claires_deal.IsClairesDealItem(item) then
                ItemAppendGraphData( options.hud.sizing.ClairesDealW, options.hud.sizing.ClairesDealH, item )
            elseif item.weapon.stats[6] < options.hud.sizing.HitMin then
                ItemAppendGraphData( options.hud.sizing.LowHitWeaponsW, options.hud.sizing.LowHitWeaponsH, item )
            end            
        end
    else
        ItemAppendGraphData( options.hud.sizing.SRankWeaponsW, options.hud.sizing.SRankWeaponsH, item )
    end
end

local function ProcessFrame(item, floor)

    local item_cfg = lib_items_list.t[item.hex]

    if item_cfg ~= nil and item_cfg[1] ~= 0 then
        ItemAppendGraphData( options.hud.sizing.ArmorsW, options.hud.sizing.ArmorsH, item )
    elseif floor then
        -- Show 4 socket armors
        if item.armor.slots == 4 then
            ItemAppendGraphData( options.hud.sizing.MaxSocketArmorW, options.hud.sizing.MaxSocketArmorH, item )
        -- Show Claire's Deal 5 items
        elseif options.hud.sizing.ClairesDealEnable and lib_claires_deal.IsClairesDealItem(item) then
            ItemAppendGraphData( options.hud.sizing.ClairesDealW, options.hud.sizing.ClairesDealH, item )
        else
            ItemAppendGraphData( options.hud.sizing.UselessArmorsW, options.hud.sizing.UselessArmorsH, item )
        end
    end
end
local function ProcessBarrier(item, floor)

    local item_cfg = lib_items_list.t[item.hex]

    if item_cfg ~= nil and item_cfg[1] ~= 0 then
        ItemAppendGraphData( options.hud.sizing.BarriersW, options.hud.sizing.BarriersH, item )
    elseif floor then
        -- Show Claire's Deal 5 items
        if options.hud.sizing.ClairesDealEnable and lib_claires_deal.IsClairesDealItem(item) then
            ItemAppendGraphData( options.hud.sizing.ClairesDealW, options.hud.sizing.ClairesDealH, item )
        else
            ItemAppendGraphData( options.hud.sizing.UselessBarriersW, options.hud.sizing.UselessBarriersH, item )
        end
    end
end
local function ProcessUnit(item, floor)

    local item_cfg = lib_items_list.t[item.hex]

    if item_cfg ~= nil and item_cfg[1] ~= 0 then
        ItemAppendGraphData( options.hud.sizing.UnitsW, options.hud.sizing.UnitsH, item )
    elseif floor then
        -- Show Claire's Deal 5 items
        if options.hud.sizing.ClairesDealEnable and lib_claires_deal.IsClairesDealItem(item) then
            ItemAppendGraphData( options.hud.sizing.ClairesDealW, options.hud.sizing.ClairesDealH, item )
        else
            ItemAppendGraphData( options.hud.sizing.UselessUnitsW, options.hud.sizing.UselessUnitsH, item )
        end
    end
end
local function ProcessMag(item, fromMagWindow)
    ItemAppendGraphData( options.hud.sizing.MagsW, options.hud.sizing.MagsH, item )
end

local function ProcessTool(item, floor)
    local nameColor
    local item_cfg = lib_items_list.t[item.hex]
    local show_item = true

    if item.data[2] == 2 then
        nameColor = lib_items_cfg.techName
    else
        nameColor = lib_items_cfg.toolName
    end

    if item_cfg ~= nil and item_cfg[1] ~= 0 then
        nameColor = item_cfg[1]
    end

    if floor then
        -- Process Technique Disks
        if item.data[2] == 0x02 then
            -- Is Reverser/Ryuker
            if item.data[5] == 0x11 then
                ItemAppendGraphData( options.hud.sizing.TechReverserW, options.hud.sizing.TechReverserH, item )
            elseif item.data[5] == 0x0E then
                ItemAppendGraphData( options.hud.sizing.TechRyukerW, options.hud.sizing.TechRyukerH, item )
            -- Is Good Anti?
            elseif item.data[5] == 0x10 then
                if item.tool.level == 5 then
                    ItemAppendGraphData( options.hud.sizing.TechAnti5W, options.hud.sizing.TechAnti5H, item )
                elseif item.tool.level >= 7 then
                    ItemAppendGraphData( options.hud.sizing.TechAnti7W, options.hud.sizing.TechAnti7H, item )
                else
                    ItemAppendGraphData( options.hud.sizing.UselessTechsW, options.hud.sizing.UselessTechsH, item )
                end
            -- Is Good Megid/Grants
            elseif item.data[5] == 0x12 then
                if item.tool.level >= options.hud.sizing.TechMegidMin then
                    ItemAppendGraphData( options.hud.sizing.TechMegidW, options.hud.sizing.TechMegidH, item )
                else
                    ItemAppendGraphData( options.hud.sizing.UselessTechsW, options.hud.sizing.UselessTechsH, item )
                end
            elseif item.data[5] == 0x09 then
                if item.tool.level >= options.hud.sizing.TechGrantsMin then
                    ItemAppendGraphData( options.hud.sizing.TechGrantsW, options.hud.sizing.TechGrantsH, item )
                else
                    ItemAppendGraphData( options.hud.sizing.UselessTechsW, options.hud.sizing.UselessTechsH, item )
                end
            -- Is good support spell
            elseif item.data[5] == 0x0A or item.data[5] == 0x0B or item.data[5] == 0x0C or item.data[5] == 0x0D or item.data[5] == 0x0F then
                if item.tool.level >= options.hud.sizing.TechSupportMin then
                    ItemAppendGraphData( options.hud.sizing.TechSupport30W, options.hud.sizing.TechSupport30H, item )
                elseif item.tool.level == 15 then
                    ItemAppendGraphData( options.hud.sizing.TechSupport15W, options.hud.sizing.TechSupport15H, item )
                elseif item.tool.level == 20 then
                    ItemAppendGraphData( options.hud.sizing.TechSupport20W, options.hud.sizing.TechSupport20H, item )
                else
                    ItemAppendGraphData( options.hud.sizing.UselessTechsW, options.hud.sizing.UselessTechsH, item )
                end
            -- Is a max tier tech?
            elseif item.tool.level >= options.hud.sizing.TechAttackMin then
                ItemAppendGraphData( options.hud.sizing.TechAttack30W, options.hud.sizing.TechAttack30H, item )
            elseif item.tool.level == 15 then
                ItemAppendGraphData( options.hud.sizing.TechAttack15W, options.hud.sizing.TechAttack15H, item )
            elseif item.tool.level == 20 then
                ItemAppendGraphData( options.hud.sizing.TechAttack20W, options.hud.sizing.TechAttack20H, item )
            else
                ItemAppendGraphData( options.hud.sizing.UselessTechsW, options.hud.sizing.UselessTechsH, item )
            end

        -- Hide Monomates, Dimates, Monofluids, Difluids, Antidotes, Antiparalysis, Telepipe, and Trap Visions
        elseif  toolLookupTable[item.data[2]] ~= nil and 
                toolLookupTable[item.data[2]][item.data[3]] ~= nil and 
                toolLookupTable[item.data[2]][item.data[3]][2] then
            -- Show Claire's Deal 5 items
            if options.hud.sizing.ClairesDealEnable and lib_claires_deal.IsClairesDealItem(item) then
                ItemAppendGraphData( options.hud.sizing.ClairesDealW, options.hud.sizing.ClairesDealH, item )
            else
                local toolLookup = toolLookupTable[item.data[2]][item.data[3]]
                if toolLookup[1] ~= nil and toolLookup[2] ~= nil then
                    ItemAppendGraphData( toolLookup[1], toolLookup[2], item )
                end
            end
        else
            ItemAppendGraphData( options.hud.sizing.ConsumablesW, options.hud.sizing.ConsumablesH, item )
        end
    end
end
local function ProcessMeseta(item)
    if options.ignoreMeseta == false then
        if item.meseta >= options.hud.sizing.MesetaMin then
            local norm = Norm(item.meseta, options.hud.sizing.MesetaMin, options.hud.sizing.MesetaMax)
            ItemAppendGraphData( options.hud.sizing.MesetaW, clampVal( Lerp( norm, options.hud.sizing.MesetaMinH, options.hud.sizing.MesetaMaxH), 0, 100 ), item )
        end
    end
end
local function ProcessItem(item, floor, save, fromMagWindow)
    floor = floor or false
    save = save or false
    fromMagWindow = fromMagWindow or false

    -- Do not process disabled items when it's floor list
    -- but only when item IDs are off
    if floor == true then
        local item_cfg = lib_items_list.t[item.hex]
        if item_cfg ~= nil and item_cfg[2] == false then
            return
        end
    end

    if item.data[1] == 0 then
        ProcessWeapon(item, floor)
    elseif item.data[1] == 1 then
        if item.data[2] == 1 then
            ProcessFrame(item, floor)
        elseif item.data[2] == 2 then
            ProcessBarrier(item, floor)
        elseif item.data[2] == 3 then
            ProcessUnit(item, floor)
        end
    elseif item.data[1] == 2 then
        ProcessMag(item, fromMagWindow)
    elseif item.data[1] == 3 then
        ProcessTool(item, floor)
    elseif item.data[1] == 4 then
        ProcessMeseta(item)
    end

end

local update_delay = (options.updateThrottle * 1000)
local current_time = 0
local last_floor_time = 0
local cache_floor = nil

local function PresentHud()

    if last_floor_time + update_delay < current_time or cache_floor == nil then
        cache_floor = lib_items.GetItemList(lib_items.NoOwner, options.invertItemList)
        last_floor_time = current_time
    end
    local itemCount = table.getn(cache_floor)

    local myFloor = lib_characters.GetCurrentFloorSelf()

    playerSelfAddr    = lib_characters.GetSelf()
    playerSelfCoords  = GetPlayerCoordinates(playerSelfAddr)
    playerSelfDirs    = GetPlayerDirection(playerSelfAddr)
    playerSelfNormDir = NormalizeVec2(playerSelfDirs)
    item_graph_data  = {}
    item_graph_size = clampVal( math.floor( options.hud.W / 2 * options.viewHudPrecision ), 1, 2000 ) -- histogram likes 2 pixels per bar, so if 1000 wide, then 500 table entries will visibly not show any gaps.

    if options.invertViewData then
        for i=1, item_graph_size do
            table.insert(item_graph_data, 100)
        end
    else
        for i=1, item_graph_size do
            table.insert(item_graph_data, 0)
        end
    end

    if options.invertTickMarkers then
        item_graph_data[math.floor(Lerp(0.3,1,item_graph_size))] = 95
        item_graph_data[math.floor(Lerp(0.5,1,item_graph_size))] = 90
        item_graph_data[math.floor(Lerp(0.7,1,item_graph_size))] = 95
    else
        item_graph_data[math.floor(Lerp(0.3,1,item_graph_size))] = 5
        item_graph_data[math.floor(Lerp(0.5,1,item_graph_size))] = 10
        item_graph_data[math.floor(Lerp(0.7,1,item_graph_size))] = 5
    end

    for i=1,itemCount,1 do
        local item = cache_floor[i]
        ProcessItem(cache_floor[i], true, false)
    end

    if options.hud.NoTitleBar == "" then
        imgui.PlotHistogram("", item_graph_data, item_graph_size, 0, "", 0,100, options.hud.W-16, options.hud.H-34);
    else
        imgui.PlotHistogram("", item_graph_data, item_graph_size, 0, "", 0,100, options.hud.W-16, options.hud.H-14);
    end
end


local function present()
    -- If the addon has never been used, open the config window
    -- and disable the config window setting
    if options.configurationEnableWindow then
        ConfigurationWindow.open = true
        options.configurationEnableWindow = false
    end
    ConfigurationWindow.Update()

    if ConfigurationWindow.changed then
        ConfigurationWindow.changed = false
        updateToolLookupTable()
        SaveOptions(options)
        -- Update the delay too
        update_delay = (options.updateThrottle * 1000)
    end

    -- Global enable here to let the configuration window work
    if options.enable == false then
        return
    end

    --- Update timer for update throttle
    current_time = pso.get_tick_count()

    if (options.hud.EnableWindow == true)
        and (options.hud.HideWhenMenu == false or lib_menu.IsMenuOpen() == false)
        and (options.hud.HideWhenSymbolChat == false or lib_menu.IsSymbolChatOpen() == false)
        and (options.hud.HideWhenMenuUnavailable == false or lib_menu.IsMenuUnavailable() == false)
    then
        local windowName = "Drop Radar"

        if options.customHudColorEnable == true then
            local PlotHistogramColor = shiftHexColor(options.customHudColorMarker)
            local FrameBgColor = shiftHexColor(options.customHudColorBackground)
            local WindowBgColor = shiftHexColor(options.customHudColorWindow)
            imgui.PushStyleColor("PlotHistogram", PlotHistogramColor[2]/255, PlotHistogramColor[3]/255, PlotHistogramColor[4]/255, PlotHistogramColor[1]/255)
            imgui.PushStyleColor("FrameBg", FrameBgColor[2]/255, FrameBgColor[3]/255, FrameBgColor[4]/255, FrameBgColor[1]/255)
            imgui.PushStyleColor("WindowBg", WindowBgColor[2]/255, WindowBgColor[3]/255, WindowBgColor[4]/255, WindowBgColor[1]/255)
        end

        if options.hud.TransparentWindow == true then
            imgui.PushStyleColor("WindowBg", 0.0, 0.0, 0.0, 0.0)
        end


        if options.hud.AlwaysAutoResize == "AlwaysAutoResize" then
            imgui.SetNextWindowSizeConstraints(0, 0, options.hud.W, options.hud.H)
        end

        if imgui.Begin(windowName,
            nil,
            {
                options.hud.NoTitleBar,
                options.hud.NoResize,
                options.hud.NoMove,
                options.hud.AlwaysAutoResize,
            }
        ) then
            PresentHud()

            lib_helpers.WindowPositionAndSize(windowName,
                options.hud.X,
                options.hud.Y,
                options.hud.W,
                options.hud.H,
                options.hud.Anchor,
                options.hud.AlwaysAutoResize,
                options.hud.changed)
        end
        imgui.End()

        if options.customHudColorEnable == true then
            imgui.PopStyleColor()
            imgui.PopStyleColor()
            imgui.PopStyleColor()
        end
        if options.hud.TransparentWindow == true then
            imgui.PopStyleColor()
        end

        options.hud.changed = false
    end

end

local function init()
    ConfigurationWindow = cfg.ConfigurationWindow(options)

    local function mainMenuButtonHandler()
        ConfigurationWindow.open = not ConfigurationWindow.open
    end

    core_mainmenu.add_button("Drop Radar", mainMenuButtonHandler)

    return
    {
        name = "Drop Radar",
        version = "0.1.2",
        author = "X9Z0.M2",
        description = "Directional Indicators to Important Drops",
        present = present,
    }
end

return
{
    __addon =
    {
        init = init
    }
}

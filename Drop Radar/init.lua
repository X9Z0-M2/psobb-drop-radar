local core_mainmenu = require("core_mainmenu")
local lib_helpers = require("solylib.helpers")
local lib_characters = require("solylib.characters")
local lib_items = require("solylib.items.items")
local lib_menu = require("solylib.menu")
local lib_items_list = require("solylib.items.items_list")
local lib_items_cfg = require("solylib.items.items_configuration")
local clairesDealLoaded, lib_claires_deal = pcall(require, "solylib.items.claires_deal")
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
    options.maxNumHUDs                = lib_helpers.NotNilOrDefault(options.maxNumHUDs, 20)
    options.numHUDs                   = lib_helpers.NotNilOrDefault(options.numHUDs, 1)
    options.tileAllHuds               = lib_helpers.NotNilOrDefault(options.tileAllHuds, true)
    options.updateThrottle            = lib_helpers.NotNilOrDefault(options.updateThrottle, 0)
    options.server                    = lib_helpers.NotNilOrDefault(options.server, 1)
    options.itemDirectionReversedCount= 0

    for i=1, options.numHUDs do
        local hudIdx = "hud" .. i
        if options[hudIdx] == nil or type(options[hudIdx]) ~= "table" then
            options[hudIdx] = {}
        end
        options[hudIdx].EnableWindow                 = lib_helpers.NotNilOrDefault(options[hudIdx].EnableWindow, true)
        options[hudIdx].AlwaysOnTop                  = lib_helpers.NotNilOrDefault(options[hudIdx].AlwaysOnTop, false)
        options[hudIdx].HideWhenMenu                 = lib_helpers.NotNilOrDefault(options[hudIdx].HideWhenMenu, false)
        options[hudIdx].HideWhenSymbolChat           = lib_helpers.NotNilOrDefault(options[hudIdx].HideWhenSymbolChat, false)
        options[hudIdx].HideWhenMenuUnavailable      = lib_helpers.NotNilOrDefault(options[hudIdx].HideWhenMenuUnavailable, false)
        options[hudIdx].changed                      = lib_helpers.NotNilOrDefault(options[hudIdx].changed, true)
        options[hudIdx].Anchor                       = lib_helpers.NotNilOrDefault(options[hudIdx].Anchor, 1)
        options[hudIdx].X                            = lib_helpers.NotNilOrDefault(options[hudIdx].X, 50)
        options[hudIdx].Y                            = lib_helpers.NotNilOrDefault(options[hudIdx].Y, 50)
        options[hudIdx].W                            = lib_helpers.NotNilOrDefault(options[hudIdx].W, 600)
        options[hudIdx].H                            = lib_helpers.NotNilOrDefault(options[hudIdx].H, 50)
        options[hudIdx].NoTitleBar                   = lib_helpers.NotNilOrDefault(options[hudIdx].NoTitleBar, "")
        options[hudIdx].NoResize                     = lib_helpers.NotNilOrDefault(options[hudIdx].NoResize, "")
        options[hudIdx].NoMove                       = lib_helpers.NotNilOrDefault(options[hudIdx].NoMove, "")
        options[hudIdx].AlwaysAutoResize             = lib_helpers.NotNilOrDefault(options[hudIdx].AlwaysAutoResize, "")
        options[hudIdx].TransparentWindow            = lib_helpers.NotNilOrDefault(options[hudIdx].TransparentWindow, false)
        options[hudIdx].customHudColorEnable         = lib_helpers.NotNilOrDefault(options[hudIdx].customHudColorEnable, false)
        options[hudIdx].customHudColorMarker         = lib_helpers.NotNilOrDefault(options[hudIdx].customHudColorMarker, 0xFFFF9900)
        options[hudIdx].customHudColorBackground     = lib_helpers.NotNilOrDefault(options[hudIdx].customHudColorBackground, 0x4CCCCCCC)
        options[hudIdx].customHudColorWindow         = lib_helpers.NotNilOrDefault(options[hudIdx].customHudColorWindow, 0xB2000000)

        options[hudIdx].reverseItemDirection         = lib_helpers.NotNilOrDefault(options[hudIdx].reverseItemDirection, false)
        options[hudIdx].clampItemView                = lib_helpers.NotNilOrDefault(options[hudIdx].clampItemView, false)
        options[hudIdx].invertViewData               = lib_helpers.NotNilOrDefault(options[hudIdx].invertViewData, false)
        options[hudIdx].invertTickMarkers            = lib_helpers.NotNilOrDefault(options[hudIdx].invertTickMarkers, false)
        options[hudIdx].viewingConeDegs              = lib_helpers.NotNilOrDefault(options[hudIdx].viewingConeDegs, 90)
        options[hudIdx].viewHudPrecision             = lib_helpers.NotNilOrDefault(options[hudIdx].viewHudPrecision, 1.0)
        options[hudIdx].ignoreItemMaxDist            = lib_helpers.NotNilOrDefault(options[hudIdx].ignoreItemMaxDist, 0)

        if hudIdx == "hud1" then
            options[hudIdx].AlwaysOnTop              = lib_helpers.NotNilOrDefault(options[hudIdx].AlwaysOnTop, true)
        else
            options[hudIdx].AlwaysOnTop              = lib_helpers.NotNilOrDefault(options[hudIdx].AlwaysOnTop, true)
        end

        if options[hudIdx].reverseItemDirection then
            options.itemDirectionReversedCount = options.itemDirectionReversedCount + 1
        end

        if options[hudIdx].sizing == nil or type(options[hudIdx].sizing) ~= "table" then
            options[hudIdx].sizing = {}
        end
        options[hudIdx].sizing.HitMin             = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.HitMin, 40)
        options[hudIdx].sizing.LowHitWeaponsH     = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.LowHitWeaponsH,  10)
        options[hudIdx].sizing.HighHitWeaponsH    = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.HighHitWeaponsH,  86)
        options[hudIdx].sizing.UselessArmorsH     = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.UselessArmorsH,  25)
        options[hudIdx].sizing.MaxSocketArmorH    = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MaxSocketArmorH,  81)
        options[hudIdx].sizing.UselessBarriersH   = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.UselessBarriersH,  25)
        options[hudIdx].sizing.UselessUnitsH      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.UselessUnitsH,  32)
        options[hudIdx].sizing.UselessTechsH      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.UselessTechsH,  35)
        options[hudIdx].sizing.MesetaMin          = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MesetaMin, 500)
        options[hudIdx].sizing.MesetaMax          = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MesetaMax,  4000)
        options[hudIdx].sizing.MesetaMinH         = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MesetaMinH, 45)
        options[hudIdx].sizing.MesetaMaxH         = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MesetaMaxH, 100)
        options[hudIdx].sizing.WeaponsH           = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.WeaponsH,  100)
        options[hudIdx].sizing.SRankWeaponsH      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.SRankWeaponsH,  100)
        options[hudIdx].sizing.ArmorsH            = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.ArmorsH,  100)
        options[hudIdx].sizing.BarriersH          = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.BarriersH,  100)
        options[hudIdx].sizing.UnitsH             = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.UnitsH,  100)
        options[hudIdx].sizing.MagsH              = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MagsH,  100)
        options[hudIdx].sizing.ConsumablesH       = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.ConsumablesH,  90)
        options[hudIdx].sizing.TechReverserH      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechReverserH,  70)
        options[hudIdx].sizing.TechRyukerH        = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechRyukerH,  70)
        options[hudIdx].sizing.TechMegidH         = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechMegidH,  90)
        options[hudIdx].sizing.TechMegidMin       = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechMegidMin,  26)
        options[hudIdx].sizing.TechGrantsH        = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechGrantsH,  90)
        options[hudIdx].sizing.TechGrantsMin      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechGrantsMin,  26)
        options[hudIdx].sizing.TechAnti5H         = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechAnti5H,  70)
        options[hudIdx].sizing.TechAnti7H         = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechAnti7H,  88)
        options[hudIdx].sizing.TechSupport15H     = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechSupport15H,  65)
        options[hudIdx].sizing.TechSupport20H     = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechSupport20H,  75)
        options[hudIdx].sizing.TechSupport30H     = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechSupport30H,  90)
        options[hudIdx].sizing.TechSupportMin     = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechSupportMin,  30)
        options[hudIdx].sizing.TechAttack15H      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechAttack15H,  65)
        options[hudIdx].sizing.TechAttack20H      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechAttack20H,  75)
        options[hudIdx].sizing.TechAttack30H      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechAttack30H,  93)
        options[hudIdx].sizing.TechAttackMin      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechAttackMin,  29)
        options[hudIdx].sizing.MonomateH          = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MonomateH,  30)
        options[hudIdx].sizing.DimateH            = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.DimateH,  45)
        options[hudIdx].sizing.TrimateH           = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TrimateH,  60)
        options[hudIdx].sizing.MonofluidH         = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MonofluidH,  30)
        options[hudIdx].sizing.DifluidH           = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.DifluidH,  45)
        options[hudIdx].sizing.TrifluidH          = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TrifluidH,  60)
        options[hudIdx].sizing.SolAtomizerH       = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.SolAtomizerH,  30)
        options[hudIdx].sizing.MoonAtomizerH      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MoonAtomizerH,  45)
        options[hudIdx].sizing.StarAtomizerH      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.StarAtomizerH,  75)
        options[hudIdx].sizing.AntidoteH          = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.AntidoteH,  20)
        options[hudIdx].sizing.AntiparalysisH     = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.AntiparalysisH,  20)
        options[hudIdx].sizing.TelepipeH          = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TelepipeH,  20)
        options[hudIdx].sizing.TrapVisionH        = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TrapVisionH,  20)
        options[hudIdx].sizing.ScapeDollH         = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.ScapeDollH,  75)
        options[hudIdx].sizing.MonogrinderH       = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MonogrinderH,  55)
        options[hudIdx].sizing.DigrinderH         = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.DigrinderH,  70)
        options[hudIdx].sizing.TrigrinderH        = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TrigrinderH,  90)
        options[hudIdx].sizing.HPMatH             = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.HPMatH,  95)
        options[hudIdx].sizing.TPMatH             = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TPMatH,  95)
        options[hudIdx].sizing.PowerMatH          = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.PowerMatH,  92)
        options[hudIdx].sizing.LuckMatH           = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.LuckMatH,  100)
        options[hudIdx].sizing.MindMatH           = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MindMatH,  92)
        options[hudIdx].sizing.DefenseMatH        = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.DefenseMatH,  85)
        options[hudIdx].sizing.EvadeMatH          = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.EvadeMatH,  85)
        options[hudIdx].sizing.ClairesDealEnable  = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.ClairesDealEnable,  false)
        options[hudIdx].sizing.ClairesDealH       = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.ClairesDealH,  92)

        options[hudIdx].sizing.LowHitWeaponsW     = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.LowHitWeaponsW,  0.001)
        options[hudIdx].sizing.HighHitWeaponsW    = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.HighHitWeaponsW,  0.001)
        options[hudIdx].sizing.UselessArmorsW     = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.UselessArmorsW,  0.001)
        options[hudIdx].sizing.MaxSocketArmorW    = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MaxSocketArmorW,  0.001)
        options[hudIdx].sizing.UselessBarriersW   = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.UselessBarriersW,  0.001)
        options[hudIdx].sizing.UselessUnitsW      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.UselessUnitsW,  0.001)
        options[hudIdx].sizing.UselessTechsW      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.UselessTechsW,  0.001)
        options[hudIdx].sizing.MesetaW            = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MesetaW, 0.001)
        options[hudIdx].sizing.WeaponsW           = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.WeaponsW,  0.001)
        options[hudIdx].sizing.SRankWeaponsW      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.SRankWeaponsW,  0.001)
        options[hudIdx].sizing.ArmorsW            = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.ArmorsW,  0.001)
        options[hudIdx].sizing.BarriersW          = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.BarriersW,  0.001)
        options[hudIdx].sizing.UnitsW             = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.UnitsW,  0.001)
        options[hudIdx].sizing.MagsW              = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MagsW,  0.001)
        options[hudIdx].sizing.ConsumablesW       = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.ConsumablesW,  0.001)
        options[hudIdx].sizing.TechReverserW      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechReverserW,  0.001)
        options[hudIdx].sizing.TechRyukerW        = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechRyukerW,  0.001)
        options[hudIdx].sizing.TechMegidW         = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechMegidW,  0.001)
        options[hudIdx].sizing.TechMegidMin       = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechMegidMin,  0.001)
        options[hudIdx].sizing.TechGrantsW        = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechGrantsW,  0.001)
        options[hudIdx].sizing.TechAnti5W         = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechAnti5W,  0.001)
        options[hudIdx].sizing.TechAnti7W         = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechAnti7W,  0.001)
        options[hudIdx].sizing.TechSupport15W     = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechSupport15W,  0.001)
        options[hudIdx].sizing.TechSupport20W     = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechSupport20W,  0.001)
        options[hudIdx].sizing.TechSupport30W     = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechSupport30W,  0.001)
        options[hudIdx].sizing.TechAttack15W      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechAttack15W,  0.001)
        options[hudIdx].sizing.TechAttack20W      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechAttack20W,  0.001)
        options[hudIdx].sizing.TechAttack30W      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TechAttack30W,  0.001)
        options[hudIdx].sizing.MonomateW          = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MonomateW,  0.001)
        options[hudIdx].sizing.DimateW            = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.DimateW,  0.001)
        options[hudIdx].sizing.TrimateW           = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TrimateW,  0.001)
        options[hudIdx].sizing.MonofluidW         = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MonofluidW,  0.001)
        options[hudIdx].sizing.DifluidW           = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.DifluidW,  0.001)
        options[hudIdx].sizing.TrifluidW          = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TrifluidW,  0.001)
        options[hudIdx].sizing.SolAtomizerW       = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.SolAtomizerW,  0.001)
        options[hudIdx].sizing.MoonAtomizerW      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MoonAtomizerW,  0.001)
        options[hudIdx].sizing.StarAtomizerW      = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.StarAtomizerW,  0.001)
        options[hudIdx].sizing.AntidoteW          = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.AntidoteW,  0.001)
        options[hudIdx].sizing.AntiparalysisW     = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.AntiparalysisW,  0.001)
        options[hudIdx].sizing.TelepipeW          = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TelepipeW,  0.001)
        options[hudIdx].sizing.TrapVisionW        = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TrapVisionW,  0.001)
        options[hudIdx].sizing.ScapeDollW         = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.ScapeDollW,  0.001)
        options[hudIdx].sizing.MonogrinderW       = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MonogrinderW,  0.001)
        options[hudIdx].sizing.DigrinderW         = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.DigrinderW,  0.001)
        options[hudIdx].sizing.TrigrinderW        = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TrigrinderW,  0.001)
        options[hudIdx].sizing.HPMatW             = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.HPMatW,  0.001)
        options[hudIdx].sizing.TPMatW             = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.TPMatW,  0.001)
        options[hudIdx].sizing.PowerMatW          = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.PowerMatW,  0.001)
        options[hudIdx].sizing.LuckMatW           = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.LuckMatW,  0.001)
        options[hudIdx].sizing.MindMatW           = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.MindMatW,  0.001)
        options[hudIdx].sizing.DefenseMatW        = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.DefenseMatW,  0.001)
        options[hudIdx].sizing.EvadeMatW          = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.EvadeMatW,  0.001)
        options[hudIdx].sizing.ClairesDealW       = lib_helpers.NotNilOrDefault(options[hudIdx].sizing.ClairesDealW,  0.001)
    end
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
local item_graph_size = {}
local toolLookupTable = {}

local function updateToolLookupTable()
    for i=1, options.numHUDs do
        local hudIdx = "hud" .. i
        toolLookupTable[hudIdx] = {
            [0x00] = {
                [0x00] = {options[hudIdx].sizing.MonomateW, options[hudIdx].sizing.MonomateH, "Monomate"},
                [0x01] = {options[hudIdx].sizing.DimateW, options[hudIdx].sizing.DimateH, "Dimate"},
                [0x02] = {options[hudIdx].sizing.TrimateW, options[hudIdx].sizing.TrimateH, "Trimate"},
            },
            [0x01] = {
                [0x00] = {options[hudIdx].sizing.MonofluidW, options[hudIdx].sizing.MonofluidH, "Monofluid"},
                [0x01] = {options[hudIdx].sizing.DifluidW, options[hudIdx].sizing.DifluidH, "Difluid"},
                [0x02] = {options[hudIdx].sizing.TrifluidW, options[hudIdx].sizing.TrifluidH, "Trifluid"},
            },
            [0x03] = { [0x00] = {options[hudIdx].sizing.SolAtomizerW, options[hudIdx].sizing.SolAtomizerH, "SolAtomizer"} },
            [0x04] = { [0x00] = {options[hudIdx].sizing.MoonAtomizerW, options[hudIdx].sizing.MoonAtomizerH, "MoonAtomizer"} },
            [0x05] = { [0x00] = {options[hudIdx].sizing.StarAtomizerW, options[hudIdx].sizing.StarAtomizerH, "StarAtomizer"} },
            [0x06] = {
                [0x00] = {options[hudIdx].sizing.AntidoteW, options[hudIdx].sizing.AntidoteH, "Antidote"},
                [0x01] = {options[hudIdx].sizing.AntiparalysisW, options[hudIdx].sizing.AntiparalysisH, "Antiparalysis"},
            },
            [0x07] = { [0x00] = {options[hudIdx].sizing.TelepipeW, options[hudIdx].sizing.TelepipeH, "Telepipe"} },
            [0x08] = { [0x00] = {options[hudIdx].sizing.TrapVisionW, options[hudIdx].sizing.TrapVisionH, "TrapVision"} },
            [0x09] = { [0x00] = {options[hudIdx].sizing.ScapeDollW, options[hudIdx].sizing.ScapeDollH, "ScapeDoll"} },
            [0x0A] = {
                [0x00] = {options[hudIdx].sizing.MonogrinderW, options[hudIdx].sizing.MonogrinderH, "Monogrinder"},
                [0x01] = {options[hudIdx].sizing.DigrinderW, options[hudIdx].sizing.DigrinderH, "Digrinder"},
                [0x02] = {options[hudIdx].sizing.TrigrinderW, options[hudIdx].sizing.TrigrinderH, "Trigrinder"},
            },
            [0x0B] = {
                [0x00] = {options[hudIdx].sizing.PowerMatW, options[hudIdx].sizing.PowerMatH, "PowerMat"},
                [0x01] = {options[hudIdx].sizing.MindMatW, options[hudIdx].sizing.MindMatH, "MindMat"},
                [0x02] = {options[hudIdx].sizing.EvadeMatW, options[hudIdx].sizing.EvadeMatH, "EvadeMat"},
                [0x03] = {options[hudIdx].sizing.HPMatW, options[hudIdx].sizing.HPMatH, "HPMat"},
                [0x04] = {options[hudIdx].sizing.TPMatH, options[hudIdx].sizing.TPMatH, "TPMat"},
                [0x05] = {options[hudIdx].sizing.DefenseMatW, options[hudIdx].sizing.DefenseMatH, "DefenseMat"},
                [0x06] = {options[hudIdx].sizing.LuckMatW, options[hudIdx].sizing.LuckMatH, "LuckMat"},
            },
        }
    end
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

local function AppendItemFacingFromCurPlayer(item,playerDir)
    if not item then return end

    item.posx = pso.read_f32(item.address + 0x38)
    --item.posy = pso.read_f32(item.address + 0x3C)
    item.posz = pso.read_f32(item.address + 0x40)

    local itemDir = {
        x = item.posx - playerSelfCoords.x,
        z = item.posz - playerSelfCoords.z,
    }

    local itemNormDir = NormalizeVec2(itemDir)    
    local itemFacing = {
        x = (itemNormDir.x - playerDir.x) / 2,
        z = (itemNormDir.z - playerDir.z) / 2,
    }
    --local itemLocalFacing = math.asin( itemNormDir.x * playerDir.x + itemNormDir.z * playerDir.z ) * 180/math.pi
    local itemLocalFacing
    
    if options.itemDirectionReversedCount > 0 then
        itemLocalFacing = math.atan2(  playerDir.z, playerDir.x ) - math.atan2(  itemNormDir.z, itemNormDir.x )
        if itemLocalFacing > math.pi then itemLocalFacing = itemLocalFacing - math.pi*2 end
        if itemLocalFacing < -math.pi then itemLocalFacing = itemLocalFacing + math.pi*2 end
        item.curPlayerFacingItemDegreesRev = itemLocalFacing * 180/math.pi
    end

    itemLocalFacing = math.atan2(  itemNormDir.z, itemNormDir.x ) - math.atan2(  playerDir.z, playerDir.x )
    if itemLocalFacing > math.pi then itemLocalFacing = itemLocalFacing - math.pi*2 end
    if itemLocalFacing < -math.pi then itemLocalFacing = itemLocalFacing + math.pi*2 end

    item.curPlayerFacingItemDegrees = itemLocalFacing * 180/math.pi
    item.curPlayerDistance = math.sqrt(itemDir.x^2 + itemDir.z^2)
end
local function invertedViewGraphValCheck(curVal, newVal)
    if curVal > newVal then
        return true
    else
        return false
    end
end
local function nonInvertedViewGraphValCheck(curVal, newVal)
    if curVal < newVal then
        return true
    else
        return false
    end
end
local function ItemAppendGraphData(size,val,item,hudIdx)
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

    if val <1 or size == 0 or options[hudIdx].viewingConeDegs == 0 then return end

    -- ignore if item is too far away
    if options[hudIdx].ignoreItemMaxDist > 0 then
        if item.curPlayerDistance > options[hudIdx].ignoreItemMaxDist then
            return
        end
    end

    local GraphValCheck
    if options[hudIdx].invertViewData then
        val = 100-val
        GraphValCheck = invertedViewGraphValCheck
    else
        GraphValCheck = nonInvertedViewGraphValCheck
    end

    local itemFacingDegs = 0
    if options[hudIdx].reverseItemDirection then
        itemFacingDegs = item.curPlayerFacingItemDegreesRev
    else
        itemFacingDegs = item.curPlayerFacingItemDegrees
    end
    --print(hudIdx,options[hudIdx].reverseItemDirection,options.itemDirectionReversedCount,itemFacingDegs,tostring(options[hudIdx].viewingConeDegs))
    if options[hudIdx].clampItemView then
        itemFacingDegs = clampVal( itemFacingDegs , -options[hudIdx].viewingConeDegs, options[hudIdx].viewingConeDegs)
    else
        if itemFacingDegs > options[hudIdx].viewingConeDegs or itemFacingDegs < -options[hudIdx].viewingConeDegs then
            return
        end
    end

    local itemHistogramPos = clampVal(
        math.floor(
            Lerp(Norm(itemFacingDegs, -options[hudIdx].viewingConeDegs, options[hudIdx].viewingConeDegs), 1, item_graph_size[hudIdx])
        ),
        1, item_graph_size[hudIdx]
    )

    local idx
    local dataCutoff = Lerp(Norm(size,0.001,5), 1, item_graph_size[hudIdx]*0.05)
    if GraphValCheck(item_graph_data[hudIdx][itemHistogramPos], val) then
        item_graph_data[hudIdx][itemHistogramPos] = val
    end
    for i=2, item_graph_size[hudIdx] do
        if i < dataCutoff then
            if i % 2 > 0 then
                idx = clampVal(itemHistogramPos - math.floor((i)/2), 1, item_graph_size[hudIdx])
            else
                idx = clampVal(itemHistogramPos - math.floor((i)/2), 1, item_graph_size[hudIdx])
            end
            if GraphValCheck(item_graph_data[hudIdx][idx], val) then
                item_graph_data[hudIdx][idx] = val
            end
        else
            break
        end
    end
end


local function ProcessWeapon(item, floor, hudIdx)

    local item_cfg = lib_items_list.t[item.hex]

    if item.weapon.isSRank == false then
        if item_cfg ~= nil and item_cfg[1] ~= 0 then
            ItemAppendGraphData( options[hudIdx].sizing.WeaponsW, options[hudIdx].sizing.WeaponsH, item, hudIdx )
        elseif floor then
            -- Hide weapon drops with less then xxHit (40 default) untekked
            if item.weapon.stats[6] >= options[hudIdx].sizing.HitMin then
                ItemAppendGraphData( options[hudIdx].sizing.HighHitWeaponsW, options[hudIdx].sizing.HighHitWeaponsH, item, hudIdx)
            -- Show Claire's Deal 5 items
            elseif options[hudIdx].sizing.ClairesDealEnable and clairesDealLoaded and lib_claires_deal.IsClairesDealItem(item) then
                ItemAppendGraphData( options[hudIdx].sizing.ClairesDealW, options[hudIdx].sizing.ClairesDealH, item, hudIdx )
            elseif item.weapon.stats[6] < options[hudIdx].sizing.HitMin then
                ItemAppendGraphData( options[hudIdx].sizing.LowHitWeaponsW, options[hudIdx].sizing.LowHitWeaponsH, item, hudIdx )
            end            
        end
    else
        ItemAppendGraphData( options[hudIdx].sizing.SRankWeaponsW, options[hudIdx].sizing.SRankWeaponsH, item, hudIdx )
    end
end
local function ProcessFrame(item, floor, hudIdx)

    local item_cfg = lib_items_list.t[item.hex]

    if item_cfg ~= nil and item_cfg[1] ~= 0 then
        ItemAppendGraphData( options[hudIdx].sizing.ArmorsW, options[hudIdx].sizing.ArmorsH, item, hudIdx )
    elseif floor then
        -- Show 4 socket armors
        if item.armor.slots == 4 then
            ItemAppendGraphData( options[hudIdx].sizing.MaxSocketArmorW, options[hudIdx].sizing.MaxSocketArmorH, item, hudIdx )
        -- Show Claire's Deal 5 items
        elseif options[hudIdx].sizing.ClairesDealEnable and clairesDealLoaded and lib_claires_deal.IsClairesDealItem(item) then
            ItemAppendGraphData( options[hudIdx].sizing.ClairesDealW, options[hudIdx].sizing.ClairesDealH, item, hudIdx )
        else
            ItemAppendGraphData( options[hudIdx].sizing.UselessArmorsW, options[hudIdx].sizing.UselessArmorsH, item, hudIdx )
        end
    end
end
local function ProcessBarrier(item, floor, hudIdx)

    local item_cfg = lib_items_list.t[item.hex]

    if item_cfg ~= nil and item_cfg[1] ~= 0 then
        ItemAppendGraphData( options[hudIdx].sizing.BarriersW, options[hudIdx].sizing.BarriersH, item, hudIdx )
    elseif floor then
        -- Show Claire's Deal 5 items
        if options[hudIdx].sizing.ClairesDealEnable and clairesDealLoaded and lib_claires_deal.IsClairesDealItem(item) then
            ItemAppendGraphData( options[hudIdx].sizing.ClairesDealW, options[hudIdx].sizing.ClairesDealH, item, hudIdx )
        else
            ItemAppendGraphData( options[hudIdx].sizing.UselessBarriersW, options[hudIdx].sizing.UselessBarriersH, item, hudIdx )
        end
    end
end
local function ProcessUnit(item, floor, hudIdx)

    local item_cfg = lib_items_list.t[item.hex]

    if item_cfg ~= nil and item_cfg[1] ~= 0 then
        ItemAppendGraphData( options[hudIdx].sizing.UnitsW, options[hudIdx].sizing.UnitsH, item, hudIdx )
    elseif floor then
        -- Show Claire's Deal 5 items
        if options[hudIdx].sizing.ClairesDealEnable and clairesDealLoaded and lib_claires_deal.IsClairesDealItem(item) then
            ItemAppendGraphData( options[hudIdx].sizing.ClairesDealW, options[hudIdx].sizing.ClairesDealH, item, hudIdx )
        else
            ItemAppendGraphData( options[hudIdx].sizing.UselessUnitsW, options[hudIdx].sizing.UselessUnitsH, item, hudIdx )
        end
    end
end
local function ProcessMag(item, fromMagWindow, hudIdx)
    ItemAppendGraphData( options[hudIdx].sizing.MagsW, options[hudIdx].sizing.MagsH, item, hudIdx )
end

local function ProcessTool(item, floor, hudIdx)
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
                ItemAppendGraphData( options[hudIdx].sizing.TechReverserW, options[hudIdx].sizing.TechReverserH, item, hudIdx )
            elseif item.data[5] == 0x0E then
                ItemAppendGraphData( options[hudIdx].sizing.TechRyukerW, options[hudIdx].sizing.TechRyukerH, item, hudIdx )
            -- Is Good Anti?
            elseif item.data[5] == 0x10 then
                if item.tool.level == 5 then
                    ItemAppendGraphData( options[hudIdx].sizing.TechAnti5W, options[hudIdx].sizing.TechAnti5H, item, hudIdx )
                elseif item.tool.level >= 7 then
                    ItemAppendGraphData( options[hudIdx].sizing.TechAnti7W, options[hudIdx].sizing.TechAnti7H, item, hudIdx )
                else
                    ItemAppendGraphData( options[hudIdx].sizing.UselessTechsW, options[hudIdx].sizing.UselessTechsH, item, hudIdx )
                end
            -- Is Good Megid/Grants
            elseif item.data[5] == 0x12 then
                if item.tool.level >= options[hudIdx].sizing.TechMegidMin then
                    ItemAppendGraphData( options[hudIdx].sizing.TechMegidW, options[hudIdx].sizing.TechMegidH, item, hudIdx )
                else
                    ItemAppendGraphData( options[hudIdx].sizing.UselessTechsW, options[hudIdx].sizing.UselessTechsH, item, hudIdx )
                end
            elseif item.data[5] == 0x09 then
                if item.tool.level >= options[hudIdx].sizing.TechGrantsMin then
                    ItemAppendGraphData( options[hudIdx].sizing.TechGrantsW, options[hudIdx].sizing.TechGrantsH, item, hudIdx )
                else
                    ItemAppendGraphData( options[hudIdx].sizing.UselessTechsW, options[hudIdx].sizing.UselessTechsH, item, hudIdx )
                end
            -- Is good support spell
            elseif item.data[5] == 0x0A or item.data[5] == 0x0B or item.data[5] == 0x0C or item.data[5] == 0x0D or item.data[5] == 0x0F then
                if item.tool.level >= options[hudIdx].sizing.TechSupportMin then
                    ItemAppendGraphData( options[hudIdx].sizing.TechSupport30W, options[hudIdx].sizing.TechSupport30H, item, hudIdx )
                elseif item.tool.level == 15 then
                    ItemAppendGraphData( options[hudIdx].sizing.TechSupport15W, options[hudIdx].sizing.TechSupport15H, item, hudIdx )
                elseif item.tool.level == 20 then
                    ItemAppendGraphData( options[hudIdx].sizing.TechSupport20W, options[hudIdx].sizing.TechSupport20H, item, hudIdx )
                else
                    ItemAppendGraphData( options[hudIdx].sizing.UselessTechsW, options[hudIdx].sizing.UselessTechsH, item, hudIdx )
                end
            -- Is a max tier tech?
            elseif item.tool.level >= options[hudIdx].sizing.TechAttackMin then
                ItemAppendGraphData( options[hudIdx].sizing.TechAttack30W, options[hudIdx].sizing.TechAttack30H, item, hudIdx )
            elseif item.tool.level == 15 then
                ItemAppendGraphData( options[hudIdx].sizing.TechAttack15W, options[hudIdx].sizing.TechAttack15H, item, hudIdx )
            elseif item.tool.level == 20 then
                ItemAppendGraphData( options[hudIdx].sizing.TechAttack20W, options[hudIdx].sizing.TechAttack20H, item, hudIdx )
            else
                ItemAppendGraphData( options[hudIdx].sizing.UselessTechsW, options[hudIdx].sizing.UselessTechsH, item, hudIdx )
            end

        -- Hide Monomates, Dimates, Monofluids, Difluids, Antidotes, Antiparalysis, Telepipe, and Trap Visions
        elseif  toolLookupTable[hudIdx][item.data[2]] ~= nil and 
                toolLookupTable[hudIdx][item.data[2]][item.data[3]] ~= nil and 
                toolLookupTable[hudIdx][item.data[2]][item.data[3]][2] then
            -- Show Claire's Deal 5 items
            if options[hudIdx].sizing.ClairesDealEnable and clairesDealLoaded and lib_claires_deal.IsClairesDealItem(item) then
                ItemAppendGraphData( options[hudIdx].sizing.ClairesDealW, options[hudIdx].sizing.ClairesDealH, item, hudIdx )
            else
                local toolLookup = toolLookupTable[hudIdx][item.data[2]][item.data[3]]
                if toolLookup[1] ~= nil and toolLookup[2] ~= nil then
                    ItemAppendGraphData( toolLookup[1], toolLookup[2], item, hudIdx )
                end
            end
        else
            ItemAppendGraphData( options[hudIdx].sizing.ConsumablesW, options[hudIdx].sizing.ConsumablesH, item, hudIdx )
        end
    end
end
local function ProcessMeseta(item, hudIdx)
    if options.ignoreMeseta == false then
        if item.meseta >= options[hudIdx].sizing.MesetaMin then
            local norm = Norm(item.meseta, options[hudIdx].sizing.MesetaMin, options[hudIdx].sizing.MesetaMax)
            ItemAppendGraphData( options[hudIdx].sizing.MesetaW, clampVal( Lerp( norm, options[hudIdx].sizing.MesetaMinH, options[hudIdx].sizing.MesetaMaxH), 0, 100 ), item, hudIdx )
        end
    end
end
local function ProcessItem(item, floor, save, fromMagWindow, hudIdx)
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
        ProcessWeapon(item, floor, hudIdx)
    elseif item.data[1] == 1 then
        if item.data[2] == 1 then
            ProcessFrame(item, floor, hudIdx)
        elseif item.data[2] == 2 then
            ProcessBarrier(item, floor, hudIdx)
        elseif item.data[2] == 3 then
            ProcessUnit(item, floor, hudIdx)
        end
    elseif item.data[1] == 2 then
        ProcessMag(item, fromMagWindow, hudIdx)
    elseif item.data[1] == 3 then
        ProcessTool(item, floor, hudIdx)
    elseif item.data[1] == 4 then
        ProcessMeseta(item, hudIdx)
    end

end

local update_delay = (options.updateThrottle * 1000)
local current_time = 0
local last_floor_time = 0
local cache_floor = nil
local itemCount = 0
local lastNumHUDs = options.numHUDs
local firstLoad = true

local function PresentHud(hudIdx)
    
    item_graph_data[hudIdx] = {}
    item_graph_size[hudIdx] = clampVal( math.floor( options[hudIdx].W / 2 * options[hudIdx].viewHudPrecision ), 1, 2000 ) -- histogram likes 2 pixels per bar, so if 1000 wide, then 500 table entries will visibly not show any gaps.
    item_graph_size[hudIdx] = item_graph_size[hudIdx] - item_graph_size[hudIdx] % 2

    if options[hudIdx].invertViewData then
        for i=1, item_graph_size[hudIdx] do
            table.insert(item_graph_data[hudIdx], 100)
        end
    else
        for i=1, item_graph_size[hudIdx] do
            table.insert(item_graph_data[hudIdx], 0)
        end
    end

    if options[hudIdx].invertTickMarkers then
        item_graph_data[hudIdx][math.floor(Lerp(0.3,1,item_graph_size[hudIdx]))] = 95
        item_graph_data[hudIdx][math.floor(Lerp(0.5,1,item_graph_size[hudIdx]))] = 90
        item_graph_data[hudIdx][math.floor(Lerp(0.7,1,item_graph_size[hudIdx]))] = 95
    else
        item_graph_data[hudIdx][math.floor(Lerp(0.3,1,item_graph_size[hudIdx]))] = 5
        item_graph_data[hudIdx][math.floor(Lerp(0.5,1,item_graph_size[hudIdx]))] = 10
        item_graph_data[hudIdx][math.floor(Lerp(0.7,1,item_graph_size[hudIdx]))] = 5
    end

    for i=1,itemCount,1 do
        local item = cache_floor[i]
        ProcessItem(cache_floor[i], true, false, false, hudIdx)
    end

    if options[hudIdx].NoTitleBar == "" then
        imgui.PlotHistogram("", item_graph_data[hudIdx], item_graph_size[hudIdx], 0, "", 0,100, options[hudIdx].W-16, options[hudIdx].H-34);
    else
        imgui.PlotHistogram("", item_graph_data[hudIdx], item_graph_size[hudIdx], 0, "", 0,100, options[hudIdx].W-16, options[hudIdx].H-14);
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

    local configChanged = ConfigurationWindow.changed
    if ConfigurationWindow.changed then
        ConfigurationWindow.changed = false
        if options.numHUDs > lastNumHUDs then
            LoadOptions()
            print(options.numHUDs, lastNumHUDs)
            lastNumHUDs = options.numHUDs
        end
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

    if last_floor_time + update_delay < current_time or cache_floor == nil then
        cache_floor = lib_items.GetItemList(lib_items.NoOwner, options.invertItemList)
        last_floor_time = current_time
    end
    itemCount = table.getn(cache_floor)

--needed?
    local myFloor = lib_characters.GetCurrentFloorSelf()
--needed?

    playerSelfAddr    = lib_characters.GetSelf()
    playerSelfCoords  = GetPlayerCoordinates(playerSelfAddr)
    playerSelfDirs    = GetPlayerDirection(playerSelfAddr)
    playerSelfNormDir = NormalizeVec2(playerSelfDirs)

    for i=1,itemCount,1 do
        local item = cache_floor[i]
        AppendItemFacingFromCurPlayer(item,playerSelfNormDir)
    end

    for i=options.numHUDs, 1, -1 do
        local hudIdx = "hud" .. i
        if (options[hudIdx].EnableWindow == true)
            and (options[hudIdx].HideWhenMenu == false or lib_menu.IsMenuOpen() == false)
            and (options[hudIdx].HideWhenSymbolChat == false or lib_menu.IsSymbolChatOpen() == false)
            and (options[hudIdx].HideWhenMenuUnavailable == false or lib_menu.IsMenuUnavailable() == false)
        then
            local windowName = "Drop Radar " .. i

            if options[hudIdx].customHudColorEnable == true then
                local PlotHistogramColor = shiftHexColor(options[hudIdx].customHudColorMarker)
                local FrameBgColor = shiftHexColor(options[hudIdx].customHudColorBackground)
                local WindowBgColor = shiftHexColor(options[hudIdx].customHudColorWindow)
                imgui.PushStyleColor("PlotHistogram", PlotHistogramColor[2]/255, PlotHistogramColor[3]/255, PlotHistogramColor[4]/255, PlotHistogramColor[1]/255)
                imgui.PushStyleColor("FrameBg", FrameBgColor[2]/255, FrameBgColor[3]/255, FrameBgColor[4]/255, FrameBgColor[1]/255)
                imgui.PushStyleColor("WindowBg", WindowBgColor[2]/255, WindowBgColor[3]/255, WindowBgColor[4]/255, WindowBgColor[1]/255)
            end

            if options[hudIdx].TransparentWindow == true then
                imgui.PushStyleColor("WindowBg", 0.0, 0.0, 0.0, 0.0)
            end


            if options[hudIdx].AlwaysAutoResize == "AlwaysAutoResize" then
                imgui.SetNextWindowSizeConstraints(0, 0, options[hudIdx].W, options[hudIdx].H)
            end

            if imgui.Begin(windowName,
                nil,
                {
                    options[hudIdx].NoTitleBar,
                    options[hudIdx].NoResize,
                    options[hudIdx].NoMove,
                    options[hudIdx].AlwaysAutoResize,
                }
            ) then
                PresentHud(hudIdx)

                lib_helpers.WindowPositionAndSize(windowName,
                    options[hudIdx].X,
                    options[hudIdx].Y,
                    options[hudIdx].W,
                    options[hudIdx].H,
                    options[hudIdx].Anchor,
                    options[hudIdx].AlwaysAutoResize,
                    options[hudIdx].changed)
            end
            if (((options.tileAllHuds and hudIdx == "hud1") or options[hudIdx].AlwaysOnTop) and configChanged) or firstLoad then
                imgui.SetWindowFocus()
            end
            imgui.End()

            if options[hudIdx].customHudColorEnable == true then
                imgui.PopStyleColor()
                imgui.PopStyleColor()
                imgui.PopStyleColor()
            end

            if options[hudIdx].TransparentWindow == true then
                imgui.PopStyleColor()
            end

            options[hudIdx].changed = false
        end
    end
    firstLoad = false
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
        version = "0.2.2",
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


local viewingConeIndicatorFData = {}
local viewingConeIndicatorBData = {}
local coneIndicatorDataInitd = false


local function clampVal(clamp, min, max)
    return clamp < min and min or clamp > max and max or clamp
end
local function Norm(Val,Min,Max)
    return (Val - Min)/(Max - Min)
end
local function Lerp(Norm,Min,Max)
    return (Max - Min) * Norm + Min
end

local function ConfigurationWindow(configuration)
    local this =
    {
        title = "Drop Radar - Configuration",
        open = false,
        changed = false,
    }

    local _configuration = configuration

    local function newViewingConeIndicatorData()
        coneIndicatorDataInitd = true
        viewingConeIndicatorFData = {}
        viewingConeIndicatorBData = {}
        for i=1, 180 do
            if _configuration.viewingConeDegs >= math.abs(i-90) then
                table.insert(viewingConeIndicatorFData, math.sin((i+3)/60)*100)
            else
                table.insert(viewingConeIndicatorFData, 0)
            end
        end

        local adjustViewDegs = (180 - _configuration.viewingConeDegs-90)+90
        for i=1, 180 do
            if adjustViewDegs <= math.abs(i-90) then
                table.insert(viewingConeIndicatorBData, math.sin((i+192)/60)*100+100)
            else
                table.insert(viewingConeIndicatorBData, 0)
            end
        end
    end

    local function PresentColorEditor(label, default, custom)
        custom = custom or 0xFFFFFFFF
    
        local changed = false
        local i_default =
        {
            bit.band(bit.rshift(default, 24), 0xFF),
            bit.band(bit.rshift(default, 16), 0xFF),
            bit.band(bit.rshift(default, 8), 0xFF),
            bit.band(default, 0xFF)
        }
        local i_custom =
        {
            bit.band(bit.rshift(custom, 24), 0xFF),
            bit.band(bit.rshift(custom, 16), 0xFF),
            bit.band(bit.rshift(custom, 8), 0xFF),
            bit.band(custom, 0xFF)
        }
    
        local ids = { "##X", "##Y", "##Z", "##W" }
        local fmt = { "A:%3.0f", "R:%3.0f", "G:%3.0f", "B:%3.0f" }
    
        imgui.BeginGroup()
        imgui.PushID(label)
    
        imgui.PushItemWidth(50)
        for n = 1, 4, 1 do
            local changedDragInt = false
            if n ~= 1 then
                imgui.SameLine(0, 5)
            end
    
            changedDragInt, i_custom[n] = imgui.DragInt(ids[n], i_custom[n], 1.0, 0, 255, fmt[n])
            if changedDragInt then
                this.changed = true
            end
        end
        imgui.PopItemWidth()
    
        imgui.SameLine(0, 5)
        imgui.ColorButton(i_custom[2] / 255, i_custom[3] / 255, i_custom[4] / 255, 1.0)
        if imgui.IsItemHovered() then
            imgui.SetTooltip(
                string.format(
                    "#%02X%02X%02X%02X",
                    i_custom[4],
                    i_custom[1],
                    i_custom[2],
                    i_custom[3]
                )
            )
        end
    
        imgui.SameLine(0, 5)
        imgui.Text(label)
    
        default =
        bit.lshift(i_default[1], 24) +
        bit.lshift(i_default[2], 16) +
        bit.lshift(i_default[3], 8) +
        bit.lshift(i_default[4], 0)
    
        custom =
        bit.lshift(i_custom[1], 24) +
        bit.lshift(i_custom[2], 16) +
        bit.lshift(i_custom[3], 8) +
        bit.lshift(i_custom[4], 0)
    
        if custom ~= default then
            imgui.SameLine(0, 5)
            if imgui.Button("Revert") then
                custom = default
                this.changed = true
            end
        end
    
        imgui.PopID()
        imgui.EndGroup()
    
        return custom
    end

    if not coneIndicatorDataInitd then
        newViewingConeIndicatorData()
    end

    local _showWindowSettings = function()
        local success
        local anchorList =
        {
            "Top Left (Disabled)", "Left", "Bottom Left",
            "Top", "Center", "Bottom",
            "Top Right", "Right", "Bottom Right",
        }
        local serverList =
        {
            "Vanilla",
            "Ultima",
            "Ephinea",
            "Schthack",
        }

        local function dropSizing(Name, Setting, Setting2, Width, Width2, Range, Range2, NoGraph, NoFloat)
            if Width == nil or Width2 == nil then return Setting, Setting2 end
            if Range == nil or type(Range) ~= "table" or Range[1] == nil or Range[2] == nil then return Setting, Setting2 end
            if Range2 == nil or type(Range2) ~= "table" or Range2[1] == nil or Range2[2] == nil then return Setting, Setting2 end
            if not NoGraph then
                local plotData = {}
                local plotSize = 42
                local plotCutoff = Lerp(Norm(Setting,Range[1],Range[2]), 1, plotSize)/2

                for i=1, plotSize do
                    if plotCutoff >= math.abs(i - plotSize/2) then
                        table.insert(plotData, Setting2)
                    else
                        table.insert(plotData, 0)
                    end
                end
                imgui.PlotHistogram("", plotData, plotSize, 0, "", 0, 100, 42, 20)
                imgui.SameLine(0, 4)
            end

            if not NoFloat then
                imgui.PushItemWidth(Width)
                success, Setting = imgui.SliderFloat("##" .. Name, Setting, Range[1], Range[2])
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 4)
            end

            imgui.PushItemWidth(Width2)
            success, Setting2 = imgui.SliderInt(Name, Setting2, Range2[1], Range2[2])
            imgui.PopItemWidth()

            if success then
                this.changed = true
            end
            return Setting, Setting2
        end

        if imgui.TreeNodeEx("General", "DefaultOpen") then
            if imgui.Checkbox("Enable", _configuration.enable) then
                _configuration.enable = not _configuration.enable
                this.changed = true
            end

            if imgui.Checkbox("Ignore meseta", _configuration.ignoreMeseta) then
                _configuration.ignoreMeseta = not _configuration.ignoreMeseta
                this.changed = true
            end

            if imgui.Checkbox("Reverse Item Direction", _configuration.reverseItemDirection) then
                _configuration.reverseItemDirection = not _configuration.reverseItemDirection
                this.changed = true
            end

            if imgui.Checkbox("Clamp Item Into View", _configuration.clampItemView) then
                _configuration.clampItemView = not _configuration.clampItemView
                this.changed = true
            end

            if imgui.Checkbox("Invert View", _configuration.invertViewData) then
                _configuration.invertViewData = not _configuration.invertViewData
                this.changed = true
            end

            if imgui.Checkbox("Invert Tick Markers", _configuration.invertTickMarkers) then
                _configuration.invertTickMarkers = not _configuration.invertTickMarkers
                this.changed = true
            end

            if imgui.Checkbox("Custom Hud Color", _configuration.customHudColorEnable) then
                _configuration.customHudColorEnable = not _configuration.customHudColorEnable
                this.changed = true
            end

            if _configuration.customHudColorEnable then
                _configuration.customHudColorMarker = PresentColorEditor("Marker Color", 0xFFFF9900, _configuration.customHudColorMarker)
                _configuration.customHudColorBackground = PresentColorEditor("Background Color", 0x4CCCCCCC, _configuration.customHudColorBackground)
                _configuration.customHudColorWindow = PresentColorEditor("Window Color", 0x46000000, _configuration.customHudColorWindow)
            end

            imgui.PlotHistogram("Front", viewingConeIndicatorFData, 180, 0, "", 0, 100, 140, 20)
            imgui.PlotHistogram("Back", viewingConeIndicatorBData, 180, 0, "", 0, 100, 140, 20)
            imgui.PushItemWidth(140)
            success, _configuration.viewingConeDegs = imgui.SliderInt("Viewing Cone (Degrees)", _configuration.viewingConeDegs, 0, 180)
            imgui.PopItemWidth()
            if success then
                this.changed = true
                newViewingConeIndicatorData()
            end

            imgui.PushItemWidth(140)
            success, _configuration.viewHudPrecision = imgui.SliderFloat("View Precision (> may lag)", _configuration.viewHudPrecision, 0.1, 2)
            imgui.PopItemWidth()
            if success then
                this.changed = true
                _configuration.viewHudPrecision = clampVal(_configuration.viewHudPrecision, 0, 999999)
            end

            imgui.PushItemWidth(100)
            success, _configuration.ignoreItemMaxDist = imgui.InputInt("Ignore Item Distance (far)", _configuration.ignoreItemMaxDist)
            imgui.PopItemWidth()
            if success then
                this.changed = true
                _configuration.ignoreItemMaxDist = clampVal(_configuration.ignoreItemMaxDist, 0, 999999)
            end

            imgui.PushItemWidth(100)
            success, _configuration.updateThrottle = imgui.InputInt("Delay Update (seconds)", _configuration.updateThrottle)
            imgui.PopItemWidth()
            if success then
                this.changed = true
            end

            imgui.PushItemWidth(200)
            success, _configuration.server = imgui.Combo("Server", _configuration.server, serverList, table.getn(serverList))
            imgui.PopItemWidth()
            if success then
                this.changed = true
            end

            imgui.TreePop()
        end

        if imgui.TreeNodeEx("Hud") then
            if imgui.Checkbox("Enable", _configuration.hud.EnableWindow) then
                _configuration.hud.EnableWindow = not _configuration.hud.EnableWindow
                _configuration.hud.changed = true
                this.changed = true
            end

        if imgui.Checkbox("Hide when menus are open", _configuration.hud.HideWhenMenu) then
                _configuration.hud.HideWhenMenu = not _configuration.hud.HideWhenMenu
                this.changed = true
            end
            if imgui.Checkbox("Hide when symbol chat/word select is open", _configuration.hud.HideWhenSymbolChat) then
                _configuration.hud.HideWhenSymbolChat = not _configuration.hud.HideWhenSymbolChat
                this.changed = true
            end
            if imgui.Checkbox("Hide when the menu is unavailable", _configuration.hud.HideWhenMenuUnavailable) then
                _configuration.hud.HideWhenMenuUnavailable = not _configuration.hud.HideWhenMenuUnavailable
                this.changed = true
            end

            if imgui.Checkbox("No title bar", _configuration.hud.NoTitleBar == "NoTitleBar") then
                if _configuration.hud.NoTitleBar == "NoTitleBar" then
                    _configuration.hud.NoTitleBar = ""
                else
                    _configuration.hud.NoTitleBar = "NoTitleBar"
                end
                _configuration.hud.changed = true
                this.changed = true
            end
            if imgui.Checkbox("No resize", _configuration.hud.NoResize == "NoResize") then
                if _configuration.hud.NoResize == "NoResize" then
                    _configuration.hud.NoResize = ""
                else
                    _configuration.hud.NoResize = "NoResize"
                end
                _configuration.hud.changed = true
                this.changed = true
            end
            if imgui.Checkbox("No move", _configuration.hud.NoMove == "NoMove") then
                if _configuration.hud.NoMove == "NoMove" then
                    _configuration.hud.NoMove = ""
                else
                    _configuration.hud.NoMove = "NoMove"
                end
                _configuration.hud.changed = true
                this.changed = true
            end
            if imgui.Checkbox("Always Auto Resize", _configuration.hud.AlwaysAutoResize == "AlwaysAutoResize") then
                if _configuration.hud.AlwaysAutoResize == "AlwaysAutoResize" then
                    _configuration.hud.AlwaysAutoResize = ""
                else
                    _configuration.hud.AlwaysAutoResize = "AlwaysAutoResize"
                end
                _configuration.hud.changed = true
                this.changed = true
            end

            if imgui.Checkbox("Transparent window", _configuration.hud.TransparentWindow) then
                _configuration.hud.TransparentWindow = not _configuration.hud.TransparentWindow
                _configuration.hud.changed = true
                this.changed = true
            end

            if imgui.TreeNodeEx("Custom Sizing") then
                local SWidth = 110
                local SWidthP = SWidth + 16
                local SizingRange = {0,100}
                local MarkerSizeRange = {0.001,5}
                local MesetaRange = {1,999999}
                local TechRange = {1,30}
                local TechAntiRange = {1,7}

                if imgui.TreeNodeEx("Non-Rares") then
                
                    imgui.PushItemWidth(SWidthP)
                    success, _configuration.hud.sizing.HitMin = imgui.SliderInt("Minimum Hit", _configuration.hud.sizing.HitMin,-10, 100)
                    imgui.PopItemWidth()
                    if success then
                        this.changed = true
                    end

                    _configuration.hud.sizing.LowHitWeaponsW, _configuration.hud.sizing.LowHitWeaponsH = 
                    dropSizing("Low Hit Weapons", _configuration.hud.sizing.LowHitWeaponsW, _configuration.hud.sizing.LowHitWeaponsH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.HighHitWeaponsW, _configuration.hud.sizing.HighHitWeaponsH = 
                    dropSizing("High Hit Weapons", _configuration.hud.sizing.HighHitWeaponsW, _configuration.hud.sizing.HighHitWeaponsH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.UselessArmorsW, _configuration.hud.sizing.UselessArmorsH = 
                    dropSizing("<4s Armor", _configuration.hud.sizing.UselessArmorsW, _configuration.hud.sizing.UselessArmorsH, SWidth, SWidth, MarkerSizeRange, SizingRange)
                    
                    _configuration.hud.sizing.MaxSocketArmorW, _configuration.hud.sizing.MaxSocketArmorH = 
                    dropSizing("=4s Armor", _configuration.hud.sizing.MaxSocketArmorW, _configuration.hud.sizing.MaxSocketArmorH, SWidth, SWidth, MarkerSizeRange, SizingRange)
                    
                    _configuration.hud.sizing.UselessBarriersW, _configuration.hud.sizing.UselessBarriersH = 
                    dropSizing("Useless Barriers", _configuration.hud.sizing.UselessBarriersW, _configuration.hud.sizing.UselessBarriersH, SWidth, SWidth, MarkerSizeRange, SizingRange)
                    
                    _configuration.hud.sizing.UselessUnitsW, _configuration.hud.sizing.UselessUnitsH = 
                    dropSizing("Useless Units", _configuration.hud.sizing.UselessUnitsW, _configuration.hud.sizing.UselessUnitsH, SWidth, SWidth, MarkerSizeRange, SizingRange)
                    
                    _configuration.hud.sizing.UselessTechsW, _configuration.hud.sizing.UselessTechsH = 
                    dropSizing("Useless Techs", _configuration.hud.sizing.UselessTechsW, _configuration.hud.sizing.UselessTechsH, SWidth, SWidth, MarkerSizeRange, SizingRange)
                    
                    _configuration.hud.sizing.MesetaW, _configuration.hud.sizing.MesetaMinH = 
                    dropSizing("Meseta Height Min", _configuration.hud.sizing.MesetaW, _configuration.hud.sizing.MesetaMinH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.MesetaW, _configuration.hud.sizing.MesetaMaxH = 
                    dropSizing("Meseta Height Max", _configuration.hud.sizing.MesetaW, _configuration.hud.sizing.MesetaMaxH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    imgui.PushItemWidth(SWidthP)
                    success, _configuration.hud.sizing.MesetaMin = imgui.DragInt("Meseta Min (will filter)", _configuration.hud.sizing.MesetaMin, 10, MesetaRange[1], MesetaRange[2])
                    imgui.PopItemWidth()
                    if success then
                        this.changed = true
                    end
                    if _configuration.hud.sizing.MesetaMin > _configuration.hud.sizing.MesetaMax then
                        _configuration.hud.sizing.MesetaMin = _configuration.hud.sizing.MesetaMax
                    end

                    imgui.PushItemWidth(SWidthP)
                    success, _configuration.hud.sizing.MesetaMax = imgui.DragInt("Meseta Max (not a filter)", _configuration.hud.sizing.MesetaMax, 10, MesetaRange[1], MesetaRange[2])
                    imgui.PopItemWidth()
                    if success then
                        this.changed = true
                    end
                    if _configuration.hud.sizing.MesetaMax < _configuration.hud.sizing.MesetaMin then
                        _configuration.hud.sizing.MesetaMax = _configuration.hud.sizing.MesetaMin
                    end

                    imgui.TreePop()
                end

                
                if imgui.TreeNodeEx("Rares") then

                    _configuration.hud.sizing.WeaponsW, _configuration.hud.sizing.WeaponsH = 
                    dropSizing("Weapons", _configuration.hud.sizing.WeaponsW, _configuration.hud.sizing.WeaponsH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.SRankWeaponsW, _configuration.hud.sizing.SRankWeaponsH = 
                    dropSizing("SRank Weapons", _configuration.hud.sizing.SRankWeaponsW, _configuration.hud.sizing.SRankWeaponsH, SWidth, SWidth, MarkerSizeRange, SizingRange)
                    
                    _configuration.hud.sizing.ArmorsW, _configuration.hud.sizing.ArmorsH = 
                    dropSizing("Armor", _configuration.hud.sizing.ArmorsW, _configuration.hud.sizing.ArmorsH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.BarriersW, _configuration.hud.sizing.BarriersH = 
                    dropSizing("Barriers", _configuration.hud.sizing.BarriersW, _configuration.hud.sizing.BarriersH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.UnitsW, _configuration.hud.sizing.UnitsH = 
                    dropSizing("Units", _configuration.hud.sizing.UnitsW, _configuration.hud.sizing.UnitsH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.MagsW, _configuration.hud.sizing.MagsH = 
                    dropSizing("Mags", _configuration.hud.sizing.MagsW, _configuration.hud.sizing.MagsH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.ConsumablesW, _configuration.hud.sizing.ConsumablesH = 
                    dropSizing("Consumables", _configuration.hud.sizing.ConsumablesW, _configuration.hud.sizing.ConsumablesH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    imgui.TreePop()
                end
                
                if imgui.TreeNodeEx("Techs") then

                    _configuration.hud.sizing.TechReverserW, _configuration.hud.sizing.TechReverserH = 
                    dropSizing("Reverser", _configuration.hud.sizing.TechReverserW, _configuration.hud.sizing.TechReverserH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.TechRyukerW, _configuration.hud.sizing.TechRyukerH = 
                    dropSizing("Ryuker", _configuration.hud.sizing.TechRyukerW, _configuration.hud.sizing.TechRyukerH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.TechAnti5W, _configuration.hud.sizing.TechAnti5H = 
                    dropSizing("Anti 5", _configuration.hud.sizing.TechAnti5W, _configuration.hud.sizing.TechAnti5H, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.TechAnti7W, _configuration.hud.sizing.TechAnti7H = 
                    dropSizing("Anti 7", _configuration.hud.sizing.TechAnti7W, _configuration.hud.sizing.TechAnti7H, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.TechSupport15W, _configuration.hud.sizing.TechSupport15H = 
                    dropSizing("Support Tech 15", _configuration.hud.sizing.TechSupport15W, _configuration.hud.sizing.TechSupport15H, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.TechSupport20W, _configuration.hud.sizing.TechSupport20H = 
                    dropSizing("Support Tech 20", _configuration.hud.sizing.TechSupport20W, _configuration.hud.sizing.TechSupport20H, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.TechAttack15W, _configuration.hud.sizing.TechAttack15H = 
                    dropSizing("Attack Tech 15", _configuration.hud.sizing.TechAttack15W, _configuration.hud.sizing.TechAttack15H, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.TechAttack20W, _configuration.hud.sizing.TechAttack20H = 
                    dropSizing("Attack Tech 20", _configuration.hud.sizing.TechAttack20W, _configuration.hud.sizing.TechAttack20H, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.TechSupport30W, _configuration.hud.sizing.TechSupport30H = 
                    dropSizing("Support Tech", _configuration.hud.sizing.TechSupport30W, _configuration.hud.sizing.TechSupport30H, SWidth, SWidth, MarkerSizeRange, SizingRange)
                    
                    _configuration.hud.sizing.TechAttack30W, _configuration.hud.sizing.TechAttack30H = 
                    dropSizing("Attack Tech", _configuration.hud.sizing.TechAttack30W, _configuration.hud.sizing.TechAttack30H, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.TechMegidW, _configuration.hud.sizing.TechMegidH = 
                    dropSizing("Megid", _configuration.hud.sizing.TechMegidW, _configuration.hud.sizing.TechMegidH, SWidth, SWidth, MarkerSizeRange, SizingRange)
                    
                    _configuration.hud.sizing.TechGrantsW, _configuration.hud.sizing.TechGrantsH = 
                    dropSizing("Grants", _configuration.hud.sizing.TechGrantsW, _configuration.hud.sizing.TechGrantsH, SWidth, SWidth, MarkerSizeRange, SizingRange)


                    _, _configuration.hud.sizing.TechSupportMin = 
                    dropSizing("Support Min Level", nil, _configuration.hud.sizing.TechSupportMin, SWidthP, SWidthP, MarkerSizeRange, TechRange, 1, 1)

                    _, _configuration.hud.sizing.TechAttackMin = 
                    dropSizing("Attack Level", nil, _configuration.hud.sizing.TechAttackMin, SWidthP, SWidthP, MarkerSizeRange, TechRange, 1, 1)
                    
                    _, _configuration.hud.sizing.TechMegidMin = 
                    dropSizing("Megid Min Level", nil, _configuration.hud.sizing.TechMegidMin, SWidthP, SWidthP, MarkerSizeRange, TechRange, 1, 1)

                    _, _configuration.hud.sizing.TechGrantsMin = 
                    dropSizing("Grants Min Level", nil, _configuration.hud.sizing.TechGrantsMin, SWidthP, SWidthP, MarkerSizeRange, TechRange, 1, 1)

                    imgui.TreePop()
                end

                if imgui.TreeNodeEx("Consumables") then

                    _configuration.hud.sizing.MonomateW, _configuration.hud.sizing.MonomateH = 
                    dropSizing("Monomates", _configuration.hud.sizing.MonomateW, _configuration.hud.sizing.MonomateH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.DimateW, _configuration.hud.sizing.DimateH = 
                    dropSizing("Dimates", _configuration.hud.sizing.DimateW, _configuration.hud.sizing.DimateH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.TrimateW, _configuration.hud.sizing.TrimateH = 
                    dropSizing("Trimates", _configuration.hud.sizing.TrimateW, _configuration.hud.sizing.TrimateH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.MonofluidW, _configuration.hud.sizing.MonofluidH = 
                    dropSizing("Monofluids", _configuration.hud.sizing.MonofluidW, _configuration.hud.sizing.MonofluidH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.DifluidW, _configuration.hud.sizing.DifluidH = 
                    dropSizing("Difluids", _configuration.hud.sizing.DifluidW, _configuration.hud.sizing.DifluidH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.TrifluidW, _configuration.hud.sizing.TrifluidH = 
                    dropSizing("Trifluids", _configuration.hud.sizing.TrifluidW, _configuration.hud.sizing.TrifluidH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.SolAtomizerW, _configuration.hud.sizing.SolAtomizerH = 
                    dropSizing("Sol Atomizers", _configuration.hud.sizing.SolAtomizerW, _configuration.hud.sizing.SolAtomizerH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.MoonAtomizerW, _configuration.hud.sizing.MoonAtomizerH = 
                    dropSizing("Moon Atomizers", _configuration.hud.sizing.MoonAtomizerW, _configuration.hud.sizing.MoonAtomizerH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.StarAtomizerW, _configuration.hud.sizing.StarAtomizerH = 
                    dropSizing("Star Atomizers", _configuration.hud.sizing.StarAtomizerW, _configuration.hud.sizing.StarAtomizerH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.AntidoteW, _configuration.hud.sizing.AntidoteH = 
                    dropSizing("Antidotes", _configuration.hud.sizing.AntidoteW, _configuration.hud.sizing.AntidoteH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.AntiparalysisW, _configuration.hud.sizing.AntiparalysisH = 
                    dropSizing("Antiparalysis", _configuration.hud.sizing.AntiparalysisW, _configuration.hud.sizing.AntiparalysisH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.TelepipeW, _configuration.hud.sizing.TelepipeH = 
                    dropSizing("Telepipes", _configuration.hud.sizing.TelepipeW, _configuration.hud.sizing.TelepipeH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.TrapVisionW, _configuration.hud.sizing.TrapVisionH = 
                    dropSizing("Trap Visions", _configuration.hud.sizing.TrapVisionW, _configuration.hud.sizing.TrapVisionH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.ScapeDollW, _configuration.hud.sizing.ScapeDollH = 
                    dropSizing("Scape Dolls", _configuration.hud.sizing.ScapeDollW, _configuration.hud.sizing.ScapeDollH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    imgui.TreePop()
                end


                if imgui.TreeNodeEx("Grinders/Materials") then

                    _configuration.hud.sizing.MonogrinderW, _configuration.hud.sizing.MonogrinderH = 
                    dropSizing("Monogrinders", _configuration.hud.sizing.MonogrinderW, _configuration.hud.sizing.MonogrinderH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.DigrinderW, _configuration.hud.sizing.DigrinderH = 
                    dropSizing("Digrinders", _configuration.hud.sizing.DigrinderW, _configuration.hud.sizing.DigrinderH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.TrigrinderW, _configuration.hud.sizing.TrigrinderH = 
                    dropSizing("Trigrinders", _configuration.hud.sizing.TrigrinderW, _configuration.hud.sizing.TrigrinderH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.HPMatW, _configuration.hud.sizing.HPMatH = 
                    dropSizing("HP Material", _configuration.hud.sizing.HPMatW, _configuration.hud.sizing.HPMatH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.LuckMatW, _configuration.hud.sizing.LuckMatH = 
                    dropSizing("Luck Material", _configuration.hud.sizing.LuckMatW, _configuration.hud.sizing.LuckMatH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.PowerMatW, _configuration.hud.sizing.PowerMatH = 
                    dropSizing("Power Material", _configuration.hud.sizing.PowerMatW, _configuration.hud.sizing.PowerMatH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.MindMatW, _configuration.hud.sizing.MindMatH = 
                    dropSizing("Mind Material", _configuration.hud.sizing.MindMatW, _configuration.hud.sizing.MindMatH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.DefenseMatW, _configuration.hud.sizing.DefenseMatH = 
                    dropSizing("Defense Material", _configuration.hud.sizing.DefenseMatW, _configuration.hud.sizing.DefenseMatH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    _configuration.hud.sizing.EvadeMatW, _configuration.hud.sizing.EvadeMatH = 
                    dropSizing("Evade Material", _configuration.hud.sizing.EvadeMatW, _configuration.hud.sizing.EvadeMatH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                    imgui.TreePop()
                end

                if imgui.Checkbox("Enable Clairs Deal 5 Items", _configuration.ClairesDealEnable) then
                    _configuration.ClairesDealEnable = not _configuration.ClairesDealEnable
                    this.changed = true
                end
                if _configuration.ClairesDealEnable then
                    _configuration.hud.sizing.ClairesDealW, _configuration.hud.sizing.ClairesDealH = 
                    dropSizing("Claire's Deal 5 Items", _configuration.hud.sizing.ClairesDealW, _configuration.hud.sizing.ClairesDealH, SWidth, SWidth, MarkerSizeRange, SizingRange)
                end

                imgui.TreePop()
            end

            imgui.Text("Position and Size")
            imgui.PushItemWidth(200)
            success, _configuration.hud.Anchor = imgui.Combo("Anchor", _configuration.hud.Anchor, anchorList, table.getn(anchorList))
            imgui.PopItemWidth()
            if success then
                _configuration.hud.changed = true
                this.changed = true
            end

            imgui.PushItemWidth(100)
            success, _configuration.hud.X = imgui.InputInt("X", _configuration.hud.X)
            imgui.PopItemWidth()
            if success then
                _configuration.hud.changed = true
                this.changed = true
            end

            imgui.SameLine(0, 38)
            imgui.PushItemWidth(100)
            success, _configuration.hud.Y = imgui.InputInt("Y", _configuration.hud.Y)
            imgui.PopItemWidth()
            if success then
                _configuration.hud.changed = true
                this.changed = true
            end

            imgui.PushItemWidth(100)
            success, _configuration.hud.W = imgui.InputInt("Width", _configuration.hud.W)
            imgui.PopItemWidth()
            if success then
                _configuration.hud.changed = true
                this.changed = true
            end

            imgui.SameLine(0, 10)
            imgui.PushItemWidth(100)
            success, _configuration.hud.H = imgui.InputInt("Height", _configuration.hud.H)
            imgui.PopItemWidth()
            if success then
                _configuration.hud.changed = true
                this.changed = true
            end
            imgui.TreePop()
        end

    end

    this.Update = function()
        if this.open == false then
            return
        end

        local success

        imgui.SetNextWindowSize(500, 400, 'FirstUseEver')
        success, this.open = imgui.Begin(this.title, this.open)

        _showWindowSettings()

        imgui.End()
    end

    return this
end

return
{
    ConfigurationWindow = ConfigurationWindow,
}

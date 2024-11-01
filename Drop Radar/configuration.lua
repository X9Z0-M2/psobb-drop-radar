
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
local function shiftHexColor(color)
    return
    {
        bit.band(bit.rshift(color, 24), 0xFF),
        bit.band(bit.rshift(color, 16), 0xFF),
        bit.band(bit.rshift(color, 8), 0xFF),
        bit.band(color, 0xFF)
    }
end

local function ConfigurationWindow(configuration)
    local this =
    {
        title = "Drop Radar - Configuration",
        open = false,
        changed = false,
    }

    local _configuration = configuration

    local function newViewingConeIndicatorData(hudIdx)
        coneIndicatorDataInitd = true
        viewingConeIndicatorFData[hudIdx] = {}
        viewingConeIndicatorBData[hudIdx] = {}
        for i=1, 180 do
            if _configuration[hudIdx].viewingConeDegs >= math.abs(i-90) then
                table.insert(viewingConeIndicatorFData[hudIdx], math.sin((i+3)/60)*100)
            else
                table.insert(viewingConeIndicatorFData[hudIdx], 0)
            end
        end

        local adjustViewDegs = (180 - _configuration[hudIdx].viewingConeDegs-90)+90
        for i=1, 180 do
            if adjustViewDegs <= math.abs(i-90) then
                table.insert(viewingConeIndicatorBData[hudIdx], math.sin((i+192)/60)*100+100)
            else
                table.insert(viewingConeIndicatorBData[hudIdx], 0)
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
        imgui.ColorButton(i_custom[2] / 255, i_custom[3] / 255, i_custom[4] / 255, i_custom[1] / 255)
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

    local function PresentOverrideButton(buttonName, hudIdx)
        if _configuration[hudIdx].AdditionalHudOverrides then
            local overrideName = buttonName .. "Override"
            if imgui.Checkbox("##" .. overrideName, _configuration[hudIdx][overrideName]) then
                _configuration[hudIdx][overrideName] = not _configuration[hudIdx][overrideName]
                _configuration[hudIdx].changed = true
                if hudIdx == "hud1" then
                    for j=2, _configuration.numHUDs do
                        local hudIdx = "hud" .. j
                        _configuration[hudIdx][overrideName] = _configuration["hud1"][overrideName]
                        _configuration[hudIdx].changed = true
                    end
                end
                this.changed = true
            end
            imgui.SameLine(0, 4)
        end
    end

    local function CopyOverridedSettings(buttonName, hudIdx)
        if _configuration[hudIdx].AdditionalHudOverrides then
            local overrideName = buttonName .. "Override"
            if _configuration[hudIdx][overrideName] then
                _configuration[hudIdx][buttonName] = _configuration["hud1"][buttonName]
                _configuration[hudIdx].changed = true
            end
        end
    end

    local function initConeIndicatorData()
        for j=1, _configuration.numHUDs do
            local hudIdx = "hud" .. j
            newViewingConeIndicatorData(hudIdx)
        end
    end 
    if not coneIndicatorDataInitd then
        initConeIndicatorData()
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

        local numHUDsChanged = false
        local lastNumHUDs

        if imgui.TreeNodeEx("General", "DefaultOpen") then
            if imgui.Checkbox("Enable", _configuration.enable) then
                _configuration.enable = not _configuration.enable
                this.changed = true
            end

            if imgui.Checkbox("Ignore meseta", _configuration.ignoreMeseta) then
                _configuration.ignoreMeseta = not _configuration.ignoreMeseta
                this.changed = true
            end

            if imgui.Checkbox("Relative to Camera", _configuration.relativeCamera) then
                _configuration.relativeCamera = not _configuration.relativeCamera
                this.changed = true
            end

            if imgui.Checkbox("Tile All Huds Together", _configuration.tileAllHuds) then
                _configuration.tileAllHuds = not _configuration.tileAllHuds
                this.changed = true
            end
            if _configuration.tileAllHuds then
                for j=2, _configuration.numHUDs do
                    local hudIdx = "hud" .. j
                    _configuration[hudIdx].Anchor = _configuration["hud1"].Anchor
                    _configuration[hudIdx].X      = _configuration["hud1"].X
                    _configuration[hudIdx].Y      = _configuration["hud1"].Y
                end
            end

            imgui.PushItemWidth(100)
            lastNumHUDs =_configuration.numHUDs
            success, _configuration.numHUDs = imgui.InputInt("Num Huds (for more colors) <- (WARNING: fps performance!)", _configuration.numHUDs)
            imgui.PopItemWidth()
            if success then
                this.changed = true
                numHUDsChanged = true
                _configuration.maxNumHUDs = 20
                _configuration.numHUDs = clampVal(_configuration.numHUDs, 1, _configuration.maxNumHUDs)
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

        local numHUDsToIterate
        if numHUDsChanged and _configuration.numHUDs > lastNumHUDs then
            numHUDsToIterate = lastNumHUDs
        else
            numHUDsToIterate = _configuration.numHUDs
        end
        for i=1, numHUDsToIterate do
            local hudIdx = "hud" .. i
            local nodeName = "Hud " .. i
            if _configuration[hudIdx].customHudColorEnable then
                local i_custom =
                {
                    bit.band(bit.rshift(_configuration[hudIdx].customHudColorMarker, 24), 0xFF),
                    bit.band(bit.rshift(_configuration[hudIdx].customHudColorMarker, 16), 0xFF),
                    bit.band(bit.rshift(_configuration[hudIdx].customHudColorMarker, 8), 0xFF),
                    bit.band(_configuration[hudIdx].customHudColorMarker, 0xFF)
                }
                imgui.ColorButton(i_custom[2] / 255, i_custom[3] / 255, i_custom[4] / 255, i_custom[1] / 255)
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
            end

            if i == 1 then
                nodeName = "Hud Main"
            end
            if imgui.TreeNodeEx(nodeName) then

                local additionalOverrideButtonText = "Enable Additional Hud Overrides"
                if i > 1 then
                    additionalOverrideButtonText = "Sync Additional Hud Overrides"
                end
                if imgui.Checkbox(additionalOverrideButtonText, _configuration[hudIdx].AdditionalHudOverrides) then
                    _configuration[hudIdx].AdditionalHudOverrides = not _configuration[hudIdx].AdditionalHudOverrides
                    _configuration[hudIdx].changed = true
                    this.changed = true
                end

                if imgui.Checkbox("Always On Top", _configuration[hudIdx].AlwaysOnTop) then
                    local alwaysOnTop = not _configuration[hudIdx].AlwaysOnTop
                    if alwaysOnTop then
                        for j=1, _configuration.numHUDs do
                            local hudIdx = "hud" .. j
                            _configuration[hudIdx].AlwaysOnTop = false
                        end
                    end
                    _configuration[hudIdx].AlwaysOnTop = alwaysOnTop
                    _configuration[hudIdx].changed = true
                    this.changed = true
                end

                PresentOverrideButton("EnableWindow", hudIdx)
                if imgui.Checkbox("Enable", _configuration[hudIdx].EnableWindow) then
                    _configuration[hudIdx].EnableWindow = not _configuration[hudIdx].EnableWindow
                    _configuration[hudIdx].changed = true
                    this.changed = true
                end
                
                if imgui.TreeNodeEx("Window") then

                    PresentOverrideButton("HideWhenMenu", hudIdx)
                    if imgui.Checkbox("Hide when menus are open", _configuration[hudIdx].HideWhenMenu) then
                        _configuration[hudIdx].HideWhenMenu = not _configuration[hudIdx].HideWhenMenu
                        this.changed = true
                    end

                    PresentOverrideButton("HideWhenSymbolChat", hudIdx)
                    if imgui.Checkbox("Hide when symbol chat/word select is open", _configuration[hudIdx].HideWhenSymbolChat) then
                        _configuration[hudIdx].HideWhenSymbolChat = not _configuration[hudIdx].HideWhenSymbolChat
                        this.changed = true
                    end

                    PresentOverrideButton("HideWhenMenuUnavailable", hudIdx)
                    if imgui.Checkbox("Hide when the menu is unavailable", _configuration[hudIdx].HideWhenMenuUnavailable) then
                        _configuration[hudIdx].HideWhenMenuUnavailable = not _configuration[hudIdx].HideWhenMenuUnavailable
                        this.changed = true
                    end

                    PresentOverrideButton("NoTitleBar", hudIdx)
                    if imgui.Checkbox("No title bar", _configuration[hudIdx].NoTitleBar == "NoTitleBar") then
                        if _configuration[hudIdx].NoTitleBar == "NoTitleBar" then
                            _configuration[hudIdx].NoTitleBar = ""
                        else
                            _configuration[hudIdx].NoTitleBar = "NoTitleBar"
                        end
                        _configuration[hudIdx].changed = true
                        this.changed = true
                    end

                    PresentOverrideButton("NoResize", hudIdx)
                    if imgui.Checkbox("No resize", _configuration[hudIdx].NoResize == "NoResize") then
                        if _configuration[hudIdx].NoResize == "NoResize" then
                            _configuration[hudIdx].NoResize = ""
                        else
                            _configuration[hudIdx].NoResize = "NoResize"
                        end
                        _configuration[hudIdx].changed = true
                        this.changed = true
                    end

                    PresentOverrideButton("NoMove", hudIdx)
                    if imgui.Checkbox("No move", _configuration[hudIdx].NoMove == "NoMove") then
                        if _configuration[hudIdx].NoMove == "NoMove" then
                            _configuration[hudIdx].NoMove = ""
                        else
                            _configuration[hudIdx].NoMove = "NoMove"
                        end
                        _configuration[hudIdx].changed = true
                        this.changed = true
                    end

                    PresentOverrideButton("AlwaysAutoResize", hudIdx)
                    if imgui.Checkbox("Always Auto Resize", _configuration[hudIdx].AlwaysAutoResize == "AlwaysAutoResize") then
                        if _configuration[hudIdx].AlwaysAutoResize == "AlwaysAutoResize" then
                            _configuration[hudIdx].AlwaysAutoResize = ""
                        else
                            _configuration[hudIdx].AlwaysAutoResize = "AlwaysAutoResize"
                        end
                        _configuration[hudIdx].changed = true
                        this.changed = true
                    end

                    PresentOverrideButton("TransparentWindow", hudIdx)
                    if imgui.Checkbox("Transparent window", _configuration[hudIdx].TransparentWindow) then
                        _configuration[hudIdx].TransparentWindow = not _configuration[hudIdx].TransparentWindow
                        _configuration[hudIdx].changed = true
                        this.changed = true
                    end

                    PresentOverrideButton("customHudColorEnable", hudIdx)
                    if imgui.Checkbox("Custom Hud Color", _configuration[hudIdx].customHudColorEnable) then
                        _configuration[hudIdx].customHudColorEnable = not _configuration[hudIdx].customHudColorEnable
                        this.changed = true
                    end

                    if _configuration[hudIdx].customHudColorEnable then
                        _configuration[hudIdx].customHudColorMarker     = PresentColorEditor("Marker Color",     0xFFFF9900, _configuration[hudIdx].customHudColorMarker)
                        _configuration[hudIdx].customHudColorBackground = PresentColorEditor("Background Color", 0x4CCCCCCC, _configuration[hudIdx].customHudColorBackground)
                        _configuration[hudIdx].customHudColorWindow     = PresentColorEditor("Window Color",     0x46000000, _configuration[hudIdx].customHudColorWindow)
                    end

                    imgui.TreePop()
                end
                
                if imgui.TreeNodeEx("Display") then

                    if _configuration[hudIdx].AdditionalHudOverrides then
                        local overrideName = "reverseItemDirectionOverride"
                        if imgui.Checkbox("##" .. overrideName, _configuration[hudIdx][overrideName]) then
                            _configuration[hudIdx][overrideName] = not _configuration[hudIdx][overrideName]
                            _configuration[hudIdx].changed = true
                            if hudIdx == "hud1" then
                                if _configuration[hudIdx].reverseItemDirection then
                                    _configuration.itemDirectionReversedCount = 1
                                else
                                    _configuration.itemDirectionReversedCount = 0
                                end
                                for j=2, _configuration.maxNumHUDs do
                                    local hudIdx = "hud" .. j
                                    _configuration[hudIdx][overrideName] = _configuration["hud1"][overrideName]
                                    _configuration[hudIdx].changed = true
                                    if _configuration["hud1"].reverseItemDirection and _configuration[hudIdx].enable then
                                        _configuration.itemDirectionReversedCount = _configuration.itemDirectionReversedCount + 1
                                    end
                                end
                            end
                            this.changed = true
                        end
                        if _configuration[hudIdx][overrideName] then
                            _configuration[hudIdx].reverseItemDirection = _configuration["hud1"].reverseItemDirection
                            _configuration[hudIdx].changed = true
                        end
                        imgui.SameLine(0, 4)
                    end
                    if imgui.Checkbox("Reverse Item Direction", _configuration[hudIdx].reverseItemDirection) then
                        _configuration[hudIdx].reverseItemDirection = not _configuration[hudIdx].reverseItemDirection
                        if _configuration[hudIdx].reverseItemDirection then
                            _configuration.itemDirectionReversedCount = _configuration.itemDirectionReversedCount + 1
                        else
                            _configuration.itemDirectionReversedCount = _configuration.itemDirectionReversedCount - 1
                        end
                        this.changed = true
                    end
        
                    PresentOverrideButton("clampItemView", hudIdx)
                    if imgui.Checkbox("Clamp Item Into View", _configuration[hudIdx].clampItemView) then
                        _configuration[hudIdx].clampItemView = not _configuration[hudIdx].clampItemView
                        this.changed = true
                    end
        
                    PresentOverrideButton("invertViewData", hudIdx)
                    if imgui.Checkbox("Invert View", _configuration[hudIdx].invertViewData) then
                        _configuration[hudIdx].invertViewData = not _configuration[hudIdx].invertViewData
                        this.changed = true
                    end
        
                    PresentOverrideButton("invertTickMarkers", hudIdx)
                    if imgui.Checkbox("Invert Tick Markers", _configuration[hudIdx].invertTickMarkers) then
                        _configuration[hudIdx].invertTickMarkers = not _configuration[hudIdx].invertTickMarkers
                        this.changed = true
                    end

                    if viewingConeIndicatorFData[hudIdx] == nil or type(viewingConeIndicatorFData[hudIdx]) ~= "table" then
                        newViewingConeIndicatorData(hudIdx)
                    end
                    imgui.PlotHistogram("Front", viewingConeIndicatorFData[hudIdx], 180, 0, "", 0, 100, 140, 20)
                    imgui.PlotHistogram("Back", viewingConeIndicatorBData[hudIdx], 180, 0, "", 0, 100, 140, 20)

                    PresentOverrideButton("viewingConeDegs", hudIdx)
                    imgui.PushItemWidth(140)
                    success, _configuration[hudIdx].viewingConeDegs = imgui.SliderInt("Viewing Cone (Degrees)", _configuration[hudIdx].viewingConeDegs, 0, 180)
                    imgui.PopItemWidth()
                    if success then
                        this.changed = true
                        newViewingConeIndicatorData(hudIdx)
                    end
        
                    PresentOverrideButton("viewHudPrecision", hudIdx)
                    imgui.PushItemWidth(140)
                    success, _configuration[hudIdx].viewHudPrecision = imgui.SliderFloat("View Precision (> may lag)", _configuration[hudIdx].viewHudPrecision, 0.1, 2)
                    imgui.PopItemWidth()
                    if success then
                        this.changed = true
                        _configuration[hudIdx].viewHudPrecision = clampVal(_configuration[hudIdx].viewHudPrecision, 0, 999999)
                    end
        
                    PresentOverrideButton("ignoreItemMaxDist", hudIdx)
                    imgui.PushItemWidth(100)
                    success, _configuration[hudIdx].ignoreItemMaxDist = imgui.InputInt("Ignore Item Distance (far)", _configuration[hudIdx].ignoreItemMaxDist)
                    imgui.PopItemWidth()
                    if success then
                        this.changed = true
                        _configuration[hudIdx].ignoreItemMaxDist = clampVal(_configuration[hudIdx].ignoreItemMaxDist, 0, 999999)
                    end

                    imgui.TreePop()
                end

                if imgui.TreeNodeEx("Custom Sizing") then
                    local SWidth = 110
                    local SWidthP = SWidth + 16
                    local SizingRange = {0,100}
                    local MarkerSizeRange = {0.001,5}
                    local MesetaRange = {1,999999}
                    local TechRange = {1,30}
                    local TechAntiRange = {1,7}

                    if _configuration[hudIdx].customHudColorEnable then
                        local PlotHistogramColor = shiftHexColor(_configuration[hudIdx].customHudColorMarker)
                        imgui.PushStyleColor("PlotHistogram", PlotHistogramColor[2]/255, PlotHistogramColor[3]/255, PlotHistogramColor[4]/255, PlotHistogramColor[1]/255)
                    end

                    if imgui.TreeNodeEx("Non-Rares") then
                    
                        imgui.PushItemWidth(SWidthP)
                        success, _configuration[hudIdx].sizing.HitMin = imgui.SliderInt("Minimum Hit", _configuration[hudIdx].sizing.HitMin,-10, 100)
                        imgui.PopItemWidth()
                        if success then
                            this.changed = true
                        end

                        _configuration[hudIdx].sizing.LowHitWeaponsW, _configuration[hudIdx].sizing.LowHitWeaponsH = 
                        dropSizing("Low Hit Weapons", _configuration[hudIdx].sizing.LowHitWeaponsW, _configuration[hudIdx].sizing.LowHitWeaponsH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.HighHitWeaponsW, _configuration[hudIdx].sizing.HighHitWeaponsH = 
                        dropSizing("High Hit Weapons", _configuration[hudIdx].sizing.HighHitWeaponsW, _configuration[hudIdx].sizing.HighHitWeaponsH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.UselessArmorsW, _configuration[hudIdx].sizing.UselessArmorsH = 
                        dropSizing("<4s Armor", _configuration[hudIdx].sizing.UselessArmorsW, _configuration[hudIdx].sizing.UselessArmorsH, SWidth, SWidth, MarkerSizeRange, SizingRange)
                        
                        _configuration[hudIdx].sizing.MaxSocketArmorW, _configuration[hudIdx].sizing.MaxSocketArmorH = 
                        dropSizing("=4s Armor", _configuration[hudIdx].sizing.MaxSocketArmorW, _configuration[hudIdx].sizing.MaxSocketArmorH, SWidth, SWidth, MarkerSizeRange, SizingRange)
                        
                        _configuration[hudIdx].sizing.UselessBarriersW, _configuration[hudIdx].sizing.UselessBarriersH = 
                        dropSizing("Useless Barriers", _configuration[hudIdx].sizing.UselessBarriersW, _configuration[hudIdx].sizing.UselessBarriersH, SWidth, SWidth, MarkerSizeRange, SizingRange)
                        
                        _configuration[hudIdx].sizing.UselessUnitsW, _configuration[hudIdx].sizing.UselessUnitsH = 
                        dropSizing("Useless Units", _configuration[hudIdx].sizing.UselessUnitsW, _configuration[hudIdx].sizing.UselessUnitsH, SWidth, SWidth, MarkerSizeRange, SizingRange)
                        
                        _configuration[hudIdx].sizing.UselessTechsW, _configuration[hudIdx].sizing.UselessTechsH = 
                        dropSizing("Useless Techs", _configuration[hudIdx].sizing.UselessTechsW, _configuration[hudIdx].sizing.UselessTechsH, SWidth, SWidth, MarkerSizeRange, SizingRange)
                        
                        if not _configuration.ignoreMeseta then
                            _configuration[hudIdx].sizing.MesetaW, _configuration[hudIdx].sizing.MesetaMinH = 
                            dropSizing("Meseta Height Min", _configuration[hudIdx].sizing.MesetaW, _configuration[hudIdx].sizing.MesetaMinH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                            _configuration[hudIdx].sizing.MesetaW, _configuration[hudIdx].sizing.MesetaMaxH = 
                            dropSizing("Meseta Height Max", _configuration[hudIdx].sizing.MesetaW, _configuration[hudIdx].sizing.MesetaMaxH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                            imgui.PushItemWidth(SWidthP)
                            success, _configuration[hudIdx].sizing.MesetaMin = imgui.DragInt("Meseta Min (will ignore below amount)", _configuration[hudIdx].sizing.MesetaMin, 10, MesetaRange[1], MesetaRange[2])
                            imgui.PopItemWidth()
                            if success then
                                this.changed = true
                            end
                            if _configuration[hudIdx].sizing.MesetaMin > _configuration[hudIdx].sizing.MesetaMax then
                                _configuration[hudIdx].sizing.MesetaMin = _configuration[hudIdx].sizing.MesetaMax
                            end

                            imgui.PushItemWidth(SWidthP)
                            success, _configuration[hudIdx].sizing.MesetaMax = imgui.DragInt("Meseta Max (doesn't filter out)", _configuration[hudIdx].sizing.MesetaMax, 10, MesetaRange[1], MesetaRange[2])
                            imgui.PopItemWidth()
                            if success then
                                this.changed = true
                            end
                            if _configuration[hudIdx].sizing.MesetaMax < _configuration[hudIdx].sizing.MesetaMin then
                                _configuration[hudIdx].sizing.MesetaMax = _configuration[hudIdx].sizing.MesetaMin
                            end
                        end

                        imgui.TreePop()
                    end

                    if imgui.TreeNodeEx("Rares") then

                        _configuration[hudIdx].sizing.WeaponsW, _configuration[hudIdx].sizing.WeaponsH = 
                        dropSizing("Weapons", _configuration[hudIdx].sizing.WeaponsW, _configuration[hudIdx].sizing.WeaponsH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.SRankWeaponsW, _configuration[hudIdx].sizing.SRankWeaponsH = 
                        dropSizing("SRank Weapons", _configuration[hudIdx].sizing.SRankWeaponsW, _configuration[hudIdx].sizing.SRankWeaponsH, SWidth, SWidth, MarkerSizeRange, SizingRange)
                        
                        _configuration[hudIdx].sizing.ArmorsW, _configuration[hudIdx].sizing.ArmorsH = 
                        dropSizing("Armor", _configuration[hudIdx].sizing.ArmorsW, _configuration[hudIdx].sizing.ArmorsH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.BarriersW, _configuration[hudIdx].sizing.BarriersH = 
                        dropSizing("Barriers", _configuration[hudIdx].sizing.BarriersW, _configuration[hudIdx].sizing.BarriersH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.UnitsW, _configuration[hudIdx].sizing.UnitsH = 
                        dropSizing("Units", _configuration[hudIdx].sizing.UnitsW, _configuration[hudIdx].sizing.UnitsH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.MagsW, _configuration[hudIdx].sizing.MagsH = 
                        dropSizing("Mags", _configuration[hudIdx].sizing.MagsW, _configuration[hudIdx].sizing.MagsH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.ConsumablesW, _configuration[hudIdx].sizing.ConsumablesH = 
                        dropSizing("Consumables", _configuration[hudIdx].sizing.ConsumablesW, _configuration[hudIdx].sizing.ConsumablesH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        imgui.TreePop()
                    end
                    
                    if imgui.TreeNodeEx("Techs") then

                        _configuration[hudIdx].sizing.TechReverserW, _configuration[hudIdx].sizing.TechReverserH = 
                        dropSizing("Reverser", _configuration[hudIdx].sizing.TechReverserW, _configuration[hudIdx].sizing.TechReverserH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.TechRyukerW, _configuration[hudIdx].sizing.TechRyukerH = 
                        dropSizing("Ryuker", _configuration[hudIdx].sizing.TechRyukerW, _configuration[hudIdx].sizing.TechRyukerH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.TechAnti5W, _configuration[hudIdx].sizing.TechAnti5H = 
                        dropSizing("Anti 5", _configuration[hudIdx].sizing.TechAnti5W, _configuration[hudIdx].sizing.TechAnti5H, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.TechAnti7W, _configuration[hudIdx].sizing.TechAnti7H = 
                        dropSizing("Anti 7", _configuration[hudIdx].sizing.TechAnti7W, _configuration[hudIdx].sizing.TechAnti7H, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.TechSupport15W, _configuration[hudIdx].sizing.TechSupport15H = 
                        dropSizing("Support Tech 15", _configuration[hudIdx].sizing.TechSupport15W, _configuration[hudIdx].sizing.TechSupport15H, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.TechSupport20W, _configuration[hudIdx].sizing.TechSupport20H = 
                        dropSizing("Support Tech 20", _configuration[hudIdx].sizing.TechSupport20W, _configuration[hudIdx].sizing.TechSupport20H, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.TechAttack15W, _configuration[hudIdx].sizing.TechAttack15H = 
                        dropSizing("Attack Tech 15", _configuration[hudIdx].sizing.TechAttack15W, _configuration[hudIdx].sizing.TechAttack15H, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.TechAttack20W, _configuration[hudIdx].sizing.TechAttack20H = 
                        dropSizing("Attack Tech 20", _configuration[hudIdx].sizing.TechAttack20W, _configuration[hudIdx].sizing.TechAttack20H, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.TechSupport30W, _configuration[hudIdx].sizing.TechSupport30H = 
                        dropSizing("Support Tech", _configuration[hudIdx].sizing.TechSupport30W, _configuration[hudIdx].sizing.TechSupport30H, SWidth, SWidth, MarkerSizeRange, SizingRange)
                        
                        _configuration[hudIdx].sizing.TechAttack30W, _configuration[hudIdx].sizing.TechAttack30H = 
                        dropSizing("Attack Tech", _configuration[hudIdx].sizing.TechAttack30W, _configuration[hudIdx].sizing.TechAttack30H, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.TechMegidW, _configuration[hudIdx].sizing.TechMegidH = 
                        dropSizing("Megid", _configuration[hudIdx].sizing.TechMegidW, _configuration[hudIdx].sizing.TechMegidH, SWidth, SWidth, MarkerSizeRange, SizingRange)
                        
                        _configuration[hudIdx].sizing.TechGrantsW, _configuration[hudIdx].sizing.TechGrantsH = 
                        dropSizing("Grants", _configuration[hudIdx].sizing.TechGrantsW, _configuration[hudIdx].sizing.TechGrantsH, SWidth, SWidth, MarkerSizeRange, SizingRange)


                        _, _configuration[hudIdx].sizing.TechSupportMin = 
                        dropSizing("Support Min Level", nil, _configuration[hudIdx].sizing.TechSupportMin, SWidthP, SWidthP, MarkerSizeRange, TechRange, 1, 1)

                        _, _configuration[hudIdx].sizing.TechAttackMin = 
                        dropSizing("Attack Level", nil, _configuration[hudIdx].sizing.TechAttackMin, SWidthP, SWidthP, MarkerSizeRange, TechRange, 1, 1)
                        
                        _, _configuration[hudIdx].sizing.TechMegidMin = 
                        dropSizing("Megid Min Level", nil, _configuration[hudIdx].sizing.TechMegidMin, SWidthP, SWidthP, MarkerSizeRange, TechRange, 1, 1)

                        _, _configuration[hudIdx].sizing.TechGrantsMin = 
                        dropSizing("Grants Min Level", nil, _configuration[hudIdx].sizing.TechGrantsMin, SWidthP, SWidthP, MarkerSizeRange, TechRange, 1, 1)

                        imgui.TreePop()
                    end

                    if imgui.TreeNodeEx("Consumables") then

                        _configuration[hudIdx].sizing.MonomateW, _configuration[hudIdx].sizing.MonomateH = 
                        dropSizing("Monomates", _configuration[hudIdx].sizing.MonomateW, _configuration[hudIdx].sizing.MonomateH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.DimateW, _configuration[hudIdx].sizing.DimateH = 
                        dropSizing("Dimates", _configuration[hudIdx].sizing.DimateW, _configuration[hudIdx].sizing.DimateH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.TrimateW, _configuration[hudIdx].sizing.TrimateH = 
                        dropSizing("Trimates", _configuration[hudIdx].sizing.TrimateW, _configuration[hudIdx].sizing.TrimateH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.MonofluidW, _configuration[hudIdx].sizing.MonofluidH = 
                        dropSizing("Monofluids", _configuration[hudIdx].sizing.MonofluidW, _configuration[hudIdx].sizing.MonofluidH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.DifluidW, _configuration[hudIdx].sizing.DifluidH = 
                        dropSizing("Difluids", _configuration[hudIdx].sizing.DifluidW, _configuration[hudIdx].sizing.DifluidH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.TrifluidW, _configuration[hudIdx].sizing.TrifluidH = 
                        dropSizing("Trifluids", _configuration[hudIdx].sizing.TrifluidW, _configuration[hudIdx].sizing.TrifluidH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.SolAtomizerW, _configuration[hudIdx].sizing.SolAtomizerH = 
                        dropSizing("Sol Atomizers", _configuration[hudIdx].sizing.SolAtomizerW, _configuration[hudIdx].sizing.SolAtomizerH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.MoonAtomizerW, _configuration[hudIdx].sizing.MoonAtomizerH = 
                        dropSizing("Moon Atomizers", _configuration[hudIdx].sizing.MoonAtomizerW, _configuration[hudIdx].sizing.MoonAtomizerH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.StarAtomizerW, _configuration[hudIdx].sizing.StarAtomizerH = 
                        dropSizing("Star Atomizers", _configuration[hudIdx].sizing.StarAtomizerW, _configuration[hudIdx].sizing.StarAtomizerH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.AntidoteW, _configuration[hudIdx].sizing.AntidoteH = 
                        dropSizing("Antidotes", _configuration[hudIdx].sizing.AntidoteW, _configuration[hudIdx].sizing.AntidoteH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.AntiparalysisW, _configuration[hudIdx].sizing.AntiparalysisH = 
                        dropSizing("Antiparalysis", _configuration[hudIdx].sizing.AntiparalysisW, _configuration[hudIdx].sizing.AntiparalysisH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.TelepipeW, _configuration[hudIdx].sizing.TelepipeH = 
                        dropSizing("Telepipes", _configuration[hudIdx].sizing.TelepipeW, _configuration[hudIdx].sizing.TelepipeH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.TrapVisionW, _configuration[hudIdx].sizing.TrapVisionH = 
                        dropSizing("Trap Visions", _configuration[hudIdx].sizing.TrapVisionW, _configuration[hudIdx].sizing.TrapVisionH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.ScapeDollW, _configuration[hudIdx].sizing.ScapeDollH = 
                        dropSizing("Scape Dolls", _configuration[hudIdx].sizing.ScapeDollW, _configuration[hudIdx].sizing.ScapeDollH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        imgui.TreePop()
                    end

                    if imgui.TreeNodeEx("Grinders/Materials") then

                        _configuration[hudIdx].sizing.MonogrinderW, _configuration[hudIdx].sizing.MonogrinderH = 
                        dropSizing("Monogrinders", _configuration[hudIdx].sizing.MonogrinderW, _configuration[hudIdx].sizing.MonogrinderH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.DigrinderW, _configuration[hudIdx].sizing.DigrinderH = 
                        dropSizing("Digrinders", _configuration[hudIdx].sizing.DigrinderW, _configuration[hudIdx].sizing.DigrinderH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.TrigrinderW, _configuration[hudIdx].sizing.TrigrinderH = 
                        dropSizing("Trigrinders", _configuration[hudIdx].sizing.TrigrinderW, _configuration[hudIdx].sizing.TrigrinderH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.HPMatW, _configuration[hudIdx].sizing.HPMatH = 
                        dropSizing("HP Material", _configuration[hudIdx].sizing.HPMatW, _configuration[hudIdx].sizing.HPMatH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.TPMatW, _configuration[hudIdx].sizing.TPMatH = 
                        dropSizing("TP Material", _configuration[hudIdx].sizing.TPMatW, _configuration[hudIdx].sizing.TPMatH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.LuckMatW, _configuration[hudIdx].sizing.LuckMatH = 
                        dropSizing("Luck Material", _configuration[hudIdx].sizing.LuckMatW, _configuration[hudIdx].sizing.LuckMatH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.PowerMatW, _configuration[hudIdx].sizing.PowerMatH = 
                        dropSizing("Power Material", _configuration[hudIdx].sizing.PowerMatW, _configuration[hudIdx].sizing.PowerMatH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.MindMatW, _configuration[hudIdx].sizing.MindMatH = 
                        dropSizing("Mind Material", _configuration[hudIdx].sizing.MindMatW, _configuration[hudIdx].sizing.MindMatH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.DefenseMatW, _configuration[hudIdx].sizing.DefenseMatH = 
                        dropSizing("Defense Material", _configuration[hudIdx].sizing.DefenseMatW, _configuration[hudIdx].sizing.DefenseMatH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        _configuration[hudIdx].sizing.EvadeMatW, _configuration[hudIdx].sizing.EvadeMatH = 
                        dropSizing("Evade Material", _configuration[hudIdx].sizing.EvadeMatW, _configuration[hudIdx].sizing.EvadeMatH, SWidth, SWidth, MarkerSizeRange, SizingRange)

                        imgui.TreePop()
                    end

                    if imgui.Checkbox("Enable Clairs Deal 5 Items", _configuration[hudIdx].sizing.ClairesDealEnable) then
                        _configuration[hudIdx].sizing.ClairesDealEnable = not _configuration[hudIdx].sizing.ClairesDealEnable
                        this.changed = true
                    end
                    if _configuration[hudIdx].sizing.ClairesDealEnable then
                        _configuration[hudIdx].sizing.ClairesDealW, _configuration[hudIdx].sizing.ClairesDealH = 
                        dropSizing("Claire's Deal 5 Items", _configuration[hudIdx].sizing.ClairesDealW, _configuration[hudIdx].sizing.ClairesDealH, SWidth, SWidth, MarkerSizeRange, SizingRange)
                    end

                    if _configuration[hudIdx].customHudColorEnable then
                        imgui.PopStyleColor()
                    end

                    imgui.TreePop()
                end

                if not _configuration.tileAllHuds or hudIdx == "hud1" then
                    imgui.Text("Position and Size")
                    PresentOverrideButton("Anchor", hudIdx)
                    imgui.PushItemWidth(200)
                    success, _configuration[hudIdx].Anchor = imgui.Combo("Anchor", _configuration[hudIdx].Anchor, anchorList, table.getn(anchorList))
                    imgui.PopItemWidth()
                    if success then
                        _configuration[hudIdx].changed = true
                        this.changed = true
                    end

                    imgui.PushItemWidth(100)
                    PresentOverrideButton("X", hudIdx)
                    success, _configuration[hudIdx].X = imgui.InputInt("X", _configuration[hudIdx].X)
                    imgui.PopItemWidth()
                    if success then
                        _configuration[hudIdx].changed = true
                        this.changed = true
                    end

                    imgui.SameLine(0, 38)
                    imgui.PushItemWidth(100)
                    PresentOverrideButton("Y", hudIdx)
                    success, _configuration[hudIdx].Y = imgui.InputInt("Y", _configuration[hudIdx].Y)
                    imgui.PopItemWidth()
                    if success then
                        _configuration[hudIdx].changed = true
                        this.changed = true
                    end
                end

                imgui.PushItemWidth(100)
                PresentOverrideButton("W", hudIdx)
                success, _configuration[hudIdx].W = imgui.InputInt("Width", _configuration[hudIdx].W)
                imgui.PopItemWidth()
                if success then
                    _configuration[hudIdx].changed = true
                    this.changed = true
                end

                imgui.SameLine(0, 10)
                imgui.PushItemWidth(100)
                PresentOverrideButton("H", hudIdx)
                success, _configuration[hudIdx].H = imgui.InputInt("Height", _configuration[hudIdx].H)
                imgui.PopItemWidth()
                if success then
                    _configuration[hudIdx].changed = true
                    this.changed = true
                end
                imgui.TreePop()
            end

            if this.changed and i > 1 then
                CopyOverridedSettings("EnableWindow", hudIdx)
                CopyOverridedSettings("HideWhenMenu", hudIdx)
                CopyOverridedSettings("HideWhenSymbolChat", hudIdx)
                CopyOverridedSettings("HideWhenMenuUnavailable", hudIdx)
                CopyOverridedSettings("NoTitleBar", hudIdx)
                CopyOverridedSettings("NoResize", hudIdx)
                CopyOverridedSettings("NoMove", hudIdx)
                CopyOverridedSettings("AlwaysAutoResize", hudIdx)
                CopyOverridedSettings("TransparentWindow", hudIdx)
                CopyOverridedSettings("customHudColorEnable", hudIdx)
                CopyOverridedSettings("reverseItemDirection", hudIdx)
                CopyOverridedSettings("clampItemView", hudIdx)
                CopyOverridedSettings("invertViewData", hudIdx)
                CopyOverridedSettings("invertTickMarkers", hudIdx)
                CopyOverridedSettings("viewingConeDegs", hudIdx)
                CopyOverridedSettings("viewHudPrecision", hudIdx)
                CopyOverridedSettings("ignoreItemMaxDist", hudIdx)
                CopyOverridedSettings("Anchor", hudIdx)
                CopyOverridedSettings("X", hudIdx)
                CopyOverridedSettings("Y", hudIdx)
                CopyOverridedSettings("H", hudIdx)
                CopyOverridedSettings("W", hudIdx)
            end
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

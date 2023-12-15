local function ConfigurationWindow(configuration)
    local this =
    {
        title = "Drop Map - Configuration",
        open = false,
        changed = false,
    }

    local _configuration = configuration

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

        local function dropSizing(Name, Setting, Width, Range, NoGraph)
            if Width == nil then return Setting end
            if Range == nil or type(Range) ~= "table" or Range[1] == nil or Range[2] == nil then return Setting end
            if not NoGraph then
                imgui.PlotHistogram("", {Setting}, 1, 0, "", 0, 100, 12, 20)
                imgui.SameLine(0, 4)
            end
            imgui.PushItemWidth(Width)
            success, Setting = imgui.SliderInt(Name, Setting, Range[1], Range[2])
            imgui.PopItemWidth()
            if success then
                this.changed = true
            end
            return Setting
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
                local MesetaRange = {1,999999}
                local TechRange = {1,30}
                local TechAntiRange = {1,7}

                if imgui.TreeNodeEx("Non-Rares") then
                
                    imgui.Columns(2, "nonrare")
                    imgui.PushItemWidth(SWidth)
                    success, _configuration.hud.sizing.HitMin = imgui.InputInt("Minimum Hit", _configuration.hud.sizing.HitMin)
                    imgui.PopItemWidth()
                    if success then
                        this.changed = true
                    end
                    imgui.NextColumn()
                    imgui.NextColumn()

                    _configuration.hud.sizing.LowHitWeaponsH = dropSizing("Low Hit Weapons", _configuration.hud.sizing.LowHitWeaponsH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.HighHitWeaponsH = dropSizing("High Hit Weapons", _configuration.hud.sizing.HighHitWeaponsH, SWidth, SizingRange)
                    imgui.NextColumn()

                    _configuration.hud.sizing.UselessArmorsH = dropSizing("<4s Armor", _configuration.hud.sizing.UselessArmorsH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.MaxSocketArmorH = dropSizing("=4s Armor", _configuration.hud.sizing.MaxSocketArmorH, SWidth, SizingRange)
                    imgui.NextColumn()
                    
                    _configuration.hud.sizing.UselessWeaponsH = dropSizing("Useless Weapons", _configuration.hud.sizing.UselessWeaponsH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.UselessBarriersH = dropSizing("Useless Barriers", _configuration.hud.sizing.UselessBarriersH, SWidth, SizingRange)
                    imgui.NextColumn()
                    
                    _configuration.hud.sizing.UselessUnitsH = dropSizing("Useless Units", _configuration.hud.sizing.UselessUnitsH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.UselessTechsH = dropSizing("Useless Techs", _configuration.hud.sizing.UselessTechsH, SWidth, SizingRange)
                    imgui.NextColumn()
                    
                    _configuration.hud.sizing.MesetaMinH = dropSizing("Meseta Height Min", _configuration.hud.sizing.MesetaMinH, SWidth, SizingRange)
                    if _configuration.hud.sizing.MesetaMinH > _configuration.hud.sizing.MesetaMaxH then
                        _configuration.hud.sizing.MesetaMinH = _configuration.hud.sizing.MesetaMaxH
                    end
                    imgui.NextColumn()
                    _configuration.hud.sizing.MesetaMaxH = dropSizing("Meseta Height Max", _configuration.hud.sizing.MesetaMaxH, SWidth, SizingRange)
                    if _configuration.hud.sizing.MesetaMaxH < _configuration.hud.sizing.MesetaMinH then
                        _configuration.hud.sizing.MesetaMaxH = _configuration.hud.sizing.MesetaMinH
                    end
                    imgui.NextColumn()

                    imgui.PushItemWidth(SWidthP)
                    success, _configuration.hud.sizing.MesetaMin = imgui.DragInt("Meseta Min", _configuration.hud.sizing.MesetaMin, 10, MesetaRange[1], MesetaRange[2])
                    imgui.PopItemWidth()
                    if success then
                        this.changed = true
                    end
                    if _configuration.hud.sizing.MesetaMin > _configuration.hud.sizing.MesetaMax then
                        _configuration.hud.sizing.MesetaMin = _configuration.hud.sizing.MesetaMax
                    end
                    imgui.NextColumn()
                    imgui.PushItemWidth(SWidthP)
                    success, _configuration.hud.sizing.MesetaMax = imgui.DragInt("Meseta Max", _configuration.hud.sizing.MesetaMax, 10, MesetaRange[1], MesetaRange[2])
                    imgui.PopItemWidth()
                    if success then
                        this.changed = true
                    end
                    if _configuration.hud.sizing.MesetaMax < _configuration.hud.sizing.MesetaMin then
                        _configuration.hud.sizing.MesetaMax = _configuration.hud.sizing.MesetaMin
                    end

                    imgui.Columns(1)
                    imgui.TreePop()
                end

                
                if imgui.TreeNodeEx("Rares") then

                    imgui.Columns(2, "rare")
                    _configuration.hud.sizing.WeaponsH = dropSizing("Weapons", _configuration.hud.sizing.WeaponsH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.SRankWeaponsH = dropSizing("SRank Weapons", _configuration.hud.sizing.SRankWeaponsH, SWidth, SizingRange)
                    imgui.NextColumn()

                    _configuration.hud.sizing.ArmorsH = dropSizing("Armor", _configuration.hud.sizing.ArmorsH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.BarriersH = dropSizing("Barriers", _configuration.hud.sizing.BarriersH, SWidth, SizingRange)
                    imgui.NextColumn()

                    _configuration.hud.sizing.UnitsH = dropSizing("Units", _configuration.hud.sizing.UnitsH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.MagsH = dropSizing("Mags", _configuration.hud.sizing.MagsH, SWidth, SizingRange)
                    imgui.NextColumn()

                    _configuration.hud.sizing.ConsumablesH = dropSizing("Consumables", _configuration.hud.sizing.ConsumablesH, SWidth, SizingRange)
                    imgui.NextColumn()

                    imgui.Columns(1)
                    imgui.TreePop()
                end
                
                if imgui.TreeNodeEx("Techs") then

                    imgui.Columns(2, "tech")
                    _configuration.hud.sizing.TechReverserH = dropSizing("Reverser",_configuration.hud.sizing.TechReverserH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.TechRyukerH = dropSizing("Ryuker",_configuration.hud.sizing.TechRyukerH, SWidth, SizingRange)
                    imgui.NextColumn()

                    _configuration.hud.sizing.TechAnti5H = dropSizing("Anti 5",_configuration.hud.sizing.TechAnti5H, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.TechAnti7H = dropSizing("Anti 7",_configuration.hud.sizing.TechAnti7H, SWidth, SizingRange)
                    imgui.NextColumn()

                    _configuration.hud.sizing.TechSupport15H = dropSizing("Support Tech 15",_configuration.hud.sizing.TechSupport15H, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.TechSupport20H = dropSizing("Support Tech 20",_configuration.hud.sizing.TechSupport20H, SWidth, SizingRange)
                    imgui.NextColumn()

                    _configuration.hud.sizing.TechAttack15H = dropSizing("Attack Tech 15",_configuration.hud.sizing.TechAttack15H, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.TechAttack20H = dropSizing("Attack Tech 20",_configuration.hud.sizing.TechAttack20H, SWidth, SizingRange)
                    imgui.NextColumn()

                    _configuration.hud.sizing.TechSupport30H = dropSizing("Support Tech",_configuration.hud.sizing.TechSupport30H, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.TechSupportMin = dropSizing("Support Min Level",_configuration.hud.sizing.TechSupportMin, SWidthP, TechRange, 1)
                    imgui.NextColumn()

                    _configuration.hud.sizing.TechAttack30H = dropSizing("Attack Tech",_configuration.hud.sizing.TechAttack30H, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.TechAttackMin = dropSizing("Attack Level",_configuration.hud.sizing.TechAttackMin, SWidthP, TechRange, 1)
                    imgui.NextColumn()

                    _configuration.hud.sizing.TechMegidH = dropSizing("Megid",_configuration.hud.sizing.TechMegidH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.TechMegidMin = dropSizing("Megid Min Level",_configuration.hud.sizing.TechMegidMin, SWidthP, TechRange, 1)
                    imgui.NextColumn()

                    _configuration.hud.sizing.TechGrantsH = dropSizing("Grants",_configuration.hud.sizing.TechGrantsH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.TechGrantsMin = dropSizing("Grants Min Level",_configuration.hud.sizing.TechGrantsMin, SWidthP, TechRange, 1)
                    imgui.NextColumn()

                    imgui.Columns(1)
                    imgui.TreePop()
                end

                if imgui.TreeNodeEx("Consumables") then

                    imgui.Columns(2, "consumable")
                    _configuration.hud.sizing.MonomateH = dropSizing("Monomates",_configuration.hud.sizing.MonomateH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.DimateH = dropSizing("Dimates",_configuration.hud.sizing.DimateH, SWidth, SizingRange)
                    imgui.NextColumn()

                    _configuration.hud.sizing.TrimateH = dropSizing("Trimates",_configuration.hud.sizing.TrimateH, SWidth, SizingRange)
                    imgui.NextColumn()
                    imgui.NextColumn()

                    _configuration.hud.sizing.MonofluidH = dropSizing("Monofluids",_configuration.hud.sizing.MonofluidH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.DifluidH = dropSizing("Difluids",_configuration.hud.sizing.DifluidH, SWidth, SizingRange)
                    imgui.NextColumn()

                    _configuration.hud.sizing.TrifluidH = dropSizing("Trifluids",_configuration.hud.sizing.TrifluidH, SWidth, SizingRange)
                    imgui.NextColumn()
                    imgui.NextColumn()
                    
                    _configuration.hud.sizing.SolAtomizerH = dropSizing("Sol Atomizers",_configuration.hud.sizing.SolAtomizerH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.MoonAtomizerH = dropSizing("Moon Atomizers",_configuration.hud.sizing.MoonAtomizerH, SWidth, SizingRange)
                    imgui.NextColumn()

                    _configuration.hud.sizing.StarAtomizerH = dropSizing("Star Atomizers",_configuration.hud.sizing.StarAtomizerH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.AntidoteH = dropSizing("Antidotes",_configuration.hud.sizing.AntidoteH, SWidth, SizingRange)
                    imgui.NextColumn()

                    _configuration.hud.sizing.AntiparalysisH = dropSizing("Antiparalysis",_configuration.hud.sizing.AntiparalysisH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.TelepipeH = dropSizing("Telepipes",_configuration.hud.sizing.TelepipeH, SWidth, SizingRange)
                    imgui.NextColumn()

                    _configuration.hud.sizing.TrapVisionH = dropSizing("Trap Visions",_configuration.hud.sizing.TrapVisionH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.ScapeDollH = dropSizing("Scape Dolls",_configuration.hud.sizing.ScapeDollH, SWidth, SizingRange)
                    imgui.NextColumn()

                    imgui.Columns(1)
                    imgui.TreePop()
                end


                if imgui.TreeNodeEx("Grinders/Materials") then

                    imgui.Columns(2, "improver")
                    _configuration.hud.sizing.MonogrinderH = dropSizing("Monogrinders",_configuration.hud.sizing.MonogrinderH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.DigrinderH = dropSizing("Digrinders",_configuration.hud.sizing.DigrinderH, SWidth, SizingRange)
                    imgui.NextColumn()

                    _configuration.hud.sizing.TrigrinderH = dropSizing("Trigrinders",_configuration.hud.sizing.TrigrinderH, SWidth, SizingRange)
                    imgui.NextColumn()
                    imgui.NextColumn()

                    _configuration.hud.sizing.HPMatH = dropSizing("HP Material",_configuration.hud.sizing.HPMatH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.LuckMatH = dropSizing("Luck Material",_configuration.hud.sizing.LuckMatH, SWidth, SizingRange)
                    imgui.NextColumn()

                    _configuration.hud.sizing.PowerMatH = dropSizing("Power Material",_configuration.hud.sizing.PowerMatH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.MindMatH = dropSizing("Mind Material",_configuration.hud.sizing.MindMatH, SWidth, SizingRange)
                    imgui.NextColumn()

                    _configuration.hud.sizing.DefenseMatH = dropSizing("Defense Material",_configuration.hud.sizing.DefenseMatH, SWidth, SizingRange)
                    imgui.NextColumn()
                    _configuration.hud.sizing.EvadeMatH = dropSizing("Evade Material",_configuration.hud.sizing.EvadeMatH, SWidth, SizingRange)
                    imgui.NextColumn()

                    imgui.Columns(1)
                    imgui.TreePop()
                end

                _configuration.hud.sizing.ClairesDealH = dropSizing("Claire's Deal 5 Items",_configuration.hud.sizing.ClairesDealH, SWidth, SizingRange)

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

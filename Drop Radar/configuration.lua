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

                imgui.Text("Non-Rares")
                
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.HitMin = imgui.InputInt("Minimum Hit", _configuration.hud.sizing.HitMin)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.LowHitWeaponsH = imgui.SliderInt("Low Hit Weapons H", _configuration.hud.sizing.LowHitWeaponsH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 9)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.HighHitWeaponsH = imgui.SliderInt("High Hit Weapons H", _configuration.hud.sizing.HighHitWeaponsH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.UselessArmorsH = imgui.SliderInt("<4s Armor H", _configuration.hud.sizing.UselessArmorsH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 44)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.MaxSocketArmorH = imgui.SliderInt("=4s Armor H", _configuration.hud.sizing.MaxSocketArmorH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.UselessWeaponsH = imgui.SliderInt("Useless Weapons H", _configuration.hud.sizing.UselessWeaponsH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 11)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.UselessBarriersH = imgui.SliderInt("Useless Barriers H", _configuration.hud.sizing.UselessBarriersH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.UselessUnitsH = imgui.SliderInt("Useless Units H", _configuration.hud.sizing.UselessUnitsH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 29)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.UselessTechsH = imgui.SliderInt("Useless Techs H", _configuration.hud.sizing.UselessTechsH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth * 2 + 4)
                success, _configuration.hud.sizing.MesetaMin, _configuration.hud.sizing.MesetaMax = imgui.DragIntRange2("Meseta Min | Max", _configuration.hud.sizing.MesetaMin, _configuration.hud.sizing.MesetaMax, 1, 999999)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth * 2 + 4)
                success, _configuration.hud.sizing.MesetaMinH, _configuration.hud.sizing.MesetaMaxH = imgui.DragIntRange2("Meseta Height Min | Max", _configuration.hud.sizing.MesetaMinH, _configuration.hud.sizing.MesetaMaxH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                
                imgui.Text("Rares")

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.WeaponsH = imgui.SliderInt("Weapons H", _configuration.hud.sizing.WeaponsH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 53)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.SRankWeaponsH = imgui.SliderInt("SRank Weapons H", _configuration.hud.sizing.SRankWeaponsH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.ArmorsH = imgui.SliderInt("Armor H", _configuration.hud.sizing.ArmorsH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 57)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.BarriersH = imgui.SliderInt("Barriers H", _configuration.hud.sizing.BarriersH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.UnitsH = imgui.SliderInt("Units H", _configuration.hud.sizing.UnitsH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 69)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.MagsH = imgui.SliderInt("Mags H", _configuration.hud.sizing.MagsH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.ConsumablesH = imgui.SliderInt("Consumables H", _configuration.hud.sizing.ConsumablesH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TechReverserH = imgui.SliderInt("Reverser H", _configuration.hud.sizing.TechReverserH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 69)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TechRyukerH = imgui.SliderInt("Ryuker H", _configuration.hud.sizing.TechRyukerH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TechMegidH = imgui.SliderInt("Megid H", _configuration.hud.sizing.TechMegidH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 69)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TechGrantsH = imgui.SliderInt("Grants H", _configuration.hud.sizing.TechGrantsH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TechAnti5H = imgui.SliderInt("Anti 5 H", _configuration.hud.sizing.TechAnti5H, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 69)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TechAnti7H = imgui.SliderInt("Anti 7+ H", _configuration.hud.sizing.TechAnti7H, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TechSupport15H = imgui.SliderInt("Support Tech 15 H", _configuration.hud.sizing.TechSupport15H, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 69)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TechSupport20H = imgui.SliderInt("Support Tech 20 H", _configuration.hud.sizing.TechSupport20H, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TechSupport30H = imgui.SliderInt("Support Tech 30+ H", _configuration.hud.sizing.TechSupport30H, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 69)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TechAttack15H = imgui.SliderInt("Attack Tech 15 H", _configuration.hud.sizing.TechAttack15H, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TechAttack20H = imgui.SliderInt("Attack Tech 20 H", _configuration.hud.sizing.TechAttack20H, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 69)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TechAttack30H = imgui.SliderInt("Attack Tech 29+ H", _configuration.hud.sizing.TechAttack30H, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end


                imgui.Text("Consumables")

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.MonomateH = imgui.SliderInt("Monomates H", _configuration.hud.sizing.MonomateH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 40)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.DimateH = imgui.SliderInt("Dimates H", _configuration.hud.sizing.DimateH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TrimateH = imgui.SliderInt("Trimates H", _configuration.hud.sizing.TrimateH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 52)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.MonofluidH = imgui.SliderInt("Monofluids H", _configuration.hud.sizing.MonofluidH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.DifluidH = imgui.SliderInt("Difluids H", _configuration.hud.sizing.DifluidH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 58)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TrifluidH = imgui.SliderInt("Trifluids H", _configuration.hud.sizing.TrifluidH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.SolAtomizerH = imgui.SliderInt("Sol Atomizers H", _configuration.hud.sizing.SolAtomizerH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 27)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.MoonAtomizerH = imgui.SliderInt("Moon Atomizers H", _configuration.hud.sizing.MoonAtomizerH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.StarAtomizerH = imgui.SliderInt("Star Atomizers H", _configuration.hud.sizing.StarAtomizerH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 20)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.AntidoteH = imgui.SliderInt("Antidotes H", _configuration.hud.sizing.AntidoteH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.AntiparalysisH = imgui.SliderInt("Antiparalysis H", _configuration.hud.sizing.AntiparalysisH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 29)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TelepipeH = imgui.SliderInt("Telepipes H", _configuration.hud.sizing.TelepipeH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TrapVisionH = imgui.SliderInt("Trap Visions H", _configuration.hud.sizing.TrapVisionH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 34)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.ScapeDollH = imgui.SliderInt("Scape Dolls H", _configuration.hud.sizing.ScapeDollH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.Text("Grinders/Materials")
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.MonogrinderH = imgui.SliderInt("Monogrinders H", _configuration.hud.sizing.MonogrinderH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 28)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.DigrinderH = imgui.SliderInt("Digrinders H", _configuration.hud.sizing.DigrinderH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.TrigrinderH = imgui.SliderInt("Trigrinders H", _configuration.hud.sizing.TrigrinderH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 40)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.HPMatH = imgui.SliderInt("HP Mat H", _configuration.hud.sizing.HPMatH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.PowerMatH = imgui.SliderInt("Power Mat H", _configuration.hud.sizing.PowerMatH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 43)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.LuckMatH = imgui.SliderInt("Luck Mat H", _configuration.hud.sizing.LuckMatH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.MindMatH = imgui.SliderInt("Mind Mat H", _configuration.hud.sizing.MindMatH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 50)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.DefenseMatH = imgui.SliderInt("Defense Mat H", _configuration.hud.sizing.DefenseMatH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.EvadeMatH = imgui.SliderInt("Evade Mat H", _configuration.hud.sizing.EvadeMatH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SameLine(0, 45)
                imgui.PushItemWidth(SWidth)
                success, _configuration.hud.sizing.ClairesDealH = imgui.SliderInt("Claire's Deal 5 Items H", _configuration.hud.sizing.ClairesDealH, 0, 100)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
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

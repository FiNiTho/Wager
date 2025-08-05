SMODS.current_mod.extra_tabs = function()
    local scale = 0.75
    return {
        label = "Credits",
        tab_definition_function = function()
            return {
                n = G.UIT.ROOT,
                config = {
                    align = "cm",
                    padding = 0.05,
                    colour = G.C.CLEAR,
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = {
                        padding = 0,
                        align = "cm"
                        },
                        nodes = {
                            {
                            n = G.UIT.T,
                            config = {
                            text = "Thanks to:",
                            shadow = true,
                            scale = scale * 0.8,
                            colour = G.C.UI.TEXT_LIGHT
                            }
                            }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = {
                        padding = 0,
                        align = "cm"
                        },
                        nodes = {
                            {
                            n = G.UIT.T,
                            config = {
                            text = "Creator: FiNiTho",
                            shadow = true,
                            scale = scale * 0.8,
                            colour = G.C.UI.TEXT_LIGHT
                            }
                            }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = {
                        padding = 0,
                        align = "cm"
                        },
                        nodes = {
                            {
                            n = G.UIT.T,
                            config = {
                            text = "Fixed typo's and playtesting: ivy___owo",
                            shadow = true,
                            scale = scale * 0.8,
                            colour = G.C.UI.TEXT_LIGHT
                            }
                            }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = {
                        padding = 0,
                        align = "cm"
                        },
                        nodes = {
                            {
                            n = G.UIT.T,
                            config = {
                            text = "Mental support: domi",
                            shadow = true,
                            scale = scale * 0.8,
                            colour = G.C.UI.TEXT_LIGHT
                            }
                            }
                        }
                    },
                    {
                    n = G.UIT.R,
                    config = {
                        padding = 0.2,
                        align = "cm",
                    },
                    nodes = {
                        UIBox_button({
                        minw = 3.85,
                        button = "wager_github",
                        label = {"Github"}
                        }),
                    },
                    },
                },
            }
        end
    }
end
function G.FUNCS.wager_github(e)
	love.system.openURL("https://github.com/FiNiTho/Wager")
end
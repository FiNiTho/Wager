local function create_clickable_joker(rarity, legendary)
    local card = create_card("Joker", G.jokers, legendary, rarity, nil, nil)

    -- Add a custom click handler
    card.click = function(self)
        -- print("Clicked card:", self)

        if G.OVERLAY_MENU then
            G.OVERLAY_MENU:remove()
            G.OVERLAY_MENU = nil
        end

        local t_card = copy_card(self)
        t_card:add_to_deck()
        G.jokers:emplace(t_card)
    end

    return card
end

function joker_menu(amount, rarity, legendary)
    local card_nodes = {}
    for i = 1, amount do
        table.insert(card_nodes, {n = G.UIT.O, config={object=create_clickable_joker(rarity, legendary)}})
    end

    return {
        n = G.UIT.ROOT,
        config = {r = 0.1, minw = 8, minh = 6, align = "cm", padding = 0.2, colour = HEX("2e3a3c"), outline = 1, outline_colour = HEX("1e2b2d") , shadow = true},
        nodes = {
            {n = G.UIT.C, config = {minw=4, minh=1, padding = 0.15, align = "cm"}, nodes = {
                {n = G.UIT.R, config = {minw=4, minh=1, padding = 0.15, align = "cm"}, nodes = {
                    {n = G.UIT.T, config={text = "Choose a joker", colour = G.C.UI.TEXT_LIGHT, scale = 0.7}},
                }},
                {n = G.UIT.R, config = {r = 0.1, align = "cm", padding = 0.2, colour = HEX("1e2b2d"), shadow = true}, nodes = {
                    {n = G.UIT.C, config = {minw=4, minh=3, padding = 0.15}, nodes = {
                        {n = G.UIT.C, config = {minw=4, minh=3, padding = 0.15}, nodes = card_nodes},
                    }},
                }},
            }},
        }
    }
end

menu_box = nil  -- global reference

function show_joker_menu(amount, rarity, legendary)
    legendary = legendary or false

    G.FUNCS.overlay_menu{
        definition = joker_menu(amount, rarity, legendary),
    }
end
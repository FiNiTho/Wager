local function create_clickable_joker(rarity, legendary)
    local card = create_card("Joker", G.jokers, legendary, rarity, nil, nil)

    -- Add a custom click handler
    card.click = function(self)
        -- print("Clicked card:", self)
        G.GAME.pool_flags.joker_menu = false

        if menu_box then
            menu_box:remove()
            menu_box = nil
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
        config = {r = 0.1, minw = 8, minh = 6, align = "cm", padding = 0.2, colour = G.C.BLACK, outline = 2, outline_colour = G.C.GRAY, shadow = true, juice = true},
        nodes = {
            {n = G.UIT.C, config = {minw=4, minh=1, padding = 0.15, align = "cm"}, nodes = {
                {n = G.UIT.R, config = {minw=4, minh=1, padding = 0.15, align = "cm"}, nodes = {
                    {n = G.UIT.T, config={text = "Choose a joker", colour = G.C.UI.TEXT_LIGHT, scale = 0.7}},
                }},
                {n = G.UIT.R, config = {minw=4, minh=3, padding = 0.15}, nodes = {
                    {n = G.UIT.C, config = {minw=4, minh=3, padding = 0.15}, nodes = card_nodes},
                }},
            }},
        }
    }
end

menu_box = nil  -- global reference

function show_joker_menu(amount, rarity, legendary)
    -- defaults to no legendary joker
    legendary = legendary or false

    G.GAME.pool_flags.joker_menu = true

    menu_box = UIBox({
        definition = joker_menu(amount, rarity, legendary),
        config = {type="cm"}
    })

    return {n=G.UIT.O, config={object = menu_box, instance_type = "ALERT"}}
end
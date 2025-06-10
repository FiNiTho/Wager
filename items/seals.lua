SMODS.Atlas {
    key = 'misc',
    path = 'misc.png',
    px = 71,
    py = 95
}
-- gamble seal/auburn seal
SMODS.Seal {
    key = 'auburnSeal',
    badge_colour = G.C.SET.gamble,
    loc_txt = {
        label = 'Auburn Seal',
        name = 'Auburn Seal',
        text = {
            "Creates a {C:gamble}Gamble{} card",
            "for final played {C:attention}poker hand{}",
            "of round if {C:attention}played{}",
            "{C:inactive}(Must have room){}"
        }
    },
    atlas = 'misc',

    calculate = function(self, card, context)
        -- Only act during final scoring hand
        if context.main_scoring and context.cardarea == G.play and context.full_hand then
            -- Make sure the card is part of the final hand
            for _, played_card in ipairs(context.full_hand) do
                if played_card == card and not card.gamble_seal_triggered then
                    card.gamble_seal_triggered = true  -- Prevent multiple triggers per round

                    -- Don't create card if inventory is full
                    if #G.consumeables.cards < G.consumeables.config.card_limit then
                        card_eval_status_text(card, "extra", nil, nil, nil, {
                            message = "Jackpot!",
                            colour = G.C.TAROT
                        })

                        G.E_MANAGER:add_event(Event({
                            trigger = "after",
                            delay = 0.2,
                            func = function()
                                local new_card = create_card("Gamble", G.consumeables, nil, nil, true, true, nil)
                                G.consumeables:emplace(new_card)
                                return true
                            end
                        }))
                    end
                    break
                end
            end
        end
    end
}


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
            "when played in first hand",
            "of round",
            "{C:inactive}(Must have room){}"
        }
    },
    atlas = 'misc',
    unlocked = true,
    discovered = true,

    calculate = function(self, card, context)
        if G.GAME.current_round.hands_played == 0 and context.main_scoring and context.cardarea == G.play then
            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                card_eval_status_text(card, "extra", nil, nil, nil, {
                    message = "+1 Gamble card",
                    colour = G.C.SET.gamble
                })

                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.2,
                    func = function()
                        SMODS.add_card({ set = 'Gamble' })
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                        return true
                    end
                }))
            end
        end
    end
}


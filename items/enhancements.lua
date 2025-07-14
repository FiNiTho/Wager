SMODS.Atlas {
    key = 'enhancements',
    path = 'enhancements.png',
    px = 70,
    py = 95
}

SMODS.Enhancement {
    key = 'stained',
    loc_txt = {
        name = 'Stained Card',
        text = {
            "{C:green}1 in 2{} chance for",
            "{X:mult,C:white}X1.5{} Mult, always scores",
        }
    },
    always_scores = true,
    atlas = 'enhancements',
    pos = { x = 0, y = 0 },

    config = { extra = { Xmult = 1.5, odds = 2 } },
     loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.Xmul,
                (G.GAME.probabilities.normal or 1),
                card.ability.extra.odds
            }
        }
    end,

    calculate = function(self, card, context)
        if not (context.main_scoring and context.cardarea == G.play) then
            return
        end

        if pseudorandom('stained') >= G.GAME.probabilities.normal / card.ability.extra.odds then
            return
        end

        return {
            x_mult = card.ability.extra.Xmult,
            card = card
        }
    end,
}
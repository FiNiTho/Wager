SMODS.Challenge({
    key = "faceDelight",
    name = "Face Delight",
    loc_txt = {
        name = "Face Delight",
        text = {
            "Deck contains only {C:attention}face cards{} (Kings, Queens, Jacks)",
            "{C:attention}3 Joker slots{}"
        }
    },
    rules = {
        custom = {},
        modifiers = {
            { id = "joker_slots", value = 3 },
            { id = "hand_size", value = 5 }
        }
    },
    deck = {
        type = "Challenge Deck",
        yes_ranks = { ["K"] = true, ["Q"] = true, ["J"] = true }
    },
    restrictions = {
        banned_cards = {},
        banned_tags = {}
    },
    unlocked = function(self)
        return true
    end
})
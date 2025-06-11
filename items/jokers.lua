

local jokers = {
    items = {}
}

-- Naruto Uzumaki Joker
jokers.items[#jokers.items + 1] = {
    object_type = "Joker",
    key = 'naruto_uzumaki',
    atlas = 'naruto_jokers',
    pos = {x = 0, y = 0},
    loc_txt = {
        name = 'Naruto Uzumaki',
        text = {
            'This joker gives {C:mult}+9 Mult{} for each',
            '{C:attention}9{} in your full deck',
            '{C:inactive}(Currently {C:mult}+#1# Mult{C:inactive})'
        }
    },
    config = { extra = {mult = 0, mult_mod = 9}},
    rarity = 2,
    cost = 6,
    -- Show current mult value in description
    loc_vars = function (self, info_queue, center)
        return {vars = {center.ability.extra.mult}}
    end,
    calculate = function (self, card, context)
        if context.joker_main then
            local count = 0
            for k, v in pairs(G.playing_cards) do
                if v:get_id() == 9 then
                    count = count + 1
                end
            end
            
            -- Update current mult
            card.ability.extra.mult = count * card.ability.extra.mult_mod
            
            -- Return mult bonus if any 9s exist
            if card.ability.extra.mult > 0 then
                return {
                    message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
                    mult_mod = card.ability.extra.mult
                }
            end
        end
    end,
}

-- Sasuke Uchiha Joker
jokers.items[#jokers.items + 1] = {
    object_type = "Joker",
    key = 'sasuke_uchiha',
    atlas = 'naruto_jokers',
    pos = {x = 1, y = 0},
    loc_txt = {
        name = 'Sasuke Uchiha',
        text = {
            '{C:attention}Spades{} and {C:attention}Clubs{}',
            'gain {C:chips}+#1# Chips{} when scored',
        }
    },
    config = {extra = {chips = 10}},
    rarity = 2,
    cost = 6,
    loc_vars = function (self, info_queue, center)
        return {vars = {center.ability.extra.chips}}
    end,
    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Spades') or context.other_card:is_suit('Clubs') then
                context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus or 0
                context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + card.ability.extra.chips
                
                return {
                    extra = { 
                        message = localize('k_upgrade_ex'), 
                        colour = G.C.CHIPS 
                    },
                    card = card
                }
            end
        end
    end
}

-- Kakashi Hatake Joker
jokers.items[#jokers.items + 1] = {
    object_type = "Joker",
    key = 'kakashi_hatake',
    atlas = 'naruto_jokers',
    pos = {x = 2, y = 0},
    loc_txt = {
        name = 'Kakashi Hatake',
        text = {
            'When you play a {C:attention}Flush{}',
            'create a {C:attention}Death{} Tarot card',
        }
    },
    config = {extra = {}},
    rarity = 3,
    cost = 8,
    calculate = function (self, card, context)
        if context.joker_main and context.scoring_name == 'Flush' then
            play_sound('kakashi_activate', 1.1, 0.8)
            
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.3,
                func = function()
                    local new_card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, 'c_death')
                    new_card:add_to_deck()
                    G.consumeables:emplace(new_card)
                    return true
                end
            }))
            
            return {
                message = 'Copy Ninja!',
                colour = G.C.PURPLE,
                card = card
            }
        end
    end
}

-- Example of how to add more jokers easily
-- Uncomment and modify as needed:
--[[
jokers.items[#jokers.items + 1] = {
    object_type = "Joker",
    key = 'sakura_haruno',
    atlas = 'naruto_jokers',
    pos = {x = 3, y = 0},
    loc_txt = {
        name = 'Sakura Haruno',
        text = {
            'Gives {C:mult}+#1# Mult{} for each',
            '{C:attention}Heart{} in played hand'
        }
    },
    config = {extra = {mult = 4}},
    rarity = 1,
    cost = 4,
    loc_vars = function (self, info_queue, center)
        return {vars = {center.ability.extra.mult}}
    end,
    calculate = function (self, card, context)
        if context.joker_main then
            local hearts = 0
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i]:is_suit('Hearts') then
                    hearts = hearts + 1
                end
            end
            if hearts > 0 then
                return {
                    message = localize{type='variable',key='a_mult',vars={hearts * card.ability.extra.mult}},
                    mult_mod = hearts * card.ability.extra.mult
                }
            end
        end
    end
}
--]]

-- Return the jokers table
return jokers
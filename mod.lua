--- STEAMODDED HEADER
--- MOD_NAME: Naruto Test Mod
--- MOD_ID: MyNinjaWay
--- MOD_AUTHOR: [elmakas666]
--- MOD_DESCRIPTION: A little project of my own to mod balatro using one of my favourite shows
--- DEPENDENCIES: [Steamodded>=1.0.0~BETA]
--- MOD_VERSION: 0.1
--- MOD_LICENSE: MIT

----------------------------------------------
------------------MOD CODE--------------------

---------- ATLAS ----------

SMODS.Atlas{
    key = 'naruto_jokers',
    path = 'naruto_jokers.png',
    px = 71,
    py = 95
}

---------- JOKERS ----------


SMODS.Joker{
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

SMODS.Joker{
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

SMODS.Joker{
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






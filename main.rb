# Your code here!
# Your code here!
module Result
    def self.all
        self.constants.map {|constant| eval("Result::#{constant}")}
    end
    NORMALS = {
        judge_proc: Proc.new{|cards| 
            cards.select{|card| card.has_type?(CardType::NORMAL)}.count >= 10
        },
        name: 'カス'
    }
    SEEDS = {
        judge_proc: Proc.new {|cards|
            cards.select { |card| card.has_type?(CardType::SEED)}.count >= 5
        },
        name: 'タネ'
    }
    STRIPS = {
        judge_proc: Proc.new {|cards|
            cards.select { |card| card.has_type?(CardType::STRIP)}.count >= 5
        },
        name: '短冊'
    }
    # BOAR_DEER_BUTTERFLY = '猪鹿蝶'
    # DRINK_WITH_MOOM = '月見で一杯'
    # DRINK_WITH_FLOWER = '花見で一杯'
    # LIGHT_THREE = '三光'
    # LIGHT_FOUR = '四光'
    # LOGHT_FIVE = '五光'
    # RED_STRIPS = '赤短'
    # BLUE_STRIPS = '青短'
end

module CardType
    NORMAL = 'カス'
    SEED = 'タネ'
    STRIP = '短冊'
    LIGHT = '光'
end

class Card
    
    def initialize(month, type)
        @month = month
        @type = type
    end
    
    def has_same_month?(card)
        card.has_month?(@month)
    end
    
    def has_type?(card_type)
        @type === card_type
    end
    
    def info
        "month:#{@month}, type:#{@type}"
    end
    
    protected
        def has_month?(month)
            @month == month
        end
    


end


#cardのリストを渡し、点数を判定する
class CulcPointService
    def self::judge_roles(cards)
        Result.all.select{|result| result[:judge_proc].call(cards)}.map{|result| result[:name]}
    end
end


class Deck
    def initialize
        @cards = [] 
        4.times do 
            @cards.push *Range.new(1,12).map{|i| Card.new(i, CardType::NORMAL)}
        end
    end
    
    def add_card(card)
        @cards << card
    end
    
    def get_card
        @cards.shift
    end
end

class Field
    def initialize
        @cards_hash = {
            1 => nil,
            2 => nil,
            3 => nil,
            4 => nil,
            5 => nil,
            6 => nil,
            7 => nil,
            8 => nil
        }
    end
    
    def add_card(card)
        empty_position = @cards_hash.detect{|key, value| value == nil}[0]
        @cards_hash[empty_position] = card 
    end
    
    def can_get?(card)
        !self.available_positions(card).empty? 
    end
    
    def available_positions(put_card)
        @cards_hash.select {|position, card| card&.has_same_month?(put_card)}.keys
    end
    
    def remove_card(put_card: nil, position: 0)
        raise RuntimeError.new("対象のカードと同月のカードはposition:#{position}にありません") unless self.can_get?(put_card)
        temp = @cards_hash[position]
        @cards_hash[position] = nil
        temp
    end
    
    def info
        @cards_hash.map {|key, value| "position:#{key} #{value&.info}"}
    end
        
end

class Hand
    def initialize
        @cards = []
    end
    
    def add_card(card)
        @cards << card
    end
    
    def remove_card(index)
        @cards.delete_at(index)
    end
    
    def info
        @cards.map {|card| card.info}
    end
end

class DrawUseCase
    def initialize(hand, deck)
        @hand = hand
        @deck = deck
    end
    
    def execute
        card = @deck.get_card
        @hand.add_card(card)
    end
end

class PutHandUseCase
    def initialize(hand, field)
        @hand = hand
        @field = field
    end
    
    def execute(hand_index:0, field_index:0)
        hand_card = @hand.remove_card(hand_index)
        field_card = @field.remove_card(put_card: hand_card, position: field_index)
        [hand_card, field_card]
    end
end

class DeckToFieldUseCase
    def initialize(deck, field)
        @deck = deck
        @field = field
    end
    
    def execute
        deck_card = @deck.get_card
        @field.add_card(deck_card)
    end
end

class DeckToFieldAfterRewardUseCase
    def initialize(deck, field)
        @deck = deck
        @field = field
    end
    
    def execute
        deck_card = @deck.get_card
        if @field.can_get?(deck_card) then
            position = @field.available_positions(deck_card)[0]
            @field.remove_card(put_card: deck_card, position: position)
        else
            @field.add_card(deck_card)
        end
    end
end

deck = Deck.new
field = Field.new
hand = Hand.new

draw = DrawUseCase.new(hand, deck)
deck_to_field = DeckToFieldUseCase.new(deck, field)
deck_to_field_after = DeckToFieldAfterRewardUseCase.new(deck,field)
put_hand = PutHandUseCase.new(hand, field) 

8.times do
    draw.execute
end

8.times do
    deck_to_field.execute
end

puts put_hand.execute(hand_index: 0, field_index: 5)
puts deck_to_field_after.execute
puts field.info

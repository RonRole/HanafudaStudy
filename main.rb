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
    
    def has_month?(month)
        @month === month
    end
    
    def has_type?(card_type)
        @type === card_type
    end
    
    def info
        "month:#{@month}, type:#{@type}"
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
        @cards = Range.new(1,10).map{|i| Card.new(i, CardType::STRIP)}
    end
    
    def add_card(card)
        @cards << card_dto
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
    
    def available_positions(target_month)
        @cards_hash.select {|position, card| card&.has_month?(target_month)}.keys
    end
    
    def remove_card(target_month:0, position:0)
        raise RuntimeError.new("target_month=#{target_month}のカードはposition:#{position}にありません") unless self.available_positions(target_month).include?(position)
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

deck = Deck.new
field = Field.new
hand = Hand.new

draw = DrawUseCase.new(hand, deck)

8.times do
    draw.execute
end










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
end


#cardのリストを渡し、点数を判定する
class CulcPointService
    def self::judge_roles(cards)
        Result.all.select{|result| result[:judge_proc].call(cards)}.map{|result| result[:name]}
    end
    
    private
        def self::filter_cards_with_type(cards, card_type)
            cards.select{|card| card.has_type?(card_type)}
        end
end


hand = []
4.times do |i|
    hand.push Card.new(i, CardType::STRIP)
    hand.push Card.new(i, CardType::SEED)
end

puts CulcPointService.judge_roles(hand)

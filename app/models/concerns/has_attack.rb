module HasAttack
  extend ActiveSupport::Concern
  included do
    validates_presence_of :attack
    validates_numericality_of :attack

    scope :is_attacking, -> { where(status: %i[attack_ready second_attack_ready]) }

    def can_attack?(defender)
      status_attack_ready? && !defender.taunt_protection?
    end

    def taunt_protection?
      taunts = taunting_cards
      taunts.present? && taunts.exclude?(self)
    end

    def increment_attack(amount = 1)
      increment!(:attack, amount)
    end

    def decrement_attack(amount = 1)
      decrement!(:attack, amount)
    end

    def attack_enemy(enemy)
      enemy.take_damage(attack)
      take_damage(enemy.attack)
      status_sleeping! #=> Needs to have a player/card split in their respective classes
    end

    private

    def taunting_cards
      player.taunting_cards
    end
  end
end

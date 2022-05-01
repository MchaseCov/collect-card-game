module HasHealth
  extend ActiveSupport::Concern

  included do
    validates_presence_of :health_cap, :health
    validates_numericality_of :health_cap
    validates :health, numericality: { less_than_or_equal_to: :health_cap }

    # Increments or decrements integer columns of the reciever.
    #
    # amount  - The amount to in/decrement by. Defaults to 1 if no input.
    # Examples
    #   card.decrement_health(5)
    #   # =>  UPDATE "cards" SET "health" = COALESCE("attack", 0) - 5 ...
    #
    # Returns true if SQL transaction is successful.
    %i[health_cap health].each do |attribute|
      define_method "increment_#{attribute}".to_sym do |amount = 1|
        increment!(attribute, amount)
      end
      define_method "decrement_#{attribute}".to_sym do |amount = 1|
        decrement!(attribute, amount)
      end
    end
    # take_damage: Decrements the health attribute of a Card by the amount supplied.
    # If the health attribute is now less than 0, the card is moved to the graveyard.
    #
    # attack  - The Integer of the recieved attack to decrease the health attribute by.
    def take_damage(attack)
      decrement_health(attack)
      die if health <= 0
    end

    # increase_health_cap: Increase the health cap of a Card by the amount supplied.
    # This also increases the current health of the Card.
    #
    # amount  -  The Integer amount to increase the health attribute value.
    def increase_health_cap(amount)
      increment_health_cap(amount) and increment_health(amount)
    end

    # decrease_health_cap: Decrease the health cap of a Card by the amount supplied.
    # If the current health of the card would be higher the cap, lower it to match the cap.
    #
    # amount  -  The Integer amount to decrease the health attribute value.
    def decrease_health_cap(amount)
      self.health_cap -= amount
      self.health = self.health_cap if health > self.health_cap
      save
    end

    private

    def take_empty_deck_fatigue
      update_column(:health_current, (health_current / 2))

      die if health <= 0
    end
  end
end

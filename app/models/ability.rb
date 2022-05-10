# t.string "action"
# t.integer "modifier"
# t.string "body_text"
class Ability < ApplicationRecord
  include GenericKeywordActions
  include SpecifiedKeywordActions

  def player_input?
    random.zero?
  end

  def trigger(targets)
    @targets = targets
    method(action).call
  end
end

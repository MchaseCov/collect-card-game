# t.string "action"
# t.integer "modifier"
# t.string "body_text"
class Ability < ApplicationRecord
  include GenericKeywordActions
  include SpecifiedKeywordActions

  has_and_belongs_to_many :buffs

  validates_uniqueness_of :body_text

  def buff
    buffs.first
  end

  def player_input?
    random.zero?
  end

  def trigger(targets)
    @targets = targets
    method(action).call
  end
end

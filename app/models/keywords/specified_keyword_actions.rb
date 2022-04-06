# Specified Keyword Actions are for actions with specific and niche scoping.
# These actions are too specific to be repeated often and are usually a "one time use".
# These methods are named after the Card Constant that the keyword belongs to
module SpecifiedKeywordActions
  def highlands_hyena
    @targets.where.not(id: @invoking_card.id).where('health <= 2').update_all(location: 'graveyard', status: 'dead')
    player_of_card.correct_all_positioning
    opposing_player_of_card.correct_all_positioning
  end
end

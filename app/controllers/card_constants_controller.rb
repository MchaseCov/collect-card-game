class CardConstantsController < ApplicationController
  def index
    constants = CardConstant.select(CardConstant.attribute_names - %w[created_at updated_at summoner_id]).all
    render json: constants
  end
end

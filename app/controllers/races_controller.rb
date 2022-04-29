class RacesController < ApplicationController
  def index
    races = Race.select(Race.attribute_names - %w[created_at updated_at health_modifier cost_modifier
                                                  resource_modifier]).all
    render json: races
  end
end

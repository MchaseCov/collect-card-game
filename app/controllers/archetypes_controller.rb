class ArchetypesController < ApplicationController
  def index
    archs = Archetype.select(Archetype.attribute_names - %w[created_at updated_at summoner_id]).all
    render json: archs
  end
end

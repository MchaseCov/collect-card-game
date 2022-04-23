class KeywordsController < ApplicationController
  def index
    keywords = Keyword.select(Keyword.attribute_names - %w[created_at updated_at listening_condition action
                                                           target]).all.map(&:attributes)
    render json: keywords
  end
end

class HomeController < ApplicationController
  def index
    @game = Game.last
  end
end

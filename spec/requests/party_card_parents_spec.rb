require 'rails_helper'

RSpec.describe "PartyCardParents", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/party_card_parents/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/party_card_parents/show"
      expect(response).to have_http_status(:success)
    end
  end

end

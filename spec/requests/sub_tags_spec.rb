require 'rails_helper'

RSpec.describe "SubTags", type: :request do
  describe "GET /sub_tags" do
    it "works! (now write some real specs)" do
      get sub_tags_path
      expect(response).to have_http_status(200)
    end
  end
end

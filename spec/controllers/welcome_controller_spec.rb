require 'spec_helper'

describe WelcomeController do
  render_views
  let(:page) { Capybara::Node::Simple.new(@response.body) }

  it "should use WelcomeController" do
    controller.should be_an_instance_of(WelcomeController)
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

end

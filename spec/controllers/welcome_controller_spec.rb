require 'spec_helper'

describe WelcomeController do
  render_views
  let(:page) { Capybara::Node::Simple.new(@response.body) }

  it "should use WelcomeController" do
    controller.should be_an_instance_of(WelcomeController)
  end

  describe "GET 'index'" do
    it "should be successful" do
      get :index
      response.should be_success
    end
    it "should not show 'authorized only' message for guest users" do
      get :index
      response.body.should have_selector("h2", :text => /Welcome/)
      response.body.should have_selector("p", :text => "You need authorization")
      response.body.should_not have_selector("p", :text => "You are authorized")
    end
    it "should show 'authorized content' for logged in users" do
      login_as("user")
      get :index
      response.body.should have_selector("h2", :text => /Welcome/)
      response.body.should have_selector("p", :text => "You are authorized")
      response.body.should_not have_selector("p", :text => "You need authorization")
    end
  end

end

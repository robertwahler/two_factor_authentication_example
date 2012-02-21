require 'spec_helper'

describe UserSessionsController do
  render_views
  let(:page) { Capybara::Node::Simple.new(@response.body) }

  describe "actions requiring no current user" do
    it "should not redirect for a non-logged in user on :new" do
      get :new
      response.should_not be_redirect
    end

    it "should not redirect for a non-logged in user on :create" do
      get :create
      response.should_not be_redirect
    end

    it "should redirect for a logged in user on :new" do
      login_as(:user)
      get :new
      response.should be_redirect
    end

    it "should redirect for a logged in user on :create" do
      login_as(:user)
      get :create
      response.should be_redirect
    end
  end

  describe "actions requiring a current user" do
    it "should redirect to login on :destroy" do
      get :destroy
      response.should redirect_to(login_path)
    end
  end

  describe "session management" do
    context "without two factor authentication" do

      before :each do
        controller.stub!(:two_factor_required?).and_return(false)
      end

      it "should redirect to the root page on successful login" do
        user = find_or_create_user("user")
        post :create, :user_session => { :login => 'user', :password => 'user' }
        user_session = UserSession.find
        user_session.should_not be_nil
        user_session.record.should == user
        response.should redirect_to('/')
      end

      it "should redirect to the login page on session deletion" do
        login_as(:user)
        post :destroy
        response.should redirect_to(login_path)
      end
    end

    context "with two factor authentication" do

      before :each do
        controller.stub!(:two_factor_required?).and_return(true)
      end

      it "should redirect to the confirmation page on successful login" do
        user = find_or_create_user("user")
        post :create, :user_session => { :login => 'user', :password => 'user' }
        user_session = UserSession.find
        user_session.should_not be_nil
        user_session.record.should == user
        response.should redirect_to(confirm_url)
      end
    end

  end


end

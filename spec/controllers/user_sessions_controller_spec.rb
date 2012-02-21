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
    context "login from approved IP addresses without two factor authentication" do

      before :each do
        controller.stub!(:two_factor_excluded_ip_addresses).and_return([IPAddress.parse("127.0.0.1/24")])
        request.stub!(:ip).and_return('127.0.0.2')
      end

      it "should redirect to the root page on successful login" do
        user = find_or_create_user("user")
        post :create, :user_session => { :login => 'user', :password => 'user' }
        user_session = UserSession.find
        user_session.should_not be_nil
        user_session.record.should == user
        response.should redirect_to('/')
        flash[:notice].should match(/Login successful!/)
      end

      it "should redirect to the login page on session deletion" do
        login_as(:user)
        post :destroy
        response.should redirect_to(login_path)
        flash[:notice].should match(/Logout successful!/)
      end
    end

    context "login from non approved IP addresses with two factor authentication" do

      before :each do
        controller.stub!(:two_factor_excluded_ip_addresses).and_return([IPAddress.parse("127.0.0.1/24")])
        request.stub!(:ip).and_return('127.0.2.1')
      end

      it "should redirect to the confirmation page on successful login" do
        user = find_or_create_user("user")
        post :create, :user_session => { :login => 'user', :password => 'user' }
        user_session = UserSession.find
        user_session.should_not be_nil
        user_session.record.should == user
        response.should redirect_to(confirm_url)
        flash[:notice].should match(/Login successful, security token required/)
      end

      context "with a valid token" do

        it "should redirect from confirmation page to the root page" do
          user = find_or_create_user("user")
          login_as(user.login, :two_factor_confirm => false)
          validation_code = ROTP::TOTP.new(user.two_factor_secret).now.to_s
          post :validate, :user_session => { :validation_code => validation_code }
          response.should redirect_to('/')
          flash[:notice].should match(/Your session is now validated/)
        end
      end

      context "with an invalid token" do

        it "should redirect back to the confirmation page" do
          user = find_or_create_user("user")
          login_as(user.login, :two_factor_confirm => false)
          validation_code = 'GARBAGE'
          put :validate, :user_session => { :validation_code => validation_code }
          response.should redirect_to(confirm_url)
          flash[:error].should match(/Token invalid!/)
        end

        it "should should lock out the user with 5 failed attempts" do
          pending
        end

      end

    end
  end

end

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

    context "login from any IP addresses when two factor authentication is disabled with quad-zero netmask" do

      before :each do
        controller.stub!(:two_factor_excluded_ip_addresses).and_return([IPAddress.parse("0.0.0.0/0")])
        request.stub!(:ip).and_return('200.1.1.10')
      end

      it "should redirect to the requested page on successful login" do
        session[:return_to] = '/users'
        user = find_or_create_user("user")
        post :create, :user_session => { :login => 'user', :password => 'user' }
        user_session = UserSession.find
        user_session.should_not be_nil
        user_session.record.should == user
        response.should redirect_to('/users')
        flash[:notice].should match(/Login successful!/)
      end

    end

    context "login from approved IP addresses without two factor authentication" do

      before :each do
        controller.stub!(:two_factor_excluded_ip_addresses).and_return([IPAddress.parse("127.0.0.1/24")])
        request.stub!(:ip).and_return('127.0.0.2')
      end

      it "should redirect to the requested page on successful login" do
        session[:return_to] = '/users'
        user = find_or_create_user("user")
        post :create, :user_session => { :login => 'user', :password => 'user' }
        user_session = UserSession.find
        user_session.should_not be_nil
        user_session.record.should == user
        response.should redirect_to('/users')
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

      it "should not change the two_factor_failure_count on successful login" do
        user = find_or_create_user("user")
        user.two_factor_failure_count = 6
        user.save!
        post :create, :user_session => { :login => 'user', :password => 'user' }
        user_session = UserSession.find
        user_session.should_not be_nil
        user_session.record.should == user
        response.should redirect_to(confirm_url)
        flash[:notice].should match(/Login successful, security token required/)
        user.reload
        user.two_factor_failure_count.should == 6
      end

      context "without a two_factor_secret" do

        it "should logout the user and redirect back to the login page" do
          user = find_or_create_user("user")
          user.two_factor_secret = nil
          user.save!
          login_as(user.login, :two_factor_confirm => false)
          validation_code = 'ANYTHING'
          post :validate, :user_session => { :validation_code => validation_code }
          user_session = UserSession.find
          user_session.should be_nil
          session[:two_factor_confirmed_at].should be_nil
          response.should redirect_to(login_url)
          flash[:error].should match(/Two factor authentication is not setup on your account/)
        end
      end


      context "with a valid token" do

        it "should redirect from confirmation page to the requested page" do
          session[:return_to] = '/users'
          user = find_or_create_user("user")
          login_as(user.login, :two_factor_confirm => false)
          validation_code = ROTP::TOTP.new(user.two_factor_secret).now.to_s
          post :validate, :user_session => { :validation_code => validation_code }
          response.should redirect_to('/users')
          flash[:notice].should match(/Your session has been confirmed/)
          session[:two_factor_confirmed_at].should_not be_nil
        end

        it "should reset the two_factor_failure_count" do
          user = find_or_create_user("user")
          user.two_factor_failure_count = 3
          user.save!
          user.reload
          user.two_factor_failure_count.should == 3
          login_as(user.login, :two_factor_confirm => false)
          validation_code = ROTP::TOTP.new(user.two_factor_secret).now.to_s
          post :validate, :user_session => { :validation_code => validation_code }
          user.reload
          user.two_factor_failure_count.should == 0
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
          session[:two_factor_confirmed_at].should be_nil
        end

        it "should increment the two_factor_failure_count" do
          user = find_or_create_user("user")
          user.two_factor_failure_count = 3
          user.save!
          login_as(user.login, :two_factor_confirm => false)
          validation_code = 'GARBAGE'
          put :validate, :user_session => { :validation_code => validation_code }
          user.reload
          user.two_factor_failure_count.should == 4
        end

        it "should should lock out confirmation with 5 failed attempts" do
          user = find_or_create_user("user")
          user.two_factor_failure_count = 5
          user.save!
          login_as(user.login, :two_factor_confirm => false)
          validation_code = 'GARBAGE'
          put :validate, :user_session => { :validation_code => validation_code }
          user_session = UserSession.find
          user_session.should be_nil
          response.should redirect_to('/')
          flash[:error].should match(/ confirmation failure count exceeded/)
          session[:two_factor_confirmed_at].should be_nil
        end
      end

    end
  end

end

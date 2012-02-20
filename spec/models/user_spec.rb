require 'spec_helper'

describe User do

  def valid_attributes
    {
      :login  => 'someone',
      :email  => 'someone@example.com',
      :first_name  => 'someone',
      :last_name => 'new',
      :password => 'test',
      :password_confirmation => 'test'
    }
  end

  describe "validations" do

    before(:each) do
      @user = Factory.create(:user)
    end

    it { should validate_uniqueness_of(:login) }
    it { should ensure_length_of(:password).is_at_least(4) }
  end

 describe "being created" do
  it "should create a two_factor_secret automatically" do
    user = User.new valid_attributes
    user.two_factor_secret.should be_nil
    user.should be_valid
    user.save!
    user.two_factor_secret.should_not be_nil
  end
 end


end

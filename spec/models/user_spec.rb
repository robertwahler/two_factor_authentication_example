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
   it "should set two_factor_failure_count to zero" do
     user = User.new valid_attributes
     user.two_factor_secret.should be_nil
     user.should be_valid
     user.two_factor_failure_count.should == 0
   end
 end

 describe "reset_two_factor_failure_count!" do

   it "should set two_factor_failure_count to zero and save the record" do
     user = User.new valid_attributes
     user.two_factor_failure_count = 5
     user.should be_changed
     user.save!
     user.two_factor_failure_count.should == 5
     user.should_not be_changed
     user.reset_two_factor_failure_count!
     user.two_factor_failure_count.should == 0
     user.should_not be_changed
   end
 end

 describe "increment_two_factor_failure_count!" do

   it "should increment two_factor_failure_count by 1 and save the record" do
     user = User.new valid_attributes
     user.two_factor_failure_count = 5
     user.save!
     user.increment_two_factor_failure_count!
     user.two_factor_failure_count.should == 6
     user.should_not be_changed
   end
 end

 describe "confirm_two_factor!" do

   it "should update two_factor_confirmed_at with a time based UUID" do
     user = User.create valid_attributes
     user.should_not be_changed
     user.two_factor_confirmed_at.should be_nil
     user.confirm_two_factor!
     user.should_not be_changed
     UUIDTools::UUID.parse(user.two_factor_confirmed_at).should_not be_nil_uuid
   end

   it "should reset two_factor_failure_count" do
     user = User.new valid_attributes
     user.two_factor_failure_count = 5
     user.save!
     user.two_factor_failure_count.should == 5
     user.confirm_two_factor!
     user.two_factor_failure_count.should == 0
     user.should_not be_changed
   end
 end

 describe "two_factor_confirmed_at_valid_for" do

   it "should return Fixnum duration in seconds" do
     user = User.create valid_attributes
     user.two_factor_confirmed_at_valid_for.is_a?(Fixnum).should be_true
   end
 end

 describe "two_factor_confirmed_at_valid?" do

   it "should not be valid if nil" do
     user = User.create valid_attributes
     user.two_factor_confirmed_at.should be_nil
     user.two_factor_confirmed_at_valid?.should be_false
     user.confirm_two_factor!
     user.two_factor_confirmed_at_valid?.should be_true
   end

   it "should not be valid if garbage" do
     user = User.create valid_attributes
     user.two_factor_confirmed_at = "12abc"
     user.save!
     user.two_factor_confirmed_at_valid?.should be_false
   end

   it "should not be valid if expired" do
     User.any_instance.stub(:two_factor_confirmed_at_valid_for).and_return(1.hour)
     user = User.create valid_attributes
     user.confirm_two_factor!
     user.two_factor_confirmed_at_valid?.should be_true
     Timecop.travel Time.now + 1.hour + 1.second
     user.two_factor_confirmed_at_valid?.should be_false
     Timecop.return
   end
 end


end

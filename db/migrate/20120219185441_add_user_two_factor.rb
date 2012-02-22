class AddUserTwoFactorSecret < ActiveRecord::Migration

  def change
     add_column :users, :two_factor_secret, :string
     add_column :users, :two_factor_failure_count, :integer, :null => false, :default => 0
  end

end

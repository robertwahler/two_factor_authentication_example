class AddUserTwoFactorSecret < ActiveRecord::Migration

  def change
     add_column :users, :two_factor_secret, :string
  end

end

class AddSaltToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :salt, :string
	rename_column :teams, :password, :encrypted_password
  end
end

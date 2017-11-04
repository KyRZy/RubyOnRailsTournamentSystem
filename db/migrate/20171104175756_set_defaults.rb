class SetDefaults < ActiveRecord::Migration[5.0]
  def self.up
    change_column :tournaments, :finished, :boolean, :default => false
	change_column :matches, :finished, :boolean, :default => false
	
	change_column :matches, :stage, :integer, :presence => true
	
	change_column :users, :team_id, :integer, :null => true
	change_column :matches, :participant_a_id, :integer, :null => true
	change_column :matches, :participant_b_id, :integer, :null => true
	change_column :matches, :participant_a_score, :integer, :null => true
	change_column :matches, :participant_b_score, :integer, :null => true 
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't remove the default"
  end
end

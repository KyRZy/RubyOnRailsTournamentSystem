class SetMatchScoreDefaults < ActiveRecord::Migration[5.0]
  def self.up
	change_column :matches, :participant_a_score, :integer, :default => 0
	change_column :matches, :participant_b_score, :integer, :default => 0
  end
  
  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't remove the default"
  end
end

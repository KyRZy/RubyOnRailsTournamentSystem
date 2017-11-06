class SetDefaultValueToSeedInParticipants < ActiveRecord::Migration[5.0]
  def self.up
	change_column :participants, :seed, :integer, :default => 0
  end
  
  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't remove the default"
  end
end

class ChangeLosesNameToLosses < ActiveRecord::Migration[5.0]
  def self.up
    rename_column :participants, :loses, :losses
  end

  def self.down
    # rename back if you need or do something else or do nothing
  end
end

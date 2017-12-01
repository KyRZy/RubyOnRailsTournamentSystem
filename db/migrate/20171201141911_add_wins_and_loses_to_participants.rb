class AddWinsAndLosesToParticipants < ActiveRecord::Migration[5.0]
  def change
    add_column :participants, :wins, :integer, :default => 0
    add_column :participants, :loses, :integer, :default => 0
  end
end

class AddMaxParticipantsToTournaments < ActiveRecord::Migration[5.0]
  def change
    add_column :tournaments, :max_participants, :integer
  end
end

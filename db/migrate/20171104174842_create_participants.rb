class CreateParticipants < ActiveRecord::Migration[5.0]
  def change
    create_table :participants do |t|
      t.references :tournament, foreign_key: true
      t.references :team, foreign_key: true
      t.integer :seed

      t.timestamps
    end
  end
end

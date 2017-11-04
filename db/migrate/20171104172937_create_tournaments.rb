class CreateTournaments < ActiveRecord::Migration[5.0]
  def change
    create_table :tournaments do |t|
      t.integer :user_id
      t.string :name
      t.integer :tournament_type_id
      t.datetime :start_date
      t.boolean :finished

      t.timestamps
    end
  end
end

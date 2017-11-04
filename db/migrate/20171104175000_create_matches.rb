class CreateMatches < ActiveRecord::Migration[5.0]
  def change
    create_table :matches do |t|
      t.integer :participant_a_id
      t.integer :participant_b_id
      t.integer :participant_a_score
      t.integer :participant_b_score
      t.integer :stage
      t.boolean :finished

      t.timestamps
    end
  end
end

class CreateTraitScores < ActiveRecord::Migration[5.2]
  def change
    create_table :trait_scores do |t|
      t.integer :score
      t.references :trait, foreign_key: true
      t.references :applicant, foreign_key: true

      t.timestamps
    end
  end
end

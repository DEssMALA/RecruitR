class CreatePositions < ActiveRecord::Migration[5.2]
  def change
    create_table :positions do |t|
      t.string :title
      t.text :description
      t.boolean :active

      t.timestamps
    end
  end
end

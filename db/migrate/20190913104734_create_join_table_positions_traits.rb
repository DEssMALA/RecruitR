class CreateJoinTablePositionsTraits < ActiveRecord::Migration[5.2]
  def change
    create_join_table :positions, :traits do |t|
      # t.index [:position_id, :trait_id]
      # t.index [:trait_id, :position_id]
    end
  end
end

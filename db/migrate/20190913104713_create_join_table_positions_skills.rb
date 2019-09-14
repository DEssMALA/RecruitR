class CreateJoinTablePositionsSkills < ActiveRecord::Migration[5.2]
  def change
    create_join_table :positions, :skills do |t|
      # t.index [:position_id, :skill_id]
      # t.index [:skill_id, :position_id]
    end
  end
end

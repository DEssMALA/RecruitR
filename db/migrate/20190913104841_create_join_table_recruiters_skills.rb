class CreateJoinTableRecruitersSkills < ActiveRecord::Migration[5.2]
  def change
    create_join_table :recruiters, :skills do |t|
      # t.index [:recruiter_id, :skill_id]
      # t.index [:skill_id, :recruiter_id]
    end
  end
end

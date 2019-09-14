class CreateJoinTableApplicantsSkills < ActiveRecord::Migration[5.2]
  def change
    create_join_table :applicants, :skills do |t|
      # t.index [:applicant_id, :skill_id]
      # t.index [:skill_id, :applicant_id]
    end
  end
end

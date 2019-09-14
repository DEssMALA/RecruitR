class AddRecruiterIdToApplicants < ActiveRecord::Migration[5.2]
  def change
    add_column :applicants, :recruiter_id, :integer
    add_index  :applicants, :recruiter_id
  end
end

class AddMeetingToApplicants < ActiveRecord::Migration[5.2]
  def change
    add_column :applicants, :meeting, :datetime
  end
end

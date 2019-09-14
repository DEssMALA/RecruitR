class AddPositionIdToApplicants < ActiveRecord::Migration[5.2]
  def change
    add_column :applicants, :position_id, :integer
    add_index  :applicants, :position_id
  end
end

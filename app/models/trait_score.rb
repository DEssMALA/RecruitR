class TraitScore < ApplicationRecord
  belongs_to :trait
  belongs_to :applicant
end

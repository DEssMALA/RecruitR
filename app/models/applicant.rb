class Applicant < ApplicationRecord
    has_and_belongs_to_many :skills
    belongs_to :position
    belongs_to :recruiter
    has_many :trait_scores
    has_many :traits, through: :trait_scores
end

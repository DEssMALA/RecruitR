class Recruiter < ApplicationRecord
    has_and_belongs_to_many :skills
    has_many: applicants
end

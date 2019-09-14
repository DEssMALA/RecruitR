class Skill < ApplicationRecord
    has_and_belongs_to_many :positions
    has_and_belongs_to_many :recruiters
    has_and_belongs_to_many :applicants

    validates :name, uniqueness: true
    
end

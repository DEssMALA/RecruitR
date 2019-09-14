class Position < ApplicationRecord
    # Relation
    has_and_belongs_to_many :skills
    has_and_belongs_to_many :traits
    has_many :applicants

    # Validations
    validates :title, presence: true, length: { minimum: 5 }
    validates :description, presence: true, length: {minimum: 15}
    validates :title, uniqueness: { case_sensitive: false }
end

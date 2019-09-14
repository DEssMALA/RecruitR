class Trait < ApplicationRecord
    has_and_belongs_to_many :positions
    has_many :trait_scores
    has_many :applicants, through: :trait_scores

    validates :name, uniqueness: true
end

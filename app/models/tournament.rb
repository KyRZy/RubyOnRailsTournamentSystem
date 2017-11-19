class Tournament < ApplicationRecord
    belongs_to :tournament_type
    has_many :participants
    has_many :matches, through: :participants, :source => 'home_matches'
    
    belongs_to :user, optional: true
end

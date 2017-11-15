class Tournament < ApplicationRecord
    belongs_to :tournament_type
    has_many :participants
    
    belongs_to :user, optional: true
end

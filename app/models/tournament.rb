class Tournament < ApplicationRecord
    has_one :tournament_type
    
    belongs_to :user, optional: true
end

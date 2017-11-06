class Tournament < ApplicationRecord
    has_one :tournament_type, class_name: "TournamentType", foreign_key: "id"
    has_many :participants
    
    belongs_to :user, optional: true
end

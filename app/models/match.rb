class Match < ApplicationRecord
    belongs_to :participant_a, :class_name => 'Participant'
    belongs_to :participant_b, :class_name => 'Participant'
    
    validates :participant_a_score, presence: true, numericality: { greater_than_or_equal_to: 0 }
	validates :participant_b_score, presence: true, numericality: { greater_than_or_equal_to: 0 }

    def teams
        [self.participant_a, self.participant_b]
    end
end

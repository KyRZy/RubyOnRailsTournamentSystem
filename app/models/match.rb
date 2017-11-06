class Match < ApplicationRecord
    belongs_to :participant_a, :class_name => 'Team'
	belongs_to :participant_b, :class_name => 'Team'
end

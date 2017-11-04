class Match < ApplicationRecord
    belongs_to :participant_a, :class_name => 'Team' , :foreign_key => "participant_a_id"
	belongs_to :participant_b, :class_name => 'Team' , :foreign_key => "participant_b_id"
end

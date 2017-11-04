class Team < ApplicationRecord
    has_one :leader, :class_name => 'User' , :foreign_key => "leader_id"

    belongs_to :user
end

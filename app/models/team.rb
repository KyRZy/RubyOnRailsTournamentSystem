require 'bcrypt'

class Team < ApplicationRecord
    has_one :leader, :class_name => 'User'

    belongs_to :user, :class_name => 'User', optional: true
end

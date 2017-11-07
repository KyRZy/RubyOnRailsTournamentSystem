class Team < ApplicationRecord
    has_one :leader, :class_name => 'User'
    has_many :users, :class_name => 'User'
    has_many :participants, :class_name => 'Participant'

    belongs_to :participant, :class_name => 'Participant'
    belongs_to :user, :class_name => 'User', optional: true

    validates_uniqueness_of :name, :case_sensitive => false
end

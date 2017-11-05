class Team < ApplicationRecord
    has_one :leader, :class_name => 'User'

    belongs_to :user, :class_name => 'User', optional: true
    has_many :users, :class_name => 'User'

    validates :name, uniqueness: true
end

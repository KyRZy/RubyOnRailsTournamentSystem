class Participant < ApplicationRecord
  belongs_to :tournament
  belongs_to :team

  has_many :matches
end

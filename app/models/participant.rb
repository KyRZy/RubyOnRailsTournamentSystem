class Participant < ApplicationRecord
  belongs_to :tournament
  belongs_to :team

  has_many :home_matches, class_name: "Match", foreign_key: "participant_a_id"
  has_many :away_matches, class_name: "Match", foreign_key: "participant_b_id"

  def matches
    self.home_matches + self.away_matches
  end
end

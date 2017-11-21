class Tournament < ApplicationRecord
    belongs_to :tournament_type
    has_many :participants
    has_many :home_matches, through: :participants, :source => 'home_matches'
    has_many :away_matches, through: :participants, :source => 'away_matches'
   
    belongs_to :user, optional: true

    def matches
        # explained in 3rd point in "Obstacles during implementation" of about page
        Match.find_by_sql('SELECT DISTINCT m.* FROM matches m, participants p, tournaments t WHERE  t.id = p.tournament_id and (p.id = m.participant_a_id or p.id = m.participant_b_id)')
    end
end

json.extract! participant, :id, :tournament_id, :team_id, :seed, :created_at, :updated_at
json.url participant_url(participant, format: :json)

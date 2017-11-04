json.extract! team, :id, :name, :password, :leader_id, :created_at, :updated_at
json.url team_url(team, format: :json)

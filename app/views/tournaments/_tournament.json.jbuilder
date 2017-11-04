json.extract! tournament, :id, :user_id, :name, :tournament_type_id, :start_date, :finished, :created_at, :updated_at
json.url tournament_url(tournament, format: :json)

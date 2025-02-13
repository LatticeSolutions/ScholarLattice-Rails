json.extract! event, :id, :title, :description, :location, :starts_at, :ends_at, :collection_id, :created_at, :updated_at
json.url event_url(event, format: :json)

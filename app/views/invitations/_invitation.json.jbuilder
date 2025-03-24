json.extract! invitation, :id, :profile_id, :collection_id, :status, :created_at, :updated_at
json.url invitation_url(invitation, format: :json)

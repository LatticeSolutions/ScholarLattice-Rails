json.extract! submission, :id, :title, :abstract, :notes, :profile_id, :collection_id, :created_at, :updated_at
json.url submission_url(submission, format: :json)

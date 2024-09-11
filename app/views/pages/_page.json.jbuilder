json.extract! page, :id, :title, :content, :collection_id, :created_at, :updated_at
json.url page_url(page, format: :json)

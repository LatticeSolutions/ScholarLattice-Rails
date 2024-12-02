class Page < ApplicationRecord
  belongs_to :collection
  validates_uniqueness_of :is_home, if: :is_home, scope: :collection_id
  before_validation :enforce_single_homepage

  def content_html
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render content
  end

  private

    def enforce_single_homepage
      if is_home
        collection.pages.where.not(id: id).update(is_home: false)
        collection.pages.where(title: "Home Page").update(title: "Former Home Page")
        self.title = "Home Page"
      end
    end
end

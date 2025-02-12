class Page < ApplicationRecord
  belongs_to :collection
  validates_uniqueness_of :is_home, if: :is_home, scope: :collection_id
  before_validation :enforce_single_homepage
  enum :visibility, { private: 0, unlisted: 1, public: 2 }, suffix: true
  validate :home_page_must_be_public

  def content_html
    Kramdown::Document.new(content).to_html
  end

  def has_admin?(user)
    collection.present? && collection.has_admin?(user)
  end

  private

    def enforce_single_homepage
      if is_home
        collection.pages.where.not(id: id).where(is_home: true).update(
          is_home: false,
          title: "Former Home Page",
        )
        self.title = "Home Page"
      end
    end

    def home_page_must_be_public
      if is_home && !public_visibility?
        errors.add(:visibility, "must be public for a home page")
      end
    end
end

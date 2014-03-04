class Page

  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  field :body, type: String
  field :show_comments, type: Boolean, default: false

  slug :name

  validates :name, :body, presence: true

  belongs_to :page_category
  has_and_belongs_to_many :attachments

  def core?
    ['About', 'Events'].include?(name)
  end

end
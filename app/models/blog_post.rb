class BlogPost

  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  include Mongoid::Slug

  field :name, type: String
  field :publish_at, type: Date
  field :body, type: String

  scope :published, lambda { where(:publish_at.lte => Date.today) }

  slug :name

  belongs_to :admin

end
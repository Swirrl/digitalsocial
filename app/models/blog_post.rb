class BlogPost

  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  include Mongoid::Slug

  field :name, type: String
  field :publish_at, type: Date
  field :body, type: String
  field :tags, type: Array

  scope :published, lambda { where(:publish_at.lte => Date.today) }

  validates :name, :body, presence: true

  slug :name

  belongs_to :admin

  def tags_list=(list)
    self.tags = list.split(',')
  end

  def tags_list
    self.tags.to_a.join(',')
  end

end
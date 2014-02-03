class PageCategory

  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  field :intro, type: String
  slug :name

  has_many :pages

end
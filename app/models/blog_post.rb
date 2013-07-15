class BlogPost

  include Mongoid::Document
  include Mongoid::MultiParameterAttributes

  field :name, type: String
  field :publish_at, type: Date
  field :status, type: String
  field :body, type: String

end
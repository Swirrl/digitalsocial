class Page

  include Mongoid::Document

  field :name, type: String
  field :body, type: String
  field :path, type: String

  def core?
    ['about', 'events'].include?(path)
  end

end
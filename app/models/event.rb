class Event

  include Mongoid::Document
  include Mongoid::MultiParameterAttributes

  field :name, type: String
  field :start_date, type: Date
  field :end_date, type: Date
  field :url, type: String

end
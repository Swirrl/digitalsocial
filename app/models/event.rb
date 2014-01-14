class Event

  include Mongoid::Document
  include Mongoid::MultiParameterAttributes

  field :name, type: String
  field :start_date, type: Date
  field :end_date, type: Date
  field :url, type: String
  field :dates_confirmed, type: Boolean, default: true

  validates :name, :url, presence: true

  def date_string
    if dates_confirmed?
      if start_date == end_date
        start_date.strftime("%-d %B %Y")
      elsif start_date.month == end_date.month
        days = [start_date.strftime("%-d"), end_date.strftime("%-d")].join("-")
        "#{days} #{start_date.strftime("%B %Y")}"
      elsif start_date.year == end_date.year
        days = [start_date.strftime("%-d %B"), end_date.strftime("%-d %B")].join(" - ")
        "#{days} #{start_date.year}"
      else
        [start_date.strftime("%-d %B %Y"), end_date.strftime("%-d %B %Y")].join(" - ")
      end
    else
      "#{start_date.strftime("%B %Y")} (TBC)"
    end
  end

end
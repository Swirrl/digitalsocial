class Logo

  include Mongoid::Document
  include Mongoid::Paperclip

  field :organisation_uri

  has_mongoid_attached_file :file,
    path:           'logos/:id/:style.:extension',
    storage:        :s3,
    url:            ":s3_eu_url",
    s3_credentials: File.join(Rails.root, 'config', 's3.yml'),
    styles: {
      thumb: '70x',
      medium: '200x'
    }

  def organisation_resource
    Organisation.find(self.organisation_uri)
  end

end
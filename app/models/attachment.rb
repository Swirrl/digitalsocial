class Attachment

  include Mongoid::Document
  include Mongoid::Paperclip

  field :name, type: String

  has_mongoid_attached_file :file,
    path:           'attachments/:id/:basename.:extension',
    storage:        :s3,
    url:            ":s3_eu_url",
    s3_credentials: File.join(Rails.root, 'config', 's3.yml')

end
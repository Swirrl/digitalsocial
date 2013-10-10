namespace :reports do 
  require 'csv'
  
  desc "Report of all the email addresses and the organisations they belong to."
  task organisation_emails: :environment do
    CSV do |csv_std_out|
      User.each do |u|
        if u.organisation_memberships.any?
          u.organisation_memberships.each do |om|
            org = om.organisation_resource
            csv_std_out << [u.email, org.name, org.uri]
          end
        else
          csv_std_out << [u.email, nil, nil]
        end
      end
    end
  end
end

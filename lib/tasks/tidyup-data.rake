namespace :tidyup do

  # This task removes an organisation along with the following
  # supporting information from both the triple-store and mongodb.
  #
  # - the organization
  # - the site of the organization
  # - the address of the site
  # - any activity memberships involving the organization
  # - the time interval of the activity
  #
  # - the link from a user to a deleted org (though need to check that a user is not still associated with a remaining organisation)
  # - email invitations and confirmations for those users
  #    - logo
  #    - users (if they're only in one organisation)
  desc 'Tidy up data that NESTA doesnt like being in the database'
  task remove_some_organisations: :environment do
   
    organisation_uris = %w(http://data.digitalsocial.eu/id/organization/adb269fe-57e8-3041-71b8-4161b42b8631
                                 http://data.digitalsocial.eu/id/organization/98ab2ffc-ec77-94df-a82e-bb1302b88097
                                 http://data.digitalsocial.eu/id/organization/9aa8446b-3821-60e6-0abb-a63a5f63260f
                                 http://data.digitalsocial.eu/id/organization/5ffb33cd-ae84-c5d1-f8d3-46df8169a2cb
                                 http://data.digitalsocial.eu/id/organization/1cb34d46-939c-ff83-24f8-1f7116dca4bb
                                 http://data.digitalsocial.eu/id/organization/005db02b-621d-5d61-54c6-24d9e45fc4c9
                                 http://data.digitalsocial.eu/id/organization/f0c94d0f-00ca-78c6-887c-1b70f1c164f7
                                 http://data.digitalsocial.eu/id/organization/0b9775e7-042c-6f9b-9cdb-27df5c523aa3
                                 http://data.digitalsocial.eu/id/organization/a54cfe42-3d2d-9aca-5df7-4a6472655ec3
                                 http://data.digitalsocial.eu/id/organization/af56693a-7f05-cab4-7c00-3d9f5a4804af
                                 http://data.digitalsocial.eu/id/organization/35a28a25-6897-578c-5587-af08cce0f5bc
                                 http://data.digitalsocial.eu/id/organization/75025741-4b21-2890-167c-f0e396174532
                                 http://data.digitalsocial.eu/id/organization/0ec7a554-57f5-c98a-a0bf-1e8f3fbca85d
                                 http://data.digitalsocial.eu/id/organization/de4b0a7a-379b-eed2-4d61-5a0464c43ea8
                                 http://data.digitalsocial.eu/id/organization/fd4d39c9-dff5-c09a-ccbd-7b1c1caa388d
                                 http://data.digitalsocial.eu/id/organization/092dac44-d9cb-c8d0-fed9-3caed008074d
                                 http://data.digitalsocial.eu/id/organization/3c71ef17-1796-fa16-a71f-b6514055a9c0
                                 http://data.digitalsocial.eu/id/organization/f03a3cb5-c26d-251b-0fee-fcf9f19ef382
                                 http://data.digitalsocial.eu/id/organization/c04a3b88-936f-805d-ae40-051d1cf902fc
                                 http://data.digitalsocial.eu/id/organization/5bb62b3e-54c4-ca90-78cd-8237b08c2ed9
                                 http://data.digitalsocial.eu/id/organization/382be39b-55be-0392-5d76-e66c8f0af8cc
                                 http://data.digitalsocial.eu/id/organization/ab9e04b6-eef8-c782-2c86-84e169673bbe)

    # Records are deleted bottom up, not top down.  So in the case of
    # error you should still have a reference to the object.
    
    puts Tripod.query_endpoint

    destroy_list = []
    mongo_destroy_list = []
    
    organisations = organisation_uris.each do |org_uri|
      org = Organisation.find org_uri
      puts "#{org.name}"
      puts "\turi: #{org.uri}"
      site = org.primary_site_resource
      unless site.nil?
        address = site.address_resource
        puts "\taddress_uri: #{address.uri}"
        puts "\taddress: #{address}"
        destroy_list << address if address.present?
        destroy_list << site 
      else

      end
      
      puts "\tprojects: "

      org.project_resources.each do |project|
        puts "\t\t#{project.name}"
        puts "\t\t\turi: #{project.uri}"
        time_interval = project.duration_resource
        puts "\t\t\tduration: #{project.duration_str}"
        
        ProjectInvite.any_of({:invited_organisation_uri => org_uri},
                             {:invitor_organisation_uri => org_uri}).each do |invite|
          puts "\t\t\tInvite (mongo): #{invite.id}"
          mongo_destroy_list << invite
        end

        ProjectRequest.where(project_uri: project.uri.to_s).each do |request|
          puts "\t\t\tRequest (mongo): #{request.id}"
          mongo_destroy_list << request
        end

        project_predicate = ProjectMembership.fields[:project].predicate.to_s
        ProjectMembership.where("?uri <#{project_predicate}> <#{project.uri}>").resources.each do |pm|
          puts "\t\t\tProjectMembership: #{pm.uri}"
          destroy_list << pm
        end
        
        destroy_list << time_interval if time_interval.present?
        destroy_list << project 
      end

      puts "\tMemberships (mongo): "
      OrganisationMembership.where(organisation_uri: org_uri).each do |om|
        user = om.user
        unless user.nil?
          if user.organisation_memberships.count == 1
            puts "\t\t #{user.email}" 
            mongo_destroy_list << om.user
          else
            puts "\t\t #{user.email} (is in several other organisations)"
          end
        end
      end

      Logo.where(organisation_uri: org_uri).each do |logo|
        puts "\tLogo (mongo): #{logo.file_file_name}"
        mongo_destroy_list << logo
      end
      
      destroy_list << org
    end

    puts "-[deletions]---------------------"
    
    destroy_list.each do |o|
      puts "Destroying #{o.class}: #{o.uri}"
      o.destroy
    end

    mongo_destroy_list.each do |o|
      puts "Destroying #{o.class} #{o.id}"

      o.class == Logo && Rails.env != 'production' ? o.delete : o.destroy
    end

    puts "-[delete orphaned memberships]---"

    destroy_memberships = []
    # Find orphaned memberships that have occured because of the deletions above, and remove them.
    ProjectMembership.find_by_sparql("SELECT ?uri WHERE { 
                                         ?uri a <http://data.digitalsocial.eu/def/ontology/ActivityMembership> .
                                         MINUS {
                                            ?uri <http://data.digitalsocial.eu/def/ontology/organization> ?org .
                                            ?org ?p ?o
                                         }
                                    }").each do |pm|
      puts "Found Orphaned Project Membership #{pm.uri}"
      destroy_memberships << pm
    end

    destroy_memberships.each do |pm|
      pm.destroy
    end
  end
end

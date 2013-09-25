namespace :db do

  desc 'Clean Mongoid and Tripod data'
  task clean: :environment do

    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = "mongoid"
    DatabaseCleaner.clean

    Tripod::SparqlClient::Update.update('
      # delete from default graph:
      DELETE {?s ?p ?o} WHERE {?s ?p ?o};
      # delete from named graphs:
      DELETE {graph ?g {?s ?p ?o}} WHERE {graph ?g {?s ?p ?o}};
    ')
  end

  desc 'Seed data for map visualisation'
  task seed_map_viz: :environment do

    puts "Seeding organisations"
    begin
      20.times { FactoryGirl.create(:organisation_near_lat_lng, near: [51.513048,-0.115753]) } # London
      10.times { FactoryGirl.create(:organisation_near_lat_lng, near: [53.479522,-2.247702]) } # Manchester
      10.times { FactoryGirl.create(:organisation_near_lat_lng, near: [52.519413,13.407022]) } # Berlin
      5.times { FactoryGirl.create(:organisation_near_lat_lng, near: [48.85659,2.352823]) }    # Paris
      5.times { FactoryGirl.create(:organisation_near_lat_lng, near: [52.370339,4.89575]) }    # Amsterdam
      5.times { FactoryGirl.create(:organisation_near_lat_lng, near: [40.416722,-3.703047]) }  # Madrid
      3.times { FactoryGirl.create(:organisation_near_lat_lng, near: [41.89318,12.483076]) }   # Rome
      3.times { FactoryGirl.create(:organisation_near_lat_lng, near: [41.005365,28.977395]) }  # Istanbul
      3.times { FactoryGirl.create(:organisation_near_lat_lng, near: [47.497929,19.040669]) }  # Budapest
      3.times { FactoryGirl.create(:organisation_near_lat_lng, near: [44.432653,26.103398]) }  # Bucharest
      2.times { FactoryGirl.create(:organisation_near_lat_lng, near: [48.208394,16.372579]) }  # Vienna
      2.times { FactoryGirl.create(:organisation_near_lat_lng, near: [52.229698,21.013037]) }  # Warsaw
      2.times { FactoryGirl.create(:organisation_near_lat_lng, near: [50.85037,4.350897]) }    # Brussels
      2.times { FactoryGirl.create(:organisation_near_lat_lng, near: [46.198524,6.142913]) }   # Geneva
      
      10.times { FactoryGirl.create(:organisation) } # Random
    rescue => e

    end

    organisations = Organisation.all.resources.to_a

    20.times do |n|
      puts "Seeding activity #{n}"
      project = FactoryGirl.create(:project_with_organisations, organisations_count: 0)

      (rand(6) + 1).times do
        FactoryGirl.create(:project_membership, project: project.uri.to_s, organisation: organisations.sample.uri.to_s) rescue nil
      end
    end
    
  end  

end
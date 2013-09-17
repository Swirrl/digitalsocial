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

    20.times { FactoryGirl.create(:organisation_near_lat_lng, near: [51.513048,-0.115753]) } # London
    10.times { FactoryGirl.create(:organisation_near_lat_lng, near: [53.479522,-2.247702]) } # Manchester
    10.times { FactoryGirl.create(:organisation_near_lat_lng, near: [52.519413,13.407022]) } # Berlin
    5.times { FactoryGirl.create(:organisation_near_lat_lng, near: [48.85659,2.352823]) }    # Paris
    5.times { FactoryGirl.create(:organisation_near_lat_lng, near: [52.370339,4.89575]) }    # Amsterdam
    5.times { FactoryGirl.create(:organisation_near_lat_lng, near: [40.416722,-3.703047]) }  # Madrid
    5.times { FactoryGirl.create(:organisation_near_lat_lng, near: [41.89318,12.483076]) }   # Rome
    30.times { FactoryGirl.create(:organisation) } # Random

    50.times { FactoryGirl.create(:project_with_organisations) }
  end  

end
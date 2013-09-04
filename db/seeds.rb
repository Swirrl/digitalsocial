# project team (in main data graph)

RestClient::Request.execute(
  :method => :post,
  :url => (Digitalsocial::DATA_ENDPOINT + '?graph=' + Digitalsocial::DATA_GRAPH),
  :payload =>  File.read(File.join(Rails.root, 'doc', 'project-team.ttl')),
  :headers => {content_type: 'text/turtle'},
  :timeout => 300
)

# dataset metadata
RestClient::Request.execute(
  :method => :put,
  :url => (Digitalsocial::DATA_ENDPOINT + '?graph=' + Digitalsocial::DATA_GRAPH + '/metadata'),
  :payload =>  File.read(File.join(Rails.root, 'doc', 'organizations-and-activities.ttl')),
  :headers => {content_type: 'text/turtle'},
  :timeout => 300
)

# ontology
RestClient::Request.execute(
  :method => :put,
  :url => (Digitalsocial::DATA_ENDPOINT + '?graph=' + Digitalsocial::ONTOLOGY_GRAPH),
  :payload =>  File.read(File.join(Rails.root, 'doc', 'dsi-ontology.nt')),
  :headers => {content_type: 'text/plain'},
  :timeout => 300
)

# supporting external ontologies

def content_type_for_filename(filename)
  {
    '.ttl' => 'text/turtle',
    '.nt' => 'text/plain',
    '.txt' => 'text/plain',
    '.rdf' => 'application/rdf+xml'
  }[File.extname(filename)]
end

['cube.ttl', 'dcterms.rdf', 'dsi-ontology.nt', 'foaf.rdf', 'org.ttl', 'owl.rdf',
 'rdf.rdf', 'rdfs.rdf', 'rdfschema_extra.nt', 'skos.rdf', 'vcard.ttl', 'wgs84_pos.rdf',
 'timeline.ttl', 'event.ttl'].each do |filename|

  RestClient::Request.execute(
    :method => :put,
    :url => (Digitalsocial::DATA_ENDPOINT + '?graph=' + "http://data.digitalsocial.eu/graph/ontology/#{filename.split('.').first}" ),
    :payload =>  File.read(File.join(Rails.root, 'doc', filename)),
    :headers => {content_type: content_type_for_filename(filename) },
    :timeout => 300
  )

end

# concept schemes

# Project Membership Natures - all top level. We don't allow other here.
["Sole funder",
  "Co-funder",
  "Delivery Lead",
  "Delivery Partner",
  "Evaluator",
  "Advisory-group member"
  # note no other
  ].each do |label|
  Concepts::ProjectMembershipNature.from_label(label, top_level:true)
end

# Activity Types
["Research Project",
  "Event",
  "Network",
  "Incubators and Accelerators",
  "Maker and Hacker Spaces",
  "Education And Training",
  "Service Delivery",
  "Investment And Funding",
  "Advocating And Campaigning",
  "Advisory or Expert Body",
  "Other" # Will be used as a special broad top-level concept scheme to hang narrower ones off.
].each do |label|
  Concepts::ActivityType.from_label(label, top_level:true)
end

# Areas of Society
["work and employment",
  "health and wellbeing",
  "participation and democracy",
  "education and skills",
  "science",
  "culture and arts",
  "finance and economy",
  "energy and environment",
  "neighbourhood regeneration",
  "Other"  # Will be used as a special broad top-level concept scheme to hang narrower ones off.
].each do |label|
  Concepts::AreaOfSociety.from_label(label, top_level:true)
end

# Technology Focus
["Open Networks",
  "Open Data",
  "Open Knowledge",
  "Open Hardware"
  # Note: no 'other'
].each do |label|
  Concepts::TechnologyFocus.from_label(label, top_level:true)
end

# Technology Method
["big data",
  "open data",
  "open source",
  "crowdfunding",
  "crowdmapping",
  "geotagging",
  "mobile apps",
  "e-petitions",
  "online learning models",
  "MOOCS",
  "online notice board",
  "personal monitoring",
  "quantified-self",
  "social networks",
  "social media",
  "3D printing",
  "P2P",
  "distributed exchange networks",
  "online peer support",
  "machine learning",
  "online market place",
  "collaborative consumption",
  "online resource sharing",
  "sensors",
  "Internet of things",
  "Other"  # Will be used as a special broad top-level concept scheme to hang narrower ones off.
].each do |label|
  Concepts::TechnologyMethod.from_label(label, top_level:true)
end

# Organisation Type
["Government And Public Sector",
  "Business",
  "Academia And Research",
  "Social Enterprise Charity Or Foundation",
  "Grass Roots Organization Or Community Network"
].each do |label|
  Concepts::OrganisationType.from_label(label, top_level:true)
end

# FTE Range
["0-5",
  "6-10",
  "11-25",
  "26-50",
  "51-100",
  "101-500",
  "501-1000",
  "over-1000"
].each do |label|
  Concepts::FTERange.from_label(label, top_level:true)
end

# Seed admins
Admin.create(email: 'admin@test.com', password: 'password', name: 'Test Admin', job_title: 'Tester', organisation: 'Swirrl', organisation_url: 'http://swirrl.com')

# Seed events
Event.create(name: 'The GovLab Experiment, New York', start_date: '18 April 2013', end_date: '19 April 2013', url: 'http://www.thegovlab.org')

# Seed blog posts
BlogPost.create(name: 'Understanding the potential in digital social innovation', publish_at: '27th June 2013', status: 'published', body: <<eos)
Following the nuclear catastrophe at the Fukushima nuclear power plant in March 2011, Safecast, a global sensor network for collecting and sharing radiation measurements, used crowdfunding platform Kickstarter to raise money for [a project that would help them crowdsource radiation levels in Japan](http://www.fastcoexist.com/1680065/safecasts-new-geiger-counter-lets-anyone-collect-and-share-data-on-radiation).

This allowed volunteers to upload their own Geiger counter readings to a [crowdsourced map](http://blog.safecast.org/maps/) to provide accurate radiation levels to the public.

From their project the Safecast team learned that most of the different Geiger counters used to measure radiation during their project were out of date or too poor quality. With this insight in mind, the team thought up the idea for the Safecast X highly sensitive Geiger counter (it detects alpha and beta radiation as well as the standard gamma).

However, the team were short the minimum $4,000 it would take to develop this new model. The team [once again turned to the crowds](http://www.kickstarter.com/projects/seanbonner/safecast-x-kickstarter-geiger-counter/comments), who responded with both feedback on what they would like from the Geiger counter in addition to what the team proposed, such as a USB connection and the ability to use it with mobile apps. Within the close of its campaign the Geiger counter had raised $104,2681. This money will provide for 250 Geiger counters to be used all over the world by Safecast's volunteers.

To date, the volunteers have mapped radiation levels of more than 3 million data points, providing a comprehensive and accurate dataset that was inconceivable before the Safecast project.

Through the use of crowdfunding, crowdsourcing, open and user generated data the Geiger counter is in many ways a mini study of some of the many projects and campaigns that use the internet to bring people together to solve social problems in new ways.

Over the last couple of months we have been working on identifying examples of Digital Social Innovations (DSI)  like the Safecast Geiger counter, that use digital technologies to bring people together to solve social challenges. Despite this great example of people coming together, the majority of DSI projects are still relatively small scale. A few, like [www.avaaz.org](http://www.avaaz.org) and [www.change.org](www.change.org) are just beginning to achieve mainstream success.

Through the next 18 months of research we hope to shine a light on the potential for digital social innovation, who the people and organisations are that are fostering its growth and finally what policy makers and others might do to encourage more digital innovation for social good.

We are still looking for great examples of DSI and to learn more about the organisations working on DSI, from grassroots networks to foundations and government departments. If you know of a great case study or if you are working on DSI then please send us a [mail](mailto:contact@digitalsocial.eu) or [tweet](https://twitter.com/digi_si).

**Here are our criteria:**

* Achieve positive social impact from their service
* Are disruptive in their use of online/digital tools or methods
* Demonstrate a "network effect" by facilitating user collaboration or the sharing of user data
* Operate at scale i.e  the larger number of users the service has, the better
eos

# Seed pages
Page.create(name: 'home', body: <<eos)
The internet is playing an ever increasing role in how we work, play, and relate to each other.

As a natural result of this many of the most exciting new innovations that address social issues are being developed online. We call this exciting new field *Digital Social Innovation* and it includes a diverse set of activities and actors.

However, while the field of digital social innovation practice is growing rapidly, there is little knowledge around what best practice looks like, where it is happening, who the digital social innovators are and what strategic approaches can best support its growth.

The EU Commission recognises this issue and has commissioned a study to explore and assess the emerging landscape. This will be carried out by an EU wide partnership of *Nesta* (UK), *Esade Business School* (Spain), *Waag Society* (NL), *Institut de Recherche et d'Innovation* (Fr) and *FutureEverything* (UK).

**Are you on the Digital Social Innovation Map?**

If you are active in this area, please help us by completing a short survey.

We are really interested in understanding who the digital social innovators are, where you are and how you are connected to each other. To understand this we are developing an EU wide map of organisations, listing what kind of activities they are involved in, how they are supporting it and how they are connected to others.

We will create a resource that helps digital social innovators connect while also developing an understanding for the EU and national governments on the state of Digital Social Innovation in different parts of EU.

If you are keen on discussion more, drop us [a tweet](https://twitter.com/digi_si), send us [an email](mailto:contact@digitalsocial.eu) or come to one of the [DSI events](/events) we are planning on attending.
eos

Page.create(name: 'about', body: <<eos)
Our research focuses on assessing and visualising the ever-changing landscape of Digital Social Innovation (DSI) - which is a type of social and collaborative innovation in which final users and communities collaborate through digital platforms to produce solutions for a wide range of social needs.

The main areas we will focus on are:

* A clear definition of Digital Social Innovation (DSI)
* A set of example DSI services which will grow over time
* An understanding of DSI practitioners and organisations that currently support them
* How Digital Social Innovation can be supported within the EU

Our work on understanding DSI begins with looking at the many inspiring types of digital technologies being used around the world to facilitate new types of collaboration and create social innovations, from crowdfunding and citizen apps to open sensors and social networks. Here are some of the case studies that inspire us.

Alongside learning from great practice we also want to identify the key organisations involved in shaping the DSI agenda in the EU, from the fablabs movement to the open ministry in Finland.
eos

Page.create(name: 'events', body: <<eos)
Some upcoming events of interest in the field of Digital Social Innovation.
eos
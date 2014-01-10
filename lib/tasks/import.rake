# rake import:admins import:events import:pages import:page_categories import:blog_posts
namespace :import do

  desc 'Import DSI admins'
  task admins: :environment do
    DatabaseCleaner.strategy = :truncation, { only: ["admins"] }
    DatabaseCleaner.orm = "mongoid"
    DatabaseCleaner.clean

    Admin.create({
      name: 'Peter Thirup Baeck',
      job_title: 'Policy Advisor',
      organisation_name: 'Nesta',
      organisation_url: 'http://www.nesta.org.uk',
      email: 'peter.baeck@nesta.org.uk',
      password: 'd1g1t4l50c14l'
    })

    Admin.create({
      name: 'Francesca Bria',
      job_title: 'Senior Project Lead',
      organisation_name: 'Nesta',
      organisation_url: 'http://www.nesta.org.uk',
      email: 'francesca.bria@nesta.org.uk',
      password: 'd1g1t4l50c14l'
    })

    Admin.create({
      name: 'Jon Kingsbury',
      organisation_name: 'Nesta',
      organisation_url: 'http://www.nesta.org.uk',
      email: 'jon.kingsbury@nesta.org.uk',
      password: 'd1g1t4l50c14l'
    })
  end

  desc 'Import DSI events'
  task events: :environment do
    DatabaseCleaner.strategy = :truncation, { only: ["events"] }
    DatabaseCleaner.orm = "mongoid"
    DatabaseCleaner.clean

    Event.create({
      name: "W3C Workshop: Publishing and the Open Web Platform. Paris",
      url: "http://www.w3.org/2012/12/global-publisher/",
      start_date: "16 September 2013",
      end_date: "17 September 2013"
    })

    Event.create({
      name: "Open Knowledge Fest 2013, Geneva",
      url: "http://okfestival.org",
      start_date: "16 September 2013",
      end_date: "18 September 2013"
    })

    Event.create({
      name: "Digital Enlightenment Forum, Brussels",
      url: "http://www.digitalenlightenment.org/",
      start_date: "18 September 2013",
      end_date: "20 September 2013"
    })

    Event.create({
      name: "Maker Faire, Global, New York",
      url: "http://makerfaire.com",
      start_date: "21 September 2013",
      end_date: "22 September 2013"
    })

    Event.create({
      name: "Digital Agenda Assembly 2013, Lithuania",
      url: "http://ec.europa.eu/digital-agenda/en/ict-2013",
      start_date: "6 November 2013",
      end_date: "8 November 2013"
    })

    Event.create({
      name: "EU Internet Week, Brussels",
      url: "http://www.eu-ems.com/summary.asp?event_id=120&page_id=949",
      start_date: "12 November 2013",
      end_date: "16 November 2013"
    })

    Event.create({
      name: "Smart City Expo, Barcelona",
      url: "http://www.smartcityexpo.com/en/home",
      start_date: "19 November 2013",
      end_date: "21 November 2013"
    })

    Event.create({
      name: "Wikipedia and OpenLabs, Tirana, Albania",
      url: "http://hackerspaces.org/wiki/Wikipedia_Workshop_at_Open_Labs",
      start_date: "1 December 2013",
      end_date: "1 December 2013"
    })

    Event.create({
      name: "CCC Congress, Hamburg",
      url: "http://events.ccc.de/congress/2012/wiki/Main_Page",
      start_date: "1 December 2013",
      end_date: "1 December 2013",
      dates_confirmed: false
    })

    Event.create({
      name: "The New Industrial World Forum, Centre Pompidou, IRI",
      url: "http://www.iri.centrepompidou.fr/seminaire/new-industrial-world-forum/?lang=en_us",
      start_date: "16 December 2013",
      end_date: "17 December 2013"
    })

    Event.create({
      name: "South By South West, Austin",
      url: "http://sxsw.com",
      start_date: "7 March 2014",
      end_date: "11 March 2014"
    })

    Event.create({
      name: "FutureEverything Festival",
      url: "http://futureeverything.org/summit/summit-highlights",
      start_date: "1 March 2014",
      end_date: "1 March 2014",
      dates_confirmed: false
    })

    Event.create({
      name: "World Wide Web Conference",
      url: "http://www.2014.wwwconference.org/",
      start_date: "1 April 2014",
      end_date: "1 April 2014",
      dates_confirmed: false
    })

    Event.create({
      name: "World Wide Web Conference",
      url: "http://www.sonar.es/en/pg/what-is-s%C3%B3nar-d#.Ucv-5fmsh8E",
      start_date: "12 June 2014",
      end_date: "14 June 2014"
    })

  end

  desc 'Import DSI pages'
  task page_categories: :environment do
    DatabaseCleaner.strategy = :truncation, { only: ["page_categories"] }
    DatabaseCleaner.orm = "mongoid"
    DatabaseCleaner.clean

    PageCategory.create(name: 'Case studies')
  end

  desc 'Import DSI pages'
  task pages: :environment do
    DatabaseCleaner.strategy = :truncation, { only: ["pages"] }
    DatabaseCleaner.orm = "mongoid"
    DatabaseCleaner.clean

    Page.create({
      name: "About",
      path: "about",
      body: <<eos
This site is part of an EU wide research project on Digital Social Innovation (DSI).

The European Commission has funded the project to build a living map of organisations that use digital technologies for social innovation. Led by [Nesta](http://nesta.org.uk), the project partners are [Esade](http://esade.edu), [FutureEverything](http://futureeverything.org), [IRI](http://www.iri.centrepompidou.fr/en/), [Swirrl](http://swirrl.com) and [Waag Society](http://waag.org/en).

By joining the network, we're asking you to give us some information about your organisation. This information will be visually represented on a map and the data you provide us will be freely open to everyone and published as [Linked Open Data](http://data.digitalsocial.eu) under a [Creative Commons Public Domain Dedication licence](http://creativecommons.org/publicdomain/zero/1.0/).

We will use the information you give us to:

* Build a community of digital social innovators across Europe
* Understand emerging technology trends and the potential opportunities for supporting them better
* Write policy recommendations to the European Commission

It's worth checking our [Terms of Use](/terms) which we'll ask you to sign up to.

Joining the network is very easy and it will take just a few minutes to [get started](/organisations/build/new_user).

If you have any questions please email [contact@digitalsocial.eu](mailto:contact@digitalsocial.eu).
eos
    })

    Page.create({
      name: "Events",
      path: "events",
      body: <<eos
Some upcoming events of interest in the field of Digital Social Innovation.
eos
    })
  end


  desc 'Import DSI blog posts'
  task blog_posts: :environment do
    DatabaseCleaner.strategy = :truncation, { only: ["blog_posts"] }
    DatabaseCleaner.orm = "mongoid"
    DatabaseCleaner.clean

    BlogPost.create({
      name: '100 inspiring digital social innovations',
      publish_at: '4 December 2013',
      body: <<eos
![Nominet Trust 100](/assets/blog/nominet-trust-100.png)

**[Research from the Nominet Trust](http://www.socialtech.org.uk/) shows the potential in Digital Social Innovation and why we need to understand how to support this exciting new type of social innovation to grow across Europe.**

Digital Social Innovation has been attracting a lot of attention lately. The term is a relatively new one, and as such it is contested, but broadly it means...

> 'a type of social and collaborative innovation in which innovators, users and communities collaborate using digital technologies to co-create knowledge and solutions for a wide range of social needs and at a scale that was unimaginable before the rise of Internet-enabled platforms'

Little research has been done to date to understand the potential for digital technologies to achieve social impact? This is one of the big questions that we have been trying to answer in [our research project into Digital Social Innovation](http://digitalsocial.eu/).

Mapping the field of new types of Digital Social Innovation, is exciting, but also a big and challenging task. Luckily, we are not alone. This week our friends at the Nominet Trust [launched findings from their NT100 project](http://www.socialtech.org.uk/), which has sought to identify 'the 100 most inspiring social tech solutions from around the world'.

The Social Tech website is an inspiring resource for anyone interested in understanding the potential of digital technologies to achieve social impact in as diverse fields as economic empowerment, education and health. In the spirit of 'proudly found elsewhere; we will 'copy' and add organisations who aren't on it already to our [digitalsocial.eu network map of organisations involved in supporting or delivering DSI activities](http://digitalsocial.eu/).

How to support Digital Social Innovation to grow
------------------------------------------------

However, looking at the case studies we have identified as part of our work and the many NT100 examples can both be an inspiring as well as a slightly frustrating exercise. Inspiring, because these great examples show the massive potential in tech for good. Frustrating, because, bar a couple of exceptions such as [Github](http://github.com/), [Arduino](http://arduino.cc/) and [Patients Like Me](http://www.patientslikeme.com/), the majority of these initiatives are relatively small scale and sit on the periphery of the mainstream.

What conditions foster and then scale the work of organisations like [Your Priorities](https://www.yrpri.org/home/world) and [Open Ministry](http://openministry.info/) on crowdsourcing legislation? Or [Tyze](http://tyze.com/) on creating online personal networks for people with care needs?  Or [Zooniverses](https://www.zooniverse.org/) pioneering work on citizen science?

Entrepreneurship will play its part, but we are also keen to understand the policies, strategies and funding mechanisms the EU, national regional and local government might apply to support digital social innovation in Europe, so we go from inspiring stories to mass market adoption. This is the focus for our next phase of research, which we will begin in December.

In the meantime, what do you think are the most successful tools policy makers and funders could apply to support DSI? Let us know in the comments below.
eos
    })

    BlogPost.create({
      name: 'Funding opportunities for Digital Social Innovation in Europe',
      publish_at: '3 December 2013',
      body: <<eos
Digital Social Innovation has been attracting a lot of attention lately. The term is a relatively new one, and as such it is contested, but broadly it can be defined as...

*'a type of social and collaborative innovation in which innovators, users and communities collaborate using digital technologies to co-create knowledge and solutions for a wide range of social needs and at a scale that was unimaginable before the rise of Internet-enabled platforms'*

And in addition to our research work to [map digital social innovation](http://digitialsocial.eu), the last month has seen three exciting new opportunities for European Commission funding:

* The second CAPS (Collective Awareness Platforms) call, priority ICT10 of Horizon 2020, was officially presente and discussed on November 7th  at the [ICT 2013 in Vilnius](http://ec.europa.eu/digital-agenda/en/ict-2013). You can find the presentation and excerpt from the draft of H202 Workprogramme draft [here](http://ec.europa.eu/digital-agenda/events/cf/ict2013/item-display.cfm?id=11634).
  
  Also in Vilnius, more details were given about [CHEST](http://www.chest-project.eu/), the CAPS project which will award 2.5 M&euro; of seed funding to [Digital Social Innovation](http://digitalsocial.eu/) activities in the coming months.

* Seed funding for projects towards SMEs and new organisations using FI-PPP services, under the objective ICT 1.8 in Call ICT-FI. The language gets a bit technical,but have a look at the [call for proposals](http://cordis.europa.eu/fp7/ict/netinnovation/call3_en.html). Be quick though - the deadline is December 10th this year.

* Finally, the project [CONFINE](http://confine-project.eu/open-call-2/) is launching its second Open Call (with a budget of 750 k&euro;) on "Connected communities: A future internet, built by the people for the people".

Remember, one of the best ways to make yourself visible to funders of Digital Social Innovation and potential collaborators is to map your activities on [digitalsocial.eu](http://digitalsocial.eu).

Participate!
eos
    })

BlogPost.create({
      name: 'What we learned about Digital Social Innovation at the Open Knowledge Conference',
      publish_at: '29 October 2013',
      body: <<eos
Six months into our research project on Digital Social
Innovation (DSI) we are in the midst of preparing our first
interim study report, which we will publish in the next
couple of months. On September 16th we convened our first
Advisory Group of experts on different aspects of digital
social innovation for the first time to discuss and
challenge our work to date. Alongside this we also [ran
three sessions](http://okcon.org/more-open-topics/dsi/) at
the recent Open Knowledge Conference
([OKCON](http://okcon.org/)) in Geneva to explore what the
open knowledge community would like to get out of our
research.

Discussions naturally went in different directions, covering the
opportunities in different technologies from open hardware to open
data and the role of DSI to help achieve outcomes in different
parts of society, from better care solutions for an ageing population
to new ways of growing democracy and participation.

However, aside from the very encouraging general interest in
the research and the recognition of the need to create a
much better knowledge base on what DSI is and how it can be
supported, there were three recurring challenges that kept
cropping up in discussions with the AG members and OKCON
participants:

* **What are the emerging socio-economic models for Digital Social
Innovation?** As with many social innovations the biggest challenge for
Digital Social Innovation(s) is the creation of sustainable and viable
systems. For instance our Advisory Group pointed out that the mere use
of open digital platforms for collaboration does not go far towards
real social innovation in our present world. What is truly disruptive
(in the positive sense) is the conjunction of digital tools and a
culture and practice of sharing. It also probably calls for major
changes in the macro-economic and legal environment (for instance
re-defining growth, economic indicators and sustainability). New
business models and socio-economic mechanisms based on the
valorisation of social data and common information resources for
collective use and public benefit are clearly starting to emerge.

However, big questions still remain around how many of the
inspiring but very small scale initiatives will be able to
demonstrate their value and compete or collaborate with
existing systems across Europe. How will a personal
network like [Tyze](http://tyze.com/) integrate with
traditional social care provision; how will sharing
platforms like [Peerby](https://peerby.com/) finance their
service; and what will it take for new models of
crowdsourcing legislation such as [Open
Ministry](http://openministry.info/) or [Liquid
Feedback](http://liquidfeedback.org/) to demonstrate they
present a viable alternative to transforming the
traditional models of representative democracy?  

Our research needs to begin to unpick how these and the
other inspiring examples we are researching answer these
questions.

* **An Emerging grassroots civic innovation ecosystem in
Europe: How can different types of organisations involved
in supporting and growing DSI in Europe be supported in
order to strengthen synergies across Europe?** A big part
of this research is crowdmapping networks of organisations
involved in supporting DSI or delivering DSI services (if
you haven't already, have a look at [our network map and
join the community](http://digitalsocial.eu/) if this is
you). This crowdmapping exercise is helping us to group
DSI projects according to their contribution to growing
technology trends such as open networks, open data, open
hardware, open source, and knowledge co-production
networks. This exercise is showing that it is crucial for
Europe to invest in this emerging and vibrant bottom-up
innovation ecosystem and technology trends.

Our research and the map will help to understand who the
organisations are, where they are based, and what strong
networks exist but it won't give us the refined
characteristics of the organisations and why they use
digital technologies. In order to develop practical
lessons for the wider social innovation community our work
on these case studies will need to unpick the rationale
behind cities like [Vienna](https://open.wien.at/site/)
and [Santander](http://www.smartsantander.eu/) pioneering
new practices in Open Data and open sensor networks, or
understand what drives organisations like
[Mysociety](http://www.mysociety.org/) and [Open Knowledge
Foundation](http://okfn.org/) to develop services like
[Fixmystreet](http://www.fixmystreet.com/) and
[CKAN](http://ckan.org/).

* What are the different types of network effects and types
of collaboration that are enabled by DSI? Digital Social
Innovation enables new forms of collaboration and/or
delivers a social impact through the creation of a
'network effect' (for a study on Digital Social Innovation
with a broader scope, have a look at the [Tech for
Good](http://www.nominettrust.org.uk/news-events/news/tech-good-challenge-uncovers-uk%E2%80%99s-most-promising-social-ventures)
project by our friends at the [Nominet
Trust](http://www.nominettrust.org.uk/)). However, to
properly understand the potential in online collaboration,
we need to recognise and understand in much more detail the
different types of collaboration and participation DSI
activities ask of people. There is a huge difference
between a simple action like an e- vote on
[Avaaz](http://www.avaaz.org/en/) vs. deeper engagement
via peer support through platforms like
[Tyze](http://tyze.com/) or taking part in a Hackathon to
unpick open public data.

These are some of the big questions and challenges to DSI
that we have had to date and hopefully our research,
together with the active engagement of the DSI community,
will begin to answer these.  What would you like to come
out of our research in to DSI? Let us know in the comments
below or via our twitter account
[@Digi_Si](https://twitter.com/digi_si) or email us at
[Digital.Social@nesta.org.uk](mailto:Digital.Social@nesta.org.uk).
eos
    })


BlogPost.create({
      name: 'Understanding the potential in digital social innovation',
      publish_at: '27 June 2013',
      body: <<eos
Following the nuclear catastrophe at the Fukushima nuclear power plant in March 2011,
Safecast, a global sensor network for collecting and sharing radiation measurements,
used crowdfunding platform Kickstarter to raise money for
[a project that would help them crowdsource radiation levels in Japan](http://www.fastcoexist.com/1680065/safecasts-new-geiger-counter-lets-anyone-collect-and-share-data-on-radiation).

This allowed volunteers to upload their own Geiger counter readings to a
[crowdsourced map](http://blog.safecast.org/maps/) to provide accurate radiation
levels to the public.


From their project the Safecast team learned that most of the different Geiger counters
used to measure radiation during their project were out of date or too poor quality.
With this insight in mind, the team thought up the idea for the Safecast X highly
sensitive Geiger counter (it detects alpha and beta radiation as well as the standard
gamma).

However, the team were short the minimum $4,000 it would take to develop this
new model. The team [once again turned to the crowds](http://www.kickstarter.com/projects/seanbonner/safecast-x-kickstarter-geiger-counter/comments),
who responded with both feedback on what they would like from the Geiger counter in
addition to what the team proposed, such as a USB connection and the ability to use it
with mobile apps. Within the close of its campaign the Geiger counter had raised
$104,2681. This money will provide for 250 Geiger counters to be used all over the world
by Safecast's volunteers.

To date, the volunteers have mapped radiation levels of more than 3 million data points,
providing a comprehensive and accurate dataset that was inconceivable before the Safecast
project.

Through the use of crowdfunding, crowdsourcing, open and user generated data the Geiger
counter is in many ways a mini study of some of the many projects and campaigns that use
the Internet to bring people together to solve social problems in new ways.

Over the last couple of months we have been working on identifying examples of Digital
Social Innovations (DSI)  like the Safecast Geiger counter, that use digital technologies
to bring people together to solve social challenges. Despite this great example of people
coming together, the majority of DSI projects are still relatively small scale. A few,
like [www.avaaz.org](http://www.avaaz.org) and [www.change.org](www.change.org) are just
beginning to achieve mainstream success.

Through the next 18 months of research we hope to shine a light on the potential for
digital social innovation, who the people and organisations are that are fostering its
growth and finally what policy makers and others might do to encourage more digital
innovation for social good.

We are still looking for great examples of DSI and to learn more about the organisations
working on DSI, from grassroots networks to foundations and government departments. If
you know of a great case study or if you are working on DSI then please send us a
[mail](mailto:contact@digitalsocial.eu) or [tweet](https://twitter.com/digi_si).

**Here are our criteria:**

* Achieve positive social impact from their service
* Are disruptive in their use of online/digital tools or methods
* Demonstrate a "network effect" by facilitating user collaboration or the sharing of user data
* Operate at scale i.e  the larger number of users the service has, the better
eos
    })
  end

end

namespace :import do

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

end

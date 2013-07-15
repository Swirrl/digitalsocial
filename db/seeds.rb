# Seed admins
Admin.create(email: 'admin@test.com', password: 'password')

# Seed events
Event.create(name: 'The GovLab Experiment, New York', start_date: '18 April 2013', end_date: '19 April 2013', url: 'http://www.thegovlab.org')

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
Digital Social Innovation
=========================

Released under the MIT-LICENSE.

Setup
-----

The app is pretty much a standard Rails app, except that it uses
[Tripod](https://github.com/Swirrl/tripod) and MongoDB instead of
ActiveRecord.

All public data is stored in a Fuseki triple store, and accessed via
the ORM-like Tripod API.

All private data is stored in MongoDB.

This repository no longer contains any configuration values, so for
example to get it running you will need to copy the
`development_example.rb` file to `development.rb` and adjust the
settings for your configuration.

Like wise when deploying to production you will need to ensure some
configuration files are copied up to the server.  The capistrano setup
task will do this, but you will need to ensure that at setup time the
files are available locally.  Some example files are provided for
these production services, these are:

1. `config/s3.example.yml` which is used for image uploads.
2. `config/development_example.rb` standard rails development environment.
3. `config/production_example.rb` standard rails production environment.
4. `config/test_example.rb` standard rails test environment.
5. `config/mongoid.yml.example` example mongoid config.
6. `config/raven_production_example.rb` config initializer for mandril SMTP.
7. `config/secret_token_production_example.rb` config initializer to secure cookies with a salt.

Production
----------

To deploy to production you will need to generate a random
secret_token.

    $ irb
    1.9.3-p448 :001 > require 'securerandom'
    => true
    1.9.3-p448 :002 > SecureRandom.hex(64)
    => "0677f2adfd6d181fd5d6abf4d047f526f57db7355705ab97624b08024622c94cf72d8e3a9469667df69feb916af4bab4dcefcecd7e0d103025ad92b007676acc"

Then copy the random string into the secret_token, and copy this file
to config/initializers/secret_token_production.rb .

The capistrano setup task willl then copy this to the server in the
shared/ directory within the app.


Setting up Fuseki
-----------------

Here is an example fuseki configuration:

    @prefix tdb:     <http://jena.hpl.hp.com/2008/tdb#> .
    @prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
    @prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
    @prefix ja:      <http://jena.hpl.hp.com/2005/11/Assembler#> .
    @prefix fuseki:  <http://jena.apache.org/fuseki#> .

    [] rdf:type fuseki:Server ;
       # Services available.  Only explicitly listed services are configured.
       #  If there is a service description not linked from this list, it is ignored.
       fuseki:services (
         <#digitalsocial_dev>
         <#digitalsocial_reporting>
         <#digitalsocial_test>
       ) .

    # add more services here ^^

    [] ja:loadClass "com.hp.hpl.jena.tdb.TDB" .
    tdb:DatasetTDB  rdfs:subClassOf  ja:RDFDataset .
    tdb:GraphTDB    rdfs:subClassOf  ja:Model .

    <#junk_data> rdf:type      tdb:DatasetTDB ;
         tdb:location "/tmp/digitalsocial_dev_data" ;  # change to suit your local installation
         # Query timeout on this dataset (1s, 1000 milliseconds)
         ja:context [ ja:cxtName "arq:queryTimeout" ;  ja:cxtValue "10000,10000" ] ;
         tdb:unionDefaultGraph true ;
         .

    <#digitalsocial_dev>  rdf:type fuseki:Service ;
        fuseki:name              "digitalsocial_dev" ;       # http://host:port/myname
        fuseki:serviceQuery      "sparql" ;    # SPARQL query service  http://host:port/odc/sparql?query=...
        fuseki:serviceUpdate     "update" ;   # SPARQL update servicehttp://host:port/odc/update?query=
        fuseki:serviceReadWriteGraphStore "data" ;     # SPARQL Graph store protocol (read and write)
        fuseki:dataset           <#digitalsocial_dev_data> ;
        .

    <#digitalsocial_dev_data> rdf:type      tdb:DatasetTDB ;
         tdb:location "/tmp/digitalsocial_dev_data" ;  # change to suit your local installation
         # Query timeout on this dataset (1s, 1000 milliseconds)
         ja:context [ ja:cxtName "arq:queryTimeout" ;  ja:cxtValue "10000,10000" ] ;
         tdb:unionDefaultGraph true ;
         .

    <#digitalsocial_test_data> rdf:type      tdb:DatasetTDB ;
         tdb:location "/tmp/digitalsocial_test_data" ;  # change to suit your local installation
         # Query timeout on this dataset (1s, 1000 milliseconds)
         ja:context [ ja:cxtName "arq:queryTimeout" ;  ja:cxtValue "10000,10000" ] ;
         tdb:unionDefaultGraph true ;
         .

Editing reminder emails
-----------------------

To change the email content, edit the files in `app/views/request_mailer`.

The table below summarises all the emails that are sent out:


| File (`.text.erb`) | Purpose | When |
| ------------- |-------------  | -----|---|
| `organisation_invite` | To notify a user that they have been invited to join an organisation. | Immediately |
| `project_new_organisation_invite` | To notify a user that does not already exist in the system that they have been invited to join a project. | Immediately |
| `project_request_acceptance` | To notify all users of an organisation that their invitation to a project was accepted. | Immediately |
| `projectless_user_reminder` | To remind all users of organisations without at least 1 project that they should add one. | Cron *(Every Tuesday at 10:30am)*
| `request_digest` | To remind all users with any pending items, a summary of those items. | Cron *(Every Tuesday at 10:15am)* |
| `unconfirmed_user_reminder` | To remind an unconfirmed user to log in (i.e. someone who has been invited but is yet to log in for the first time and set their password). | Cron *(Every Tuesday at 10:30am)*. |
| `user_request_acceptance` | To notify a user that their request to join an organisation was accepted. | Immediately |

Downloading a list of users
---------------------------

To download a CSV of existing users, visit `/admin/users.csv`. You must be logged in as an `Admin`.

This path will provide a CSV containing the users' first name, email address, and list of their organisations.

For example:

    Ric,ric@swirrl.com,Swirrl
    Bill,bill@swirrl.com,Swirrl
    John,john.smith@megacorp.com,Megacorp
    
To change the fields of this CSV, edit the `User.to_csv` method in the `User` model.



Making survey questions compulsory/optional
-------------------------------------------

### About you (Step 1)

The `User` is created on this step. `first_name`, `email` and `password` are all required here. These validations can be found in the `User` model. It is strongly recommended you do not remove these.

View for this step can be found at `app/views/organisations/build/new_user.html.haml`.

### Org Basics (Step 2)

This step initializes a new `OrganisationPresenter` (found in `app/presenters`).

The presenter then creates the `Organisation`, `Site` and `Address` records from the submitted form. Edit the presence validation in this presenter to require the appropriate fields in the form.

View for this step can be found at `app/views/organisations/build/new_organisation.html.haml`.

### Org details (Step 3)

This step edits an existing `Organisation`. Add validations to the `Organisation` model.

Note that any validations added here will also be applied to Step 2. To avoid this, ensure that it only applies to a persisted record.

E.g. in `app/models/user.rb`

    validates :twitter_username, presence: true, unless: :new_record?

View for this step can be found at `app/views/organisations/build/edit_organisation.html.haml`.

### 1st project (Step 4)

This step creates a new `Project`.

Add any validations for these fields in `app/models/project.rb`.

View for this step can be found at `app/views/organisations/build/new_project.html.haml`.

### Project details (Step 5)

This step updates the `Project` created in the previous step. Any validations applied for this step must have the `unless :first_step?` clause. This ensures that any validations applied here do not prevent Step 4 from progressing.

View for this step can be found at `app/views/organisation/build/edit_project.html.haml`.

### Project invites (Step 6)

This step initializes a new `ProjectInvitePresenter` (found in `app/presenters`).

The presenter then creates the `ProjectInvite` and, if they do not already exist, a new `User` and `Organisation`. Edit the presence validation in this presenter to require the appropriate fields in the form.

View for this step can be found at `app/views/organisations/build/invite_organisations.html.haml`.

### Making fields appear required

If an `if` or `unless` clause has been applied to a validation, SimpleForm will not automatically make the field appear required.

To resolve this, add `required: true` to the appropriate field in the view.
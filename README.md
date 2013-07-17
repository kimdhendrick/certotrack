Certotrack
==========

Welcome to CT on Rails! 

To do:

- Getting off the ground:
  - Backbone
     - How to get template/views into separate files?  Need require.js?
  - Jade
     - How to incorporate and translate templates in Jade
  - Capybara tests
     - Figure out how to install and write a few
  - Jasmine tests
     - Figure out how to install and write a few

- Epics
  - Port grails app!
  - Styling - same as Grails or more like Bootstrap default or something in the middle?
  - Migrate Grails app DB
  - Move to new host

----    

# Getting Started

## Clone repo

    git clone git@github.com:kimdbarnes/certotrack.git [local_dir]
    cd [local_dir]

## Setup gemset & rvmrc

### Create certotrack Gemset:

    rvm gemset create certotrack

### Use certotrack Gemset
    
    rvm gemset use certotrack

### Create .rvmrc file in /certotrack

*Note: You don't need to do this step if you've pulled the `.rvmrc` file checked into master.*

     rvm --rvmrc --create 1.9.3@certotrack

In this case, 1.9.3 is the version of ruby you want to use and certotrack is the gemset.
*Note: You __DO__ still need to do the following even if you've pulled the `.rvmrc` file checked into master.*

    cd ..
    cd [local_dir]

Answer 'yes' when prompted. Copy & paste command to ignore rvm warnings.

## Setup Database

### Create development, test, and production Databases

#### Start postgresql

    psql

#### Create Databases

    create database certotrack_development;
    create database certotrack_test;
    create database certotrack_production;

#### Create certouser Role

    create user certouser with password '';
    grant all privileges on database certotrack_development to certouser;
    grant all privileges on database certotrack_test to certouser;
    grant all privileges on database certotrack_production to certouser;

#### Add CreateDB Attribute to certouser Role

    alter role certouser with createdb;

#### Exit postgresql

    \q

### Migrate and Prepare Databases

    rake db:migrate
    rake db:test:prepare

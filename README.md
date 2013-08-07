Certotrack
==========

Welcome to CT on Rails! 

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

     rvm --rvmrc --create ruby-2.0.0-p247@certotrack

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
    rake db:seed

### Reset Database from Seed Data

    rake db:reset

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

## Setup Devise

### CERTOTRACK_SECRET_KEY

    export CERTOTRACK_SECRET_KEY=blahblahblah

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

#### Note that in one case, I had to do this:

    alter database certotrack_development owner to certouser;
    alter database certotrack_test owner to certouser;
    alter database certotrack_production owner to certouser;

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

# Development

## Builds
    build_unit => Build all but features
    build_all => Build all including features

# Deployment

### Tag sha to release
    git tag release-0.1 b4af07e
    git push
    git push --tags

### Deploy release to staging
    ./deploy-staging release-0.1

### Deploy release to production
    ./deploy-production release-0.1

# Reactivate Employee
    There is no UI at this point for reactivating employees, but there is a service.
    From the (production) rails console, run:

    EmployeeReactivationService.new.reactivate_employee(employee)

    after you've located the employee and stuffed them into a variable of the same name.
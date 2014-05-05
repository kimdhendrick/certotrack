Heroku README
============

## Setup

### Email settings

Use 'heroku config' to see/set/get environment variables.
These values are loaded by config/initializers/setup_mail.rb.

    CERTOTRACK_EMAIL_ADDRESS:    smtp.sendgrid.net
    CERTOTRACK_EMAIL_DOMAIN:     heroku.com
    CERTOTRACK_EMAIL_PORT:       587
    CERTOTRACK_EMAIL_PASSWORD:   see 1password or heroku (set to same as SENDGRID_PASSWORD)
    CERTOTRACK_EMAIL_USERNAME:   see 1password or herok (set to same as SENDGRID_USERNAME)
    CERTOTRACK_SECRET_KEY:       see 1password or heroku

SendGrid: https://sendgrid.com/account/overview

### Scheduler settings

Modify these at: https://scheduler.heroku.com/dashboard

Daily jobs @ 15:00 UTC for each of these:

    rake notification:equipment:daily:expired

    rake notification:equipment:daily:expiring

    if [ "$(date +%u)" = 1 ]; then rake notification:equipment:weekly:expired; fi

    if [ "$(date +%u)" = 1 ]; then rake notification:equipment:weekly:expiring; fi

    rake notification:certification:daily:expired

    rake notification:certification:daily:expiring

    if [ "$(date +%u)" = 1 ]; then rake notification:certification:weekly:expired; fi

    if [ "$(date +%u)" = 1 ]; then rake notification:certification:weekly:expiring; fi

## Heroku cheatsheet

### Rake tasks
    heroku run rake <...>

### Rails Console
    heroku run rails console
    heroku pg:psql

### Get database stats
    heroku pg

### Recreate database (does not migrate or seed)
    heroku pg:reset DATABASE

### Migrate database
    heroku run rake db:migrate

### Reseed database
    heroku run rake db:seed

### Restart heroku
    heroku restart

### Push tag to heroku
    git push certotrack-staging <tag-name>:master
    git push certotrack <tag-name>:master
    (go back to master)
    git push -f certotrack-staging master

### Setting config values on heroku

https://devcenter.heroku.com/articles/config-vars

    heroku config:set GITHUB_USERNAME=joesmith
    heroku config
    heroku config:get GITHUB_USERNAME
    heroku config:unset GITHUB_USERNAME

### PG Backup

#### List backups
    heroku pgbackups

#### Create backup
    heroku pgbackups:capture

#### Download backup
    heroku pgbackups:url

#### View documentation
    heroku addons:docs pgbackups


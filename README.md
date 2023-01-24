# Monica Reminder

Monica reminder is a BASH script that will takeover the emailing of reminders
for a Monica instance if you are experiencing problems. It is highly
configurable and logs all its decisions.

It expects to be run at least daily however it can recover from multiple days of
downtime and will email any missed reminders, marking them as "[LATE]". At the
moment it has some restrictions but these will be fixed over time:

* Only handles yearly reminders.
* Hard-coded to send reminders at 0, 7 and 30 days ahead of an event.
* Hard-coded to ignore any events older than a month.

## Table of Contents

<!-- vim-markdown-toc GitLab -->

* [Background](#background)
* [Installation](#installation)
* [Usage](#usage)
* [Configuration](#configuration)
  * [Required Configuration](#required-configuration)
  * [Optional Configuration](#optional-configuration)
* [How it Works](#how-it-works)
* [Troubleshooting](#troubleshooting)
* [Roadmap](#roadmap)
* [Implementation Notes](#implementation-notes)

<!-- vim-markdown-toc -->

## Background

My own self-hosted Monica instance is wonderful to use but reminders never quite
seem to work. The authors of Monica are hard at work on a [full rewrite](https://www.monicahq.com/blog/a-new-version-is-coming)
so a pull request seems unlikely to succeed. Instead I decided to fix it from
the outside with a BASH script that takes over reminders completely.

## Installation

You should already have a working Monica instance and test emails should work:

```bash
php artisan monica:test-email
```

If not start here: [mail settings (Monica docs)](https://github.com/monicahq/monica/blob/main/docs/installation/mail.md)

Our instructions assume monica-reminder will run inside the same container as
Monica. This makes life easy as they share many of the same environment
variables for configuration. It can also be run from outside a container but
you'd need to setup more configuration yourself.

At present we have to modify the container to install monica-reminder.
This can be done by running a shell inside the container for testing but
longer-term should be put into a Dockerfile so it survives restart.

We use `msmtp` for emailing. Inside the container:

```bash
apt-get update
apt-get install -y msmtp
```

Git clone this repo and install the script into the monica container from the
host. We choose a destination that should be a Docker volume so will survive
restarts:

```bash
# podman users
podman cp monica_reminder monica:/var/www/html/storage/monica_reminder
# docker users
docker cp monica_reminder monica:/var/www/html/storage/monica_reminder
```

## Usage

Back inside the container let's test out `monica_reminder` for the first time:

```bash
LOGDIR=- DRYRUN=true ./monica_reminder
```

`LOGDIR=-` sends logs to stdout and `DRYRUN=true` means no email will be sent
and no state will be saved. Check if the output looks correct based on the
reminders you might expect for your contacts.

Before you start running monica-reminder for real consider that on the first
run it may send out a lot of emails as it starts from nothing. This might be ok
but if you don't want to bombard your users you can instead do a one-off
catch-up run with emails disabled:

```bash
NOSEND=true ./monica_reminder
```

To ensure you get daily reminders schedule a cron job in the container and
restart/reload cron. I am using supervisord so can simply kill the `busybox
cron` process as it will be restarted automatically by supervisord:

```bash
# e.g. 12:00 every day
echo "0 12 * * * bash /var/www/html/storage/monica_reminder" >> /var/spool/cron/crontabs/www-data
pkill busybox
```

To put these installation steps into a Dockerfile you might try this:

```dockerfile
RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        supervisor \
        msmtp \
    ; \
    rm -rf /var/lib/apt/lists/*

RUN echo "0 12 * * * bash /var/www/html/storage/monica_reminder" >> /var/spool/cron/crontabs/www-data
```

## Configuration

Monica-reminder relies on environment variables for configuration. Some are
required but may be part of your Monica setup already. Others are optional for
testing and doing dry runs etc.

### Required Configuration

Monica-reminder needs to reach the Monica database. These environment variables
are the same ones Monica uses so should already be set up:

```bash
DB_HOST
DB_PASSWORD
```

For an example see
[.env.example](https://github.com/monicahq/monica/blob/main/.env.example) in the
Monica repo.

Monica-reminder needs to send email. The environment variables below are needed.
Again they should also already be set if you have a working Monica email
configuration:

```bash
MAIL_HOST
MAIL_PORT
MAIL_USERNAME
MAIL_FROM_NAME
MAIL_FROM_ADDRESS
MAIL_PASSWORD
```

See [mail settings (Monica docs)](https://github.com/monicahq/monica/blob/main/docs/installation/mail.md)
for how to work with these.

### Optional Configuration

There are several options set through further environment variables that control
execution of monica-reminder:

```bash
DRYRUN
TODAY
NOSEND
LOGDIR
LOGROTATEDAY
DATA_HOME
```

**DRYRUN=true|false** If true then don't send any email, don't write any state
(default=false). This is to allow a user to see what will happen without
consequences. Useful to combine with `LOGDIR=-` so logs are written to stdout
and/or `TODAY` to see what would happen on a different day.

**TODAY=YYYY-MM-DD** Change what monica-reminder thinks of as 'today', by
default it will ask the system for the date. This allows you to see what it will
do on any date in the past/present. Might want to combine with `DRYRUN` and/or
`LOGDIR=-`. It can accept any date format unstandable by `date`.

**NOSEND=true|false** If true send no email (default=false). This will process
reminders and remember what it has been seen but will simply not send any email.
Useful if you want monica-reminder to 'catch-up' on reminders but don't want to
be bombarded with email. This is ideal for a first run where you don't want to
receive a lot of emails for events that have just passed.

**LOGDIR=/PATH|-** Set a path for where monica-reminder should log or to use
stdout use `-`. Default is `/var/www/html/storage/logs` which is correct for
Docker instances. Monica-reminder will create a log file for each run postfixed
with a timestamp.

**LOGROTATEDAY=10** Monica-reminder will rotate its own logs deleting those
older than the number of days specified here. Default is 10 days.

**DATA_HOME=/PATH** Base path for monica-reminder to save its state
(default=`/var/www/html/storage`). It will create a dir inside this dir
called `monica_reminder_data` and simply touch a file for each reminder, user
and reminder date it has seen. This prevents monica-reminder repeating itself.

## How it Works

Monica-reminder's flow is:

* Check what day it is TODAY (can be configured, see below)
* Fetch all reminders and users from the Monica database
* For each reminder and each user:
  * Consult our saved state in `DATA_HOME` - if we've already dealt with this
    reminder skip it.
  * Any reminders due for the future can be ignored.
  * If the event is too far in the past (1 month) mark it as dealt with and
    ignore it.
  * Send any reminders that should have sent before TODAY with the subject
    prefixed with "[LATE]". Mark them as dealt with.
  * Send any reminder due today and mark them as dealt with.

Monica-reminder relies on its saved state in `DATA_HOME` to remember what is has
done in the past so as not to repeat itself. This is simple a directory of files
and can be cleared if needed to reset.

## Troubleshooting

Not receiving any email? Ensure this test-email command works first in your
instance:

```bash
php artisan monica:test-email
```

Check monica-reminder's logs at `LOGDIR` (default `/var/www/html/storage/logs`)
for any issues. If it is running ok it may just be the case that no reminders
are due right now.

## Roadmap

* Get tests over it all
* Simplify installation - container/host mode - given a container name we inject
  and run ourselves. Needs its own preflight to check for podman docker cmd and
  container is running/avail.
  * Removes need to alter container so users can run Monica straight from source
  * Allows us to also use laravel emailing
* Change email template to include date of event and link to contact.
  or make it identical to Monica's.
* Make properly available for others
  * License etc galagos and version, install with bin
  * Reference in bugs
  * Version it - releash?
* Remove restrictions
  * Respect reminder intervals set per user. Note there seems to be a bug in
    Monica that users share reminder intervals though the DB table hints that
    they can be set per user(?)
  * Cope with one-offs properly
  * Other reminder frequencies: N week, month and year
  * Allow cutoff to be configurable
* Support other/all mailer methods as Monica does if not already done
  * We force TLS currently, support use of `START_TLS`. Check value of
    `MAIL_ENCRYPTION`. `ssl` means TLS and `tls` means STARTTLS confusingly.
    [laravel - How do I use STARTTLS with swiftmailer in php? - Stack Overflow](https://stackoverflow.com/questions/62577544/how-do-i-use-starttls-with-swiftmailer-in-php)
    So we'd need to switch on this env. var and feed it through to msmtp
  * This is intricate. It's handing off to Laravel's mailing facility and config
    so we would end up mimicking Laravel.

## Implementation Notes

Some questions below on how we can avoid altering the container so users can
always use latest Monica.

Can we insert the cron job via a bind mount?

* busybox cron does run as root but seems to ignore `etc/cron.d` where we
  might mount an extra file. Are we sure we have format right? What if we
  use a crontab for root and just change user `su` in the job?
* Tried root's crontab which works but we can't switch into the
  environment of www-data as it has nologin so we can't get all the MONICA
  settings.
* Other alternative is to somehow concat the cron line to www-data's
  crontab by some other means at restart...but this is getting v hacky and
  not going to work for everyone anyway. Leave it to user at this point.
* Or inject ourselves somehow into monica's laravel schedule but that
  looks like nothing short of a code change in Monica's kernel PHP.
* How about podman healthcheck? This is schedulable and runs on the host.
  Uses systemd timers. Might as well just use systemd directly though I guess?
  Or cron? On the host. Then we could as part of same step cp in our email
  command - or even `monica_reminder` does all this, copying
  itself into container, with its email command and then setting itself
  off? That's best.

Can we send email same way monica does? An artisan command we could insert?

* Here is there command:
  [monica/SendTestEmail.php at a5ff8fc247197c1ac2de2a17f75f0ebf1275c243 · monicahq/monica](https://github.com/monicahq/monica/blob/a5ff8fc247197c1ac2de2a17f75f0ebf1275c243/app/Console/Commands/SendTestEmail.php)
* Could we monkey-patch our own email command?
* DONE: Try creating own simple command to start, just echo
* DONE: Then make full email
* Install it to `/var/www/html/app/Console/Commands`
* At this point should we just publish our own container?

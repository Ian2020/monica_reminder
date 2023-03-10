<!--
SPDX-FileCopyrightText: 2023 Ian2020 <https://github.com/Ian2020>

SPDX-License-Identifier: CC-BY-SA-4.0

Monica reminder is a BASH script that will takeover the emailing of reminders
for a Monica instance if you are experiencing problems.

For full copyright information see the AUTHORS file at the top-level
directory of this distribution or at
[AUTHORS](https://github.com/Ian2020/monica_reminder/AUTHORS.md)

This work is licensed under the Creative Commons Attribution 4.0 International
License. You should have received a copy of the license along with this work.
If not, visit http://creativecommons.org/licenses/by/4.0/ or send a letter to
Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
-->

# Monica Reminder

Monica reminder is a BASH script that will takeover the emailing of reminders
for a [Monica](https://www.monicahq.com/) instance if you are experiencing
problems. It is highly configurable and logs all its decisions.

It expects to be run at least daily however it can recover from multiple days of
downtime and will email any missed reminders, marking them as "[LATE]". At the
moment it has some restrictions but these could be fixed over time:

* Hard-coded to send reminders at 0, 7 and 30 days ahead of an event.
* Doesn't disable Monica's own reminder mechanism, so some duplicates may be
  received.

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
* [Contributing](#contributing)
* [License](#license)

<!-- vim-markdown-toc -->

## Background

My own self-hosted Monica instance is wonderful to use but reminders never quite
seem to work. There are a few bugs on this: [#1638](https://github.com/monicahq/monica/issues/1638),
[#4178](https://github.com/monicahq/monica/issues/4178),
[#5681](https://github.com/monicahq/monica/issues/5681),
[#6134](https://github.com/monicahq/monica/issues/6134).
The authors of Monica are hard at work on a [full
rewrite](https://www.monicahq.com/blog/a-new-version-is-coming) so pull
requests seem unlikely to succeed in the meantime. Instead I decided to fix it
from the outside with a BASH script that takes over reminders completely.

## Installation

Install monica-reminder on your Monica host if running on bare metal/VM. If
Monica is running in a container install it on the container host.

To install with [bin](https://github.com/marcosnils/bin):

```bash
bin install https://github.com/Ian2020/monica_reminder
```

To install manually git clone this repo. Clone a tag to ensure you're on an
official version. Optionally copy `monica_reminder` to a dir on your PATH, e.g.
`/usr/local/bin`.

## Usage

Make sure you have **BACKUPS** before running monica-reminder. Whilst it should
never touch anything other than it's own logs/data I can't predict its behaviour
in every environment.

You should already have a working Monica instance and test emails should work
i.e. this command run on your Monica host results in you receiving an email:

```bash
php artisan monica:test-email
```

If not start here: [mail settings (Monica docs)](https://github.com/monicahq/monica/blob/main/docs/installation/mail.md)

First let's test `monica_reminder` - don't worry this won't save or send any
emails:

```bash
#
# Choose:
#
# If Monica is running in a container called 'monica':
#
CONTAINER=monica LOGDIR=- DRYRUN=true monica_reminder
#
# Or if running on bare metal/VM:
#
cd [MONICA BASE DIR e.g. /var/www/html]
LOGDIR=- DRYRUN=true monica_reminder
```

`LOGDIR=-` sends logs to stdout and `DRYRUN=true` means no email will be sent
and no state will be saved. `CONTAINER` causes monica-reminder to relaunch
itself inside the named container via podman or docker.

If you experience errors than look at the configuration section below but if
Monica is setup correctly than much of the configuration will default ok.

Check if the output looks correct based on the reminders you might expect for
your contacts. If it's all ok you're almost ready to run monica-reminder
regularly.

The final consideration is that on the first run it may send out a lot of emails
as it starts from nothing. This might be ok but if you don't want to bombard
your users you can instead do a one-off catch-up with emails disabled:

```bash
#
# Choose:
#
# If Monica is running in a container called 'monica':
#
CONTAINER=monica TODAY=yesterday NOSEND=true monica_reminder
#
# Or if running on bare metal/VM:
#
TODAY=yesterday NOSEND=true monica_reminder
```

`TODAY=yesterday` tells monica-reminder to work as if it was running yesterday, thus
clearing the backlog before today's run.

Now we're ready. To ensure you get daily reminders schedule a cron job/systemd
service on your host to simply run:

```bash
#
# Choose:
#
# If Monica is running in a container called 'monica':
#
CONTAINER=monica monica_reminder
#
# Or if running on bare metal/VM:
#
monica_reminder
```

Here's an example systemd service unit file `monica_reminder.service`:

```systemd
[Unit]
Description=Monica Reminder
Wants=monica_reminder.timer

[Service]
Type=oneshot
StandardOutput=journal
Environment=CONTAINER=monica
ExecStart=/bin/env bash -c 'CONTAINER=$CONTAINER monica_reminder'

[Install]
WantedBy=default.target
```

...and the corresponding timer file `monica_reminder.time` to fire at 6 a.m. (or
next nearest possible time):

```systemd
[Unit]
Description=Monica Reminder Daily

[Timer]
OnCalendar=*-*-* 06:00:00
Persistent=true

[Install]
WantedBy=monica_reminder.service
```

## Configuration

Monica-reminder relies on environment variables for configuration. Some are
required but may be part of your Monica setup already. Others are optional for
testing and doing dry runs etc.

### Required Configuration

Monica-reminder needs to reach the Monica database. These environment variables
are the same ones Monica uses so should already be set up on your monica host:

```bash
DB_HOST
DB_PASSWORD
```

For an example see
[.env.example](https://github.com/monicahq/monica/blob/main/.env.example) in the
Monica repo.

### Optional Configuration

There are several options set through further environment variables that control
execution of monica-reminder:

```bash
CONTAINER
DRYRUN
TODAY
NOSEND
LOGDIR
LOGROTATEDAY
DATA_HOME
MONICABASEDIR
```

**CONTAINER=NAME** Instead of running on the host relaunch monica-reminder
inside the named container. Any other configuration environment variables will
be passed through to the container process.

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
the official Docker container. Monica-reminder will create a log file for each
run postfixed with a timestamp.

**LOGROTATEDAY=10** Monica-reminder will rotate its own logs deleting those
older than the number of days specified here. Default is 10 days.

**DATA_HOME=/PATH** Base path for monica-reminder to save its state.
The default is `/var/www/html/storage` which is correct for the official Docker
container. It will create a dir inside this dir called `monica_reminder`
and simply touch a file for each reminder, user and reminder date it has seen.
This prevents monica-reminder repeating itself. It will automatically delete old
state so the dir cannot grow indefinately.

**MONICABASEDIR=/PATH** Path to the Monica install, the default is the current
working dir. This should be correct for running monica-reminder in your monica
container. If running on bare metal/VM you could switch to the correct dir
before running monica-reminder instead of setting this var. The correct path is
`/var/www/html` in the standard container or whereever the `artisan` file is
located.

## How it Works

Monica-reminder's flow is:

* Check what day it is TODAY (can be configured, see below)
* Fetch all events and users from the Monica database
* For each event and each user:
  * If it's a repeating event calculate the nearest occurence to today.
  * Consult our saved state in `DATA_HOME` - if we've already sent the expected
    reminders skip it.
  * Any reminders due for the future can be ignored.
  * If the event is too far in the past (1 month) mark it as dealt with and
    ignore it.
  * Send any reminders that should have sent before TODAY with the subject
    prefixed with "[LATE]". Mark them as dealt with.
  * Send any reminder due today and mark them as dealt with.

Monica-reminder relies on its saved state in `DATA_HOME` to remember what is has
done in the past so as not to repeat itself. This is simply a directory of files
and can be cleared if needed to reset.

## Troubleshooting

Not receiving any email? Ensure this test-email command works first in your
instance:

```bash
php artisan monica:test-email
```

Next check monica-reminder's logs at `LOGDIR` (default `/var/www/html/storage/logs`)
for any issues. If it is running ok it may just be the case that no reminders
are due right now.

## Roadmap

* Remove restrictions and pain points:
  * If a reminder interval is longer than the frequency on an event (e.g. 30 day
    reminder for a weekly event) than don't send that reminder as it'll always
    be late.
  * Respect reminder intervals set per user. Note there seems to be a bug in
    Monica that users share reminder intervals though the DB table hints that
    they can be set per user(?)
  * Allow cutoff to be configurable
  * Disable Monica's own reminder handling
* Change email template to include a link to contact. The link is not available
  from the database, it appears to be a route calculated inside Monica unf. Can
  we just plug into the existing code that sends reminder emails so we also gain
  translations?
* Test if monica-reminder works with 'stay in touch' reminders
  ["Stay in Touch", cron, and database connection issues ?? Issue #4842 ?? monicahq/monica](https://github.com/monicahq/monica/issues/4842)

## Contributing

It's great that you're interested in contributing. Please ask questions by
raising an issue and PRs will be considered. For full details see
[CONTRIBUTING.md](CONTRIBUTING.md)

## License

We declare our licensing by following the REUSE specification - copies of
applicable licenses are stored in the LICENSES directory. Here is a summary:

* Source code is licensed under GPL-3.0-or-later.
* Anything else that is not executable, including the text when extracted from
  code, is licensed under CC-BY-SA-4.0.
* Where we use a range of copyright years it is inclusive and shorthand for
  listing each year individually as a copyrightable year in its own right.

For more accurate information, check individual files.

monica-reminder is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

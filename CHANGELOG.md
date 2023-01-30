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

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.3 - 2023-01-26](https://github.com/Ian2020/monica_reminder/releases/tag/v0.0.3)

### Added

* Cope with all frequencies of events Monica supports: N yearly, N monthly, N
  weekly and one-offs. Note that our hard-coded seting of 7/30 day reminders
  means for any event that occurs more frequently than 30 days will always have
  a late 30 day reminder. We should fix this in future.

## [0.0.2 - 2023-01-26](https://github.com/Ian2020/monica_reminder/releases/tag/v0.0.2)

### Added

* Reminder emails now include the date of the event in the body.
* We now clean up old state to prevent `DATA_HOME` growing forever. Anything older
  than 500 days as we should remember things we sent a bit over a year ago.

### Removed

* Our dependency on `msmtp` is no longer needed. Now we use Monica's own
  mechanism to send email. This means no need to change your Monica
  system/container at all simplifying installation.

## [0.0.1 - 2023-01-25](https://github.com/Ian2020/monica_reminder/releases/tag/v0.0.1)

### Added

* README: instructions on installing with bin and example systemd timer and
  service files.

### Changed

* `DATA_HOME` dir renamed `monica_reminder_data` -> `monica_reminder`.

## [0.0.0 - 2023-01-25](https://github.com/Ian2020/monica_reminder/releases/tag/v0.0.0)

### Added

* Basic functionality complete.
* We support installation via [bin](https://github.com/marcosnils/bin) due to
  this GitHub release.

#!/usr/bin/env bats

# SPDX-FileCopyrightText: 2023 Ian2020 <https://github.com/Ian2020>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Monica reminder is a BASH script that will takeover the emailing of reminders
# for a Monica instance if you are experiencing problems.
#
# For full copyright information see the AUTHORS file at the top-level
# directory of this distribution or at
# [AUTHORS](https://github.com/Ian2020/monica_reminder/AUTHORS.md)
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <https://www.gnu.org/licenses/>.

source "$BATS_TEST_DIRNAME"/../monica_reminder
load test_helper/bats-support/load
load test_helper/bats-assert/load

@test "log: to stdout when not initialised" {
  # This ensures we log to stdout when monica_reminder is dot sourced for testing etc
  run log "something"
  assert [ "$status" -eq 0 ]
  assert [ "$output" = "monica_reminder: something" ]
}

@test "log: to stdout when logdir='-'" {
  # We cannot use bats' run here as we need initlogging and log to share same scope
  LOGDIR="-"
  initlogging
  output=$(log "something")
  rc=$?

  assert [ "$rc" -eq 0 ]
  assert [ "$output" = "monica_reminder: something" ]
}

@test "log: to file when logdir set" {
  # We cannot use bats' run here as we need initlogging and log to share same scope
  LOGDIR=$(mktemp -d)
  initlogging
  output=$(log "something")
  rc=$?

  logfile=$(find "$LOGDIR" -type f)
  assert [ "$rc" -eq 0 ]
  assert [ "$output" = "" ]
  assert [ "$(cat "$logfile")" = "something" ]
}


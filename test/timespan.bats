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

@test "invalid dates" {
  run timespan "XXXX" "2001-01-02" "year" ; assert [ "$status" -eq 1 ]
  run timespan "2001-01-02" "XXXX" "year" ; assert [ "$status" -eq 1 ]
  run timespan "" "2001-01-2" "year" ; assert [ "$status" -eq 1 ]
  run timespan "2001-01-2" "" "year" ; assert [ "$status" -eq 1 ]
}

@test "invalid dates - date2 before date1" {
  run timespan "2002-01-02" "2001-01-02" "year" ; assert [ "$status" -eq 1 ]
}

@test "invalid quanta" {
  run timespan "2000-01-02" "2001-01-02" "nonsense" ; assert [ "$status" -eq 1 ]
}

@test "seconds: one day" {
  run timespan "2001-01-01" "2001-01-02" "second"

  assert [ "$status" -eq 0 ]
  assert [ "$output" = $(( 60 * 60 * 24 )) ]
}

@test "seconds: one week" {
  run timespan "2001-01-01" "2001-01-08" "second"

  assert [ "$status" -eq 0 ]
  assert [ "$output" = $(( 60 * 60 * 24 * 7 )) ]
}

@test "seconds: thirty years" {
  run timespan "1970-01-01" "2000-01-01" "second"

  assert [ "$status" -eq 0 ]
  assert [ "$output" = 946688400 ]
}

@test "weeks: zero weeks" {
  # One day
  run timespan "2001-01-01" "2001-01-02" "week" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 0 ]
  # Just shy one week
  run timespan "2001-01-01" "2001-01-07" "week" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 0 ]
  # Just shy across a month end
  run timespan "2001-01-30" "2001-02-05" "week" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 0 ]
}

@test "weeks: one week" {
  # One week
  run timespan "2001-01-01" "2001-01-08" "week" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 1 ]
  # Just short two weeks
  run timespan "2001-01-01" "2001-01-14" "week" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 1 ]
  # Just short across a month
  run timespan "2001-01-20" "2001-02-02" "week" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 1 ]
}

@test "weeks: multiple weeks" {
  run timespan "2001-01-01" "2001-09-08" "week" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 35 ]
}

@test "months: zero months" {
  run timespan "2001-01-01" "2001-01-08" "month" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 0 ]
  run timespan "2001-01-05" "2001-02-01" "month" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 0 ]
}

@test "months: one month" {
  run timespan "2001-01-01" "2001-02-01" "month" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 1 ]
  run timespan "2001-01-05" "2001-02-10" "month" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 1 ]
}

@test "months: multiple months" {
  run timespan "2001-05-15" "2002-03-01" "month" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 9 ]
  run timespan "2001-01-01" "2003-02-01" "month" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 25 ]
}

@test "years: zero years" {
  # One day
  run timespan "2001-01-01" "2001-01-02" "year" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 0 ]
  # Few months
  run timespan "2001-01-01" "2001-09-02" "year" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 0 ]
  # Cross a year boundary
  run timespan "2001-09-01" "2002-08-02" "year" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 0 ]
  # Just one day shy
  run timespan "2001-01-02" "2002-01-01" "year" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 0 ]
}

@test "years: one year" {
  # Exactly one year
  run timespan "2001-01-01" "2002-01-01" "year" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 1 ]
  run timespan "2001-04-06" "2002-04-06" "year" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 1 ]
  # Over a year but not two
  run timespan "2001-01-01" "2002-06-01" "year" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 1 ]
  # Just short two years
  run timespan "2001-01-01" "2002-12-31" "year" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 1 ]
}

@test "years: multiple years" {
  run timespan "2001-04-06" "2008-04-06" "year" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 7 ]
  run timespan "2001-04-06" "2008-03-06" "year" ; assert [ "$status" -eq 0 ] ; assert [ "$output" = 6 ]
}

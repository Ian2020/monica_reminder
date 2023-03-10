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

bats_require_minimum_version 1.5.0

source "$BATS_TEST_DIRNAME"/../monica_reminder
load test_helper/bats-support/load
load test_helper/bats-assert/load

@test "event is today" {
  run -0 nearest_occurence "2001-01-01" "2001-01-01" "year" "1"
  assert [ "$output" = "2001-01-01" ]
}

@test "event in the future: its always its own nearest occurence" {
  run -0 nearest_occurence "2001-01-01" "2004-01-01" "year" "1"
  assert [ "$output" = "2004-01-01" ]
}

@test "weekly event: two days later" {
  run -0 nearest_occurence "2000-01-03" "2000-01-01" "week" "1"
  assert [ "$output" = "2000-01-01" ]
}

@test "weekly event: five days later" {
  run -0 nearest_occurence "2000-01-06" "2000-01-01" "week" "1"
  assert [ "$output" = "2000-01-08" ]
}

@test "biweekly event: five days later" {
  run -0 nearest_occurence "2000-01-06" "2000-01-01" "week" "2"
  assert [ "$output" = "2000-01-01" ]
}

@test "biweekly event: eight days later" {
  run -0 nearest_occurence "2000-01-09" "2000-01-01" "week" "2"
  assert [ "$output" = "2000-01-15" ]
}

@test "monthly event: a week later" {
  run -0 nearest_occurence "2000-01-08" "2000-01-01" "month" "1"
  assert [ "$output" = "2000-01-01" ]
}

@test "monthly event: three weeks later" {
  run -0 nearest_occurence "2000-01-22" "2000-01-01" "month" "1"
  assert [ "$output" = "2000-02-01" ]
}

@test "bimonthly event: three weeks later" {
  run -0 nearest_occurence "2000-01-22" "2000-01-01" "month" "2"
  assert [ "$output" = "2000-01-01" ]
}

@test "bimonthly event: five weeks later" {
  run -0 nearest_occurence "2000-02-05" "2000-01-01" "month" "2"
  assert [ "$output" = "2000-03-01" ]
}

@test "yearly event: exactly a year later" {
  run -0 nearest_occurence "2001-01-01" "2000-01-01" "year" "1"
  assert [ "$output" = "2001-01-01" ]
}

@test "yearly event: 8 months later" {
  run -0 nearest_occurence "2000-09-01" "2000-01-01" "year" "1"
  assert [ "$output" = "2001-01-01" ]
}

@test "yearly event: 5 months later" {
  run -0 nearest_occurence "2000-06-01" "2000-01-01" "year" "1"
  assert [ "$output" = "2000-01-01" ]
}

@test "biyearly event: 8 months later" {
  run -0 nearest_occurence "2000-09-01" "2000-01-01" "year" "2"
  assert [ "$output" = "2000-01-01" ]
}

@test "biyearly event: 12 months later" {
  run -0 nearest_occurence "2001-01-01" "2000-01-01" "year" "2"
  assert [ "$output" = "2002-01-01" ]
}

@test "one-time event: months after" {
  run -0 nearest_occurence "2000-06-01" "2000-01-01" "one_time" "1"
  assert [ "$output" = "2000-01-01" ]
}

@test "one-time event: years after" {
  run -0 nearest_occurence "2009-06-01" "2000-01-01" "one_time" "1"
  assert [ "$output" = "2000-01-01" ]
}

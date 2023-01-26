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

@test "unknown frequency: return very old date" {
  run nearest_occurence "2001-01-01" "2000-01-01" "nonsense"

  assert [ "$status" -eq 0 ]
  assert [ "$output" = "1970-01-01" ]
}

@test "yearly event: exactly a year later" {
  run nearest_occurence "2001-01-01" "2000-01-01" "year"

  assert [ "$status" -eq 0 ]
  assert [ "$output" = "2001-01-01" ]
}

@test "yearly event: 8 months later" {
  run nearest_occurence "2000-09-01" "2000-01-01" "year"

  assert [ "$status" -eq 0 ]
  assert [ "$output" = "2001-01-01" ]
}

@test "yearly event: 5 months later" {
  run nearest_occurence "2000-06-01" "2000-01-01" "year"

  assert [ "$status" -eq 0 ]
  assert [ "$output" = "2000-01-01" ]
}

@test "one-time event: months after" {
  run nearest_occurence "2000-06-01" "2000-01-01" "one_time"

  assert [ "$status" -eq 0 ]
  assert [ "$output" = "2000-01-01" ]
}

@test "one-time event: years after" {
  run nearest_occurence "2009-06-01" "2000-01-01" "one_time"

  assert [ "$status" -eq 0 ]
  assert [ "$output" = "2000-01-01" ]
}

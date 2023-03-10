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

@test "bad date" {
  run -1 movedate "XXX" "year" "1"
}

@test "bad freq" {
  run -1 movedate "XXX" "nonsense" "1"
}

@test "bad freq_num" {
  run -1 movedate "XXX" "year" "a"
}

@test "years" {
  run -0 movedate "2001-01-02" "year" "1"
  assert [ "$output" = "2002-01-02" ]
  run -0 movedate "2001-01-02" "year" "5"
  assert [ "$output" = "2006-01-02" ]
  run -0 movedate "2001-01-02" "year" "10"
  assert [ "$output" = "2011-01-02" ]
}

@test "months" {
  run -0 movedate "2001-01-02" "month" "1"
  assert [ "$output" = "2001-02-02" ]
  run -0 movedate "2001-09-02" "month" "6"
  assert [ "$output" = "2002-03-02" ]
  run -0 movedate "2001-01-02" "month" "12"
  assert [ "$output" = "2002-01-02" ]
  run -0 movedate "2001-01-02" "month" "18"
  assert [ "$output" = "2002-07-02" ]
}

@test "months - moving into shorter months" {
  run -0 movedate "2001-01-30" "month" "1"
  assert [ "$output" = "2001-02-28" ]
  run -0 movedate "2001-03-31" "month" "1"
  assert [ "$output" = "2001-04-30" ]
}

@test "months - moving into feb in a leap year" {
  run -0 movedate "2016-01-30" "month" "1"
  assert [ "$output" = "2016-02-29" ]
}

@test "weeks" {
  run -0 movedate "2001-01-02" "week" "1"
  assert [ "$output" = "2001-01-09" ]
  run -0 movedate "2001-01-02" "week" "2"
  assert [ "$output" = "2001-01-16" ]
  run -0 movedate "2001-01-02" "week" "10"
  assert [ "$output" = "2001-03-13" ]
}

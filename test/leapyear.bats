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

@test "non-leap years" {
  run -0 leapyear "1900" ; assert [ "$output" = "false" ]
  run -0 leapyear "2022" ; assert [ "$output" = "false" ]
}

@test "leap years" {
  run -0 leapyear "2016" ; assert [ "$output" = "true" ]
  run -0 leapyear "2020" ; assert [ "$output" = "true" ]
  run -0 leapyear "2024" ; assert [ "$output" = "true" ]
}

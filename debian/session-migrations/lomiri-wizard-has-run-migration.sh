#!/bin/sh -euf

# Copyright (C) 2021 UBports Foundation
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Authored by: Ratchanan Srirattanamet <ratchanan@ubports.com>

OLD_FILE="${HOME}/.config/ubuntu-system-settings/wizard-has-run"
NEW_FILE="${HOME}/.config/lomiri/wizard-has-run"

if [ -e "$NEW_FILE" ]; then
    echo "${NEW_FILE} exists. Perhaps the migration has already" \
         "happened, and/or the user has run the wizard since."
    exit 0
fi

if [ -e "$OLD_FILE" ]; then
    mkdir -p "$(dirname "$NEW_FILE")"
    cp -a "$OLD_FILE" "$NEW_FILE"

    echo "Lomiri wizard-has-run file is migrated."
fi
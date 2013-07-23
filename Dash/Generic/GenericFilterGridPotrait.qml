/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import "../../Components"

GenericFilterGrid {
    id: filtergrid

    minimumHorizontalSpacing: units.gu(0.5)
    delegateWidth: units.gu(11)
    delegateHeight: units.gu(18)
    verticalSpacing: units.gu(2)

    iconWidth: (width / columns) * 0.8
    iconHeight: iconWidth * 16 / 11
}

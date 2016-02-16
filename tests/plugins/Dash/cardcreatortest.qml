/*
 * Copyright (C) 2014 Canonical, Ltd.
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

import QtQuick 2.4
import "../../../plugins/Dash/CardCreator.js" as CardCreator

Item {
    id: root
    function cardString(template, components, isCardCreator) {
        return CardCreator.cardString(JSON.parse(template), JSON.parse(components), isCardCreator);
    }

    function createCardComponent(template, components, isCardCreator) {
        return CardCreator.createCardComponent(root, JSON.parse(template), JSON.parse(components), isCardCreator) !== null;
    }
}

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

pragma Singleton
import QtQuick 2.4
import "CardCreator.js" as CardCreator

QtObject {
    id: root

    property var cache: new Object();

    function getCardComponent(template, components) {
        if (template === undefined || components === undefined)
            return undefined;

        var tString = JSON.stringify(template);
        var cString = JSON.stringify(components);
        var allString = tString + cString;
        var component = cache[allString];
        if (component === undefined) {
            component = CardCreator.createCardComponent(root, template, components, allString);
            cache[allString] = component;
        }
        return component;
    }
}

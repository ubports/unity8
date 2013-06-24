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

.pragma library

// FIXME: a quick hack to get icons out of gicons and fallback to
// base icon for annotated icons. Doesn't correctly handle all icons.
// Proper global solution needed.
function from_gicon(name) {
    var icon_name = name;
    var annotated_re = /^. UnityProtocolAnnotatedIcon/;
    if (annotated_re.test(name)) {
        var base_icon_re = /'base-icon':.+?'(.+?)'/;
        var base_icon = name.toString().match(base_icon_re);
        icon_name = base_icon[1];
    } else {
        var themed_re = /^. GThemedIcon\s*([^\s]+)\s*/;
        var themed = name.match(themed_re);
        if (themed) {
            return "image://gicon/" + themed[1];
        }
    }
    var name_re = /^[a-z-]+$/;
    if (name_re.test(icon_name)) {
        return "image://gicon/" + icon_name;
    } else {
        return icon_name;
    }
}

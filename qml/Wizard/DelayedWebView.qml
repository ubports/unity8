/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import Ubuntu.Web 0.2

// FIXME: we use this separate file to avoid import Ubuntu.Web, because we're
// seeing freezes in unity8 after the wizard shuts down, seemingly due to oxide?
// So for now, as a hotfix, we only load the webview when necessary.
// Also see Wizard.qml, where we avoid unloading the wizard at all for
// similar mitigation reasons while we root-cause the problem.
WebView {
}

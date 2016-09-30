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
import Ubuntu.Components 1.3
import Unity.Application 0.1
import Unity.ApplicationMenu 0.1
import Unity.Indicators 0.1 as Indicators
import Unity.Test 0.1
import Utils 0.1
import QMenuModel 0.1

import "../../../qml/Stages"

Item {
    id: root
    width:  units.gu(70)
    height:  units.gu(50)

    Component.onCompleted: {
        QuickUtils.keyboardAttached = true;
        theme.name = "Ubuntu.Components.Themes.SuruDark"

        ApplicationMenuRegistry.RegisterSurfaceMenu("dialerAppSurfaceId", "/dialerapp", "/dialerapp", ":2");
        Indicators.UnityMenuModelCache.setCachedModelData("/dialerapp", appMenuData.dialerData);

        fakeApplication = ApplicationManager.add("dialer-app");
        fakeApplication.manualSurfaceCreation = true;
        fakeApplication.setState(ApplicationInfoInterface.Starting);

        fakeSurface = SurfaceManager.createSurface("dialerAppSurface",Mir.NormalType, Mir.MaximizedState, fakeApplication);
        fakeApplication.setState(ApplicationInfoInterface.Running);
    }
    property QtObject fakeApplication: null
    property QtObject fakeSurface: null

    Binding {
        target: MouseTouchAdaptor
        property: "enabled"
        value: false
    }

    DesktopMenuData { id: appMenuData }

    Item {
        anchors.fill: parent
        anchors.margins: units.gu(2)

        DecoratedWindow {
            id: window
            active: true
            requestedHeight: parent.height
            requestedWidth: parent.width

            application: fakeApplication
            surface: fakeSurface
            focus: true
        }
    }

    UnityTestCase {
        id: testCase
        name: "DecoratedWindow"
        when: windowShown

        function init() {
        }
    }
}

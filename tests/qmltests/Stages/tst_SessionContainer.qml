/*
 * Copyright 2014 Canonical Ltd.
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
import QtTest 1.0
import Unity.Test 0.1 as UT
import Unity.Application 0.1
import "../../../qml/Stages"

Item {
    id: shell
    width: units.gu(40)
    height: units.gu(80)

    Repeater {
        anchors.fill: parent
        model: ApplicationManager

        delegate: SessionContainer {
            id: container
            anchors.fill: parent
            objectName: appId

            session: model.session
        }
    }

    SignalSpy {
        id: sessionSpy
        target: SessionManager
        signalName: "sessionDestroyed"
    }

    UT.UnityTestCase {
        id: testCase
        name: "SessionContainer"

        function init() {
            sessionSpy.clear();
        }

        when: windowShown

        function test_add_child_session_data() {
            return [ { tag: "count=1", count: 1 },
                     { tag: "count=4", count: 4 } ];
        }

        function test_add_child_session(data) {
            var unity8dash = findChild(shell, "unity8-dash");
            verify(unity8dash !== null);
            compare(unity8dash.childSessions.count(), 0);

            var i;
            var sessions = [];
            for (i = 0; i < data.count; i++) {
                sessions.push(ApplicationTest.addChildSession("unity8-dash", 0, Qt.resolvedUrl("../Dash/artwork/music-player-design.png")));
                compare(unity8dash.childSessions.count(), i+1);
            }

            for (i = data.count-1; i >= 0; i--) {
                ApplicationTest.removeSession(sessions[i]);
                tryCompareFunction(function() { return unity8dash.childSessions.count(); }, i);
            }
            tryCompare(sessionSpy, "count", data.count)
        }

        function test_nest_child_sessions_data() {
            return [ { tag: "depth=2", depth: 2 },
                     { tag: "depth=8", depth: 8 }
            ];
        }

        function test_nest_child_sessions(data) {
            var unity8dash = findChild(shell, "unity8-dash");
            verify(unity8dash !== null);
            compare(unity8dash.childSessions.count(), 0);

            var i;
            var sessions = [];
            var lastSessionId = 0;
            var delegate;
            var sessionContainer = unity8dash;
            for (i = 0; i < data.depth; i++) {
                lastSessionId = ApplicationTest.addChildSession("unity8-dash", lastSessionId, Qt.resolvedUrl("Dash/artwork/music-player-design.png"))
                sessions.push(lastSessionId);
                compare(sessionContainer.childSessions.count(), 1);

                delegate = findChild(sessionContainer, "childDelegate0");
                sessionContainer = findChild(delegate, "sessionContainer");
            }

            for (i = data.depth-1; i >= 0; i--) {
                ApplicationTest.removeSession(sessions[i]);
            }

            tryCompareFunction(function() { return unity8dash.childSessions.count(); }, 0);
            tryCompare(sessionSpy, "count", data.depth)
        }
    }
}

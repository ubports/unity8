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
    id: root
    width: units.gu(40)
    height: units.gu(80)


    property QtObject fakeApplication: null

    SessionContainer {
        id: sessionContainer
        anchors.fill: parent

        session: SessionManager.createSession("music-player", Qt.resolvedUrl("../Dash/artwork/music-player-design.png"));
        onSessionChanged: {
            session.manualSurfaceCreation = true;
            session.createSurface();
        }
    }

    SignalSpy {
        id: sessionSpy
        target: SessionManager
        signalName: "sessionStopping"
    }

    UT.UnityTestCase {
        id: testCase
        name: "SessionContainer"

        function init() {
            sessionSpy.clear();
        }

        when: windowShown

        function test_addChildSession_data() {
            return [ { tag: "count=1", count: 1 },
                     { tag: "count=4", count: 4 } ];
        }

        function test_addChildSession(data) {
            compare(sessionContainer.childSessions.count(), 0);

            var i;
            var sessions = [];
            for (i = 0; i < data.count; i++) {
                var session = SessionManager.createSession(sessionContainer.session.name + "-Child" + i,
                                                           Qt.resolvedUrl("../Dash/artwork/music-player-design.png"))
                sessionContainer.session.addChildSession(session);
                compare(sessionContainer.childSessions.count(), i+1);

                sessions.push(session);
            }

            for (i = data.count-1; i >= 0; i--) {
                sessions[i].release();
                tryCompareFunction(function() { return sessionContainer.childSessions.count(); }, i);
            }
            tryCompare(sessionSpy, "count", data.count)
        }

        function test_nestedChildSessions_data() {
            return [ { tag: "depth=2", depth: 2 },
                     { tag: "depth=8", depth: 8 }
            ];
        }

        function test_nestedChildSessions(data) {
            compare(sessionContainer.childSessions.count(), 0);

            var i;
            var sessions = [];
            var lastSession = sessionContainer.session;
            var delegate;
            var container = sessionContainer;
            for (i = 0; i < data.depth; i++) {
                var session = SessionManager.createSession(lastSession.name + "-Child" + i,
                                                           Qt.resolvedUrl("../Dash/artwork/music-player-design.png"))
                lastSession.addChildSession(session);
                compare(container.childSessions.count(), 1);
                sessions.push(session);

                delegate = findChild(container, "childDelegate0");
                container = findChild(delegate, "sessionContainer");
                lastSession = session;
            }

            for (i = data.depth-1; i >= 0; i--) {
                sessions[i].release();
            }

            tryCompareFunction(function() { return sessionContainer.childSessions.count(); }, 0);
            tryCompare(sessionSpy, "count", data.depth)
        }
    }
}

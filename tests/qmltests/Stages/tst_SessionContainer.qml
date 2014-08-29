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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtTest 1.0
import Unity.Test 0.1 as UT
import Ubuntu.Components 0.1
import Unity.Application 0.1
import "../../../qml/Stages"

Rectangle {
    color: "red"
    id: root
    width: units.gu(80)
    height: units.gu(70)

    Connections {
        target: sessionContainerLoader.status === Loader.Ready ? sessionContainerLoader.item : null
        onSessionChanged: {
            sessionCheckbox.checked = sessionContainerLoader.item.session !== null
        }
    }

    Component {
        id: sessionContainerComponent

        SessionContainer {
            id: sessionContainer
            anchors.fill: parent
        }
    }

    Loader {
        id: sessionContainerLoader
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        width: units.gu(40)
        sourceComponent: sessionContainerComponent
    }

    Rectangle {
        color: "white"
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: sessionContainerLoader.right
            right: parent.right
        }

        ColumnLayout {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
            spacing: units.gu(1)

            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: sessionCheckbox;
                    checked: false;
                    onCheckedChanged: {
                        if (sessionContainerLoader.status !== Loader.Ready)
                            return;

                        if (checked) {
                            var fakeSession = SessionManager.createSession("music-player", Qt.resolvedUrl("../Dash/artwork/music-player-design.png"));
                            sessionContainerLoader.item.session = fakeSession;
                            fakeSession.createSurface();
                        } else {
                            sessionContainerLoader.item.session.release();
                        }
                    }
                }

                Label {
                    text: "session"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                border {
                    color: "black"
                    width: 1
                }
                anchors {
                    left: parent.left
                    right: parent.right
                }
                Layout.preferredHeight: sessionChildrenControl.height

                RecursingChildSessionControl {
                    id: sessionChildrenControl
                    anchors { left: parent.left; right: parent.right; }

                    session: sessionContainerLoader.item.session
                }
            }
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
            // reload our test subject to get it in a fresh state once again
            sessionContainerLoader.active = false;
            sessionCheckbox.checked = false;
            sessionContainerLoader.active = true;

            tryCompare(sessionContainerLoader.item, "session", null);
            sessionSpy.clear();
        }

        when: windowShown

        function test_addChildSession_data() {
            return [ { tag: "count=1", count: 1 },
                     { tag: "count=4", count: 4 } ];
        }

        function test_addChildSession(data) {
            sessionCheckbox.checked = true;
            var sessionContainer = sessionContainerLoader.item;
            compare(sessionContainer.childSessions.count(), 0);

            var i;
            var sessions = [];
            for (i = 0; i < data.count; i++) {
                var session = SessionManager.createSession(sessionContainer.session.name + "-Child" + i,
                                                           Qt.resolvedUrl("../Dash/artwork/music-player-design.png"));
                session.createSurface();
                sessionContainer.session.addChildSession(session);
                compare(sessionContainer.childSessions.count(), i+1);

                sessions.push(session);
            }

            for (i = data.count-1; i >= 0; i--) {
                sessions[i].release();
                tryCompareFunction(function() { return sessionContainer.childSessions.count(); }, i);
            }
            tryCompare(sessionSpy, "count", data.count);
        }

        function test_nestedChildSessions_data() {
            return [ { tag: "depth=2", depth: 2 },
                     { tag: "depth=8", depth: 8 }
            ];
        }

        function test_nestedChildSessions(data) {
            sessionCheckbox.checked = true;
            var sessionContainer = sessionContainerLoader.item;
            compare(sessionContainer.childSessions.count(), 0);

            var i;
            var sessions = [];
            var lastSession = sessionContainer.session;
            var delegate;
            var container = sessionContainer;
            for (i = 0; i < data.depth; i++) {
                var session = SessionManager.createSession(lastSession.name + "-Child" + i,
                                                           Qt.resolvedUrl("../Dash/artwork/music-player-design.png"));
                session.createSurface();
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
            tryCompare(sessionSpy, "count", data.depth);
        }

        function test_childrenAdjustForParentSize() {
            sessionCheckbox.checked = true;
            var sessionContainer = sessionContainerLoader.item;

            wait(2000);

            var session = SessionManager.createSession(sessionContainer.session.name + "-Child0",
                                                       Qt.resolvedUrl("../Dash/artwork/music-player-design.png"));
            session.createSurface();
            sessionContainer.session.addChildSession(session);

            var delegate = findChild(sessionContainer, "childDelegate0");
            var childContainer = findChild(delegate, "sessionContainer");

            tryCompareFunction(function() { return childContainer.height === sessionContainer.height; }, true);
            tryCompareFunction(function() { return childContainer.width === sessionContainer.width; }, true);
            tryCompareFunction(function() { return childContainer.x === 0; }, true);
            tryCompareFunction(function() { return childContainer.y === 0; }, true);

            sessionContainer.anchors.margins = units.gu(2);

            tryCompareFunction(function() { return childContainer.height === sessionContainer.height; }, true);
            tryCompareFunction(function() { return childContainer.width === sessionContainer.width; }, true);
            tryCompareFunction(function() { return childContainer.x === 0; }, true);
            tryCompareFunction(function() { return childContainer.y === 0; }, true);
        }
    }
}

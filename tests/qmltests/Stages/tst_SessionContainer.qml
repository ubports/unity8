/*
 * Copyright 2014-2015 Canonical Ltd.
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
import QtQuick.Layouts 1.1
import QtTest 1.0
import Unity.Test 0.1 as UT
import Ubuntu.Components 1.3
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
            focus: true
            interactive: true
        }
    }

    Loader {
        id: sessionContainerLoader
        focus: true
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
                    activeFocusOnPress: false
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

                    session: sessionContainerLoader.item ? sessionContainerLoader.item.session : null
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
                var session = ApplicationTest.addChildSession(sessionContainer.session,
                                                              "gallery");
                session.createSurface();
                sessionContainer.session.addChildSession(session);
                compare(sessionContainer.childSessions.count(), i+1);

                sessions.push(session);
            }

            for (i = data.count-1; i >= 0; i--) {
                ApplicationTest.removeSession(sessions[i]);
                tryCompareFunction(function() { return sessionContainer.childSessions.count(); }, i);
            }
            tryCompare(sessionSpy, "count", data.count);
        }

        function test_childSessionDestructionReturnsFocusToSiblingOrParent() {
            sessionCheckbox.checked = true;
            var sessionContainer = sessionContainerLoader.item;
            compare(sessionContainer.childSessions.count(), 0);

            var i;
            var sessions = [];
            // 3 sessions should cover all edge cases
            for(i = 0; i < 3; i++) {
                var a_session = ApplicationTest.addChildSession(
                    sessionContainer.session, "gallery"
                )

                a_session.createSurface();
                sessionContainer.session.addChildSession(a_session);
                compare(sessionContainer.childSessions.count(), i + 1);

                sessions.push(a_session);
            }

            var a_session;
            while(a_session = sessions.pop()) {
                compare(a_session.surface.activeFocus, true);

                ApplicationTest.removeSurface(a_session.surface);
                ApplicationTest.removeSession(a_session);

                if (sessions.length > 0) {
                    // active focus should have gone to the yongest remaining sibling
                    var previousSiblingSurface = sessions[sessions.length - 1].surface
                    tryCompare(previousSiblingSurface, "activeFocus", true);
                } else {
                    // active focus should have gone to the parent surface
                    tryCompare(sessionContainer.session.surface, "activeFocus", true);
                }
            }
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
                var session = ApplicationTest.addChildSession(lastSession,
                                                              "gallery");
                session.createSurface();
                lastSession.addChildSession(session);
                compare(container.childSessions.count(), 1);
                sessions.push(session);

                delegate = findChild(container, "childDelegate0");
                container = findChild(delegate, "sessionContainer");
                lastSession = session;
            }

            for (i = data.depth-1; i >= 0; i--) {
                ApplicationTest.removeSession(sessions[i]);
            }

            tryCompareFunction(function() { return sessionContainer.childSessions.count(); }, 0);
            tryCompare(sessionSpy, "count", data.depth);
        }

        function test_childrenAdjustForParentSize() {
            sessionCheckbox.checked = true;
            var sessionContainer = sessionContainerLoader.item;

            var session = ApplicationTest.addChildSession(sessionContainer.session,
                                                          "gallery");
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

        function isContainerAnimating(container) {
            var animation = findInvisibleChild(container, "sessionAnimation");
            if (!animation) return false;

            var animating = false;
            for (var i = 0; i < animation.transitions.length; ++i) {
                if (animation.transitions[i].running) {
                    return true;
                }
            }
            return false;
        }

        function test_childrenAnimate() {
            sessionCheckbox.checked = true;
            var sessionContainer = sessionContainerLoader.item;

            var session = ApplicationTest.addChildSession(sessionContainer.session,
                                                          "gallery");

            var delegate = findChild(sessionContainer, "childDelegate0");
            var childContainer = findChild(delegate, "sessionContainer");

            // wait for animation to begin
            tryCompareFunction(function() { return isContainerAnimating(childContainer); }, true);
            // wait for animation to end
            tryCompareFunction(function() { return isContainerAnimating(childContainer); }, false);

            ApplicationTest.removeSession(session);

            // wait for animation to begin
            tryCompareFunction(function() { return isContainerAnimating(childContainer); }, true);
            // wait for animation to end
            tryCompareFunction(function() { return isContainerAnimating(childContainer); }, false);
        }
    }
}

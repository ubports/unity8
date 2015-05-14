import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtMultimedia 5.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Themes 1.0
import Ubuntu.Components.Popups 1.0

Item {
    id: root

    property alias component: loader.sourceComponent

    signal actionClicked(string action)
    signal viewModeClicked

    property list<Action> userActions
    property Action viewAction

    Rectangle {
        anchors.fill: parent
        color: "#1B1B1B"
        opacity: 0.85
    }

    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
        }
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: units.gu(2)
        spacing: units.gu(2)

        AbstractButton {
            id: actionButton
            Layout.preferredWidth: units.gu(3)
            Layout.preferredHeight: units.gu(3)
            Layout.alignment: Qt.AlignVCenter
            enabled: action && action.enabled

            Action {
                id: popupAction
                iconName: "navigation-menu"
                onTriggered: userActionsPopup.createObject(root, { "anchors.bottom": root.top })
            }

            action: {
                switch (userActions.length) {
                    case 0:
                        return null;
                    case 1:
                        return userActions[0];
                    default:
                        return popupAction;
                }
            }

            Icon {
                anchors.fill: parent
                visible: actionButton.action && actionButton.action.iconSource !== "" || false
                source: actionButton.action ? actionButton.action.iconSource : ""
                color: "#F3F3E7"
                opacity: actionButton.action && actionButton.action.enabled ? 1.0 : 0.5
            }
        }

        Loader {
            id: loader
            Layout.fillWidth: true
            Layout.preferredHeight: units.gu(3)
        }

        AbstractButton {
            Layout.preferredWidth: units.gu(3)
            Layout.preferredHeight: units.gu(3)
            Layout.alignment: Qt.AlignVCenter
            enabled: viewAction.enabled
            action: viewAction

            Icon {
                anchors.fill: parent
                visible: viewAction.iconSource !== ""
                source: viewAction.iconSource
                color: "#F3F3E7"
                opacity: viewAction.enabled ? 1.0 : 0.5
            }
        }
    }

    Component {
        id: userActionsPopup

            Rectangle {
                id: popup
                color: "#1B1B1B"
                width: userActionsColumn.width
                height: userActionsColumn.height

                InverseMouseArea {
                    id: eventGrabber
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    anchors.fill: popup
                    propagateComposedEvents: false
                    onWheel: wheel.accepted = true

                    onPressed: popup.destroy()
                }

                Column {
                    id: userActionsColumn
                    spacing: units.gu(1)

                    width: units.gu(31)
                    onHeightChanged: console.log("height", height)

                    Repeater {
                        id: actionRepeater
                        model: userActions
                        AbstractButton {
                            action: modelData

                            onClicked: popup.destroy()

                            implicitHeight: units.gu(4) + bottomDividerLine.height
                            width: parent ? parent.width : units.gu(31)

                            Rectangle {
                                visible: parent.pressed
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                }
                                height: parent.height - bottomDividerLine.height
                                opacity: 0.5
                            }

                            Icon {
                                id: actionIcon
                                visible: "" !== action.iconSource
                                source: action.iconSource
                                color: "#F3F3E7"
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    verticalCenterOffset: units.dp(-1)
                                    left: parent.left
                                    leftMargin: units.gu(2)
                                }
                                width: units.gu(2)
                                height: units.gu(2)
                                opacity: action.enabled ? 1.0 : 0.5
                            }

                            Label {
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    verticalCenterOffset: units.dp(-1)
                                    left: actionIcon.visible ? actionIcon.right : parent.left
                                    leftMargin: units.gu(2)
                                    right: parent.right
                                }
                                // In the tabs overflow panel there are no icons, and the font-size
                                //  is medium as opposed to the small font-size in the actions overflow panel.
                                fontSize: actionIcon.visible ? "small" : "medium"
                                elide: Text.ElideRight
                                text: action.text
                                color: "#F3F3E7"
                                opacity: action.enabled ? 1.0 : 0.5
                            }

                            ListItem.ThinDivider {
                                id: bottomDividerLine
                                anchors.bottom: parent.bottom
                                visible: index !== actionRepeater.count - 1
                            }
                        }
                }
            }
        }
    }
}

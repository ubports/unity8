/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Settings.Menus 0.1 as Menus
import Ubuntu.Settings.Components 0.1 as SettingsComponents
import QMenuModel 0.1
import Utils 0.1 as Utils
import Ubuntu.Components.ListItems 0.1 as ListItems
import Ubuntu.Components 0.1

Item {
    id: menuFactory

    property var rootModel: null
    property var menuModel: null

    property var _map:  {
        "unity.widgets.systemsettings.tablet.volumecontrol" : sliderMenu,
        "unity.widgets.systemsettings.tablet.switch"        : switchMenu,

        "com.canonical.indicator.button"        : buttonMenu,
        "com.canonical.indicator.div"           : separatorMenu,
        "com.canonical.indicator.section"       : sectionMenu,
        "com.canonical.indicator.progress"      : progressMenu,
        "com.canonical.indicator.slider"        : sliderMenu,
        "com.canonical.indicator.switch"        : switchMenu,
        "com.canonical.indicator.alarm"         : alarmMenu,
        "com.canonical.indicator.appointment"   : appointmentMenu,
        "com.canonical.indicator.transfer"      : transferMenu,
        "com.canonical.indicator.transfer-bulk-action" : bulkTransferMenu,

        "com.canonical.indicator.messages.messageitem"  : messageItem,
        "com.canonical.indicator.messages.sourceitem"   : groupedMessage,

        "com.canonical.unity.slider"    : sliderMenu,
        "com.canonical.unity.switch"    : switchMenu,

        "com.canonical.unity.media-player"    : mediaPayerMenu,
        "com.canonical.unity.playback-item"   : playbackItemMenu,

        "unity.widgets.systemsettings.tablet.wifisection" : wifiSection,
        "unity.widgets.systemsettings.tablet.accesspoint" : accessPoint,
    }

    function getExtendedProperty(object, propertyName, defaultValue) {
        if (object && object.hasOwnProperty(propertyName)) {
            return object[propertyName];
        }
        return defaultValue;
    }

    Component {
        id: separatorMenu;
        Menus.SeparatorMenu {
            objectName: "separatorMenu"
        }
    }

    Component {
        id: sliderMenu;
        Menus.SliderMenu {
            objectName: "sliderMenu"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined
            property var serverValue: getExtendedProperty(menuData, "actionState", undefined)

            text: menuData && menuData.label || ""
            iconSource: menuData && menuData.icon || ""
            minIcon: getExtendedProperty(extendedData, "minIcon", "")
            maxIcon: getExtendedProperty(extendedData, "maxIcon", "")

            minimumValue: getExtendedProperty(extendedData, "minValue", 0.0)
            maximumValue: {
                var maximum = getExtendedProperty(extendedData, "maxValue", 1.0);
                if (maximum <= minimumValue) {
                        return minimumValue + 1;
                }
                return maximum;
            }
            enabled: menuData && menuData.sensitive || false

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }
            onServerValueChanged: {
                // value can be changed by slider, so a binding won't work.
                if (serverValue !== undefined) {
                    value = serverValue;
                }
            }
            onUpdated: {
                menuModel.changeState(menuIndex, value);
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'min-value': 'double',
                                                             'max-value': 'double',
                                                             'min-icon': 'icon',
                                                             'max-icon': 'icon'});
            }
        }
    }

    Component {
        id: buttonMenu;
        Menus.ButtonMenu {
            objectName: "buttonMenu"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1

            buttonText: menuData && menuData.label || ""
            enabled: menuData && menuData.sensitive || false

            onTriggered: {
                menuModel.activate(menuIndex);
                shell.hideIndicatorMenu(UbuntuAnimation.FastDuration);
            }
        }
    }
    Component {
        id: sectionMenu;
        Menus.SectionMenu {
            objectName: "sectionMenu"
            property QtObject menuData: null
            property var menuIndex: undefined

            text: menuData && menuData.label || ""
            busy: false
        }
    }

    Component {
        id: progressMenu;
        Menus.ProgressValueMenu {
            objectName: "progressMenu"
            property QtObject menuData: null
            property int menuIndex: -1

            text: menuData && menuData.label || ""
            iconSource: menuData && menuData.icon || ""
            value : menuData && menuData.actionState || 0.0
            enabled: menuData && menuData.sensitive || false
        }
    }

    Component {
        id: standardMenu;
        ListItems.Standard {
            objectName: "standardMenu"
            property QtObject menuData: null
            property int menuIndex: -1

            text: menuData && menuData.label || ""
            iconSource: menuData && menuData.icon || ""
            enabled: menuData && menuData.sensitive || false

            onTriggered: {
                menuModel.activate(menuIndex);
                shell.hideIndicatorMenu(UbuntuAnimation.BriskDuration);
            }
        }
    }

    Component {
        id: checkableMenu;
        Menus.CheckableMenu {
            objectName: "checkableMenu"
            property QtObject menuData: null
            property int menuIndex: -1

            text: menuData && menuData.label || ""
            enabled: menuData && menuData.sensitive || false
            checked: menuData && menuData.isToggled || false

            onTriggered: {
                menuModel.activate(menuIndex);
                shell.hideIndicatorMenu(UbuntuAnimation.BriskDuration);
            }
        }
    }


    Component {
        id: switchMenu;
        Menus.SwitchMenu {
            objectName: "switchMenu"
            property QtObject menuData: null
            property int menuIndex: -1

            text: menuData && menuData.label || ""
            iconSource: menuData && menuData.icon || ""
            enabled: menuData && menuData.sensitive || false
            checked: menuData && menuData.isToggled || false

            onTriggered: {
                menuModel.activate(menuIndex);
                shell.hideIndicatorMenu(UbuntuAnimation.BriskDuration);
            }
        }
    }

    Component {
        id: alarmMenu;
        Menus.EventMenu {
            objectName: "alarmMenu"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined
            // TODO - bug #1260728
            property var timeFormatter: Utils.GDateTimeFormatter {
                time: getExtendedProperty(extendedData, "xCanonicalTime", 0)
                format: getExtendedProperty(extendedData, "xCanonicalTimeFormat", "")
            }

            text: menuData && menuData.label || ""
            iconSource: menuData && menuData.icon || "image://theme/alarm-clock"
            time: timeFormatter.timeString
            enabled: menuData && menuData.sensitive || false

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }
            onTriggered: {
                menuModel.activate(menuIndex);
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-time': 'int64',
                                                             'x-canonical-time-format': 'string'});
            }
        }
    }

    Component {
        id: appointmentMenu;
        Menus.EventMenu {
            objectName: "appointmentMenu"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined
            // TODO - bug #1260728
            property var timeFormatter: Utils.GDateTimeFormatter {
                time: getExtendedProperty(extendedData, "xCanonicalTime", 0)
                format: getExtendedProperty(extendedData, "xCanonicalTimeFormat", "")
            }

            text: menuData && menuData.label || ""
            iconSource: menuData && menuData.icon || "image://theme/calendar"
            time: timeFormatter.timeString
            eventColor: getExtendedProperty(extendedData, "xCanonicalColor", Qt.rgba(0.0, 0.0, 0.0, 0.0))
            enabled: menuData && menuData.sensitive || false

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }
            onTriggered: {
                menuModel.activate(menuIndex);
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-color': 'string',
                                                             'x-canonical-time': 'int64',
                                                             'x-canonical-time-format': 'string'});
            }
        }
    }

    Component {
        id: wifiSection;
        Menus.SectionMenu {
            objectName: "wifiSection"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined

            text: menuData && menuData.label || ""
            busy: getExtendedProperty(extendedData, "xCanonicalBusyAction", false)

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-busy-action': 'bool'})
            }
        }
    }

    Component {
        id: accessPoint;
        Menus.AccessPointMenu {
            objectName: "accessPoint"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined

            property var strengthAction: UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalWifiApStrengthAction", "")
            }

            text: menuData && menuData.label || ""
            enabled: menuData && menuData.sensitive || false
            checked: menuData && menuData.isToggled || false
            secure: getExtendedProperty(extendedData, "xCanonicalWifiApIsSecure", false)
            adHoc: getExtendedProperty(extendedData, "xCanonicalWifiApIsAdhoc", false)
            signalStrength: strengthAction.valid ? strengthAction.state : 0

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }
            onTriggered: {
                menuModel.activate(menuIndex);
                shell.hideIndicatorMenu(UbuntuAnimation.BriskDuration);
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-wifi-ap-is-adhoc': 'bool',
                                                             'x-canonical-wifi-ap-is-secure': 'bool',
                                                             'x-canonical-wifi-ap-strength-action': 'string'});
            }
        }
    }

    Component {
        id: messageItem
        MessageMenuItemFactory {
            objectName: "messageItem"
            menuModel: menuFactory.menuModel
        }
    }

    Component {
        id: groupedMessage
        Menus.GroupedMessageMenu {
            objectName: "groupedMessage"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined

            text: menuData && menuData.label || ""
            iconSource: getExtendedProperty(extendedData, "icon", "qrc:/indicators/artwork/messaging/default_app.svg")
            count: menuData && menuData.actionState.length > 0 ? menuData.actionState[0] : "0"
            enabled: menuData && menuData.sensitive || false
            removable: true

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }
            onClicked: {
                menuModel.activate(menuIndex, true);
                shell.hideIndicatorMenu(UbuntuAnimation.FastDuration);
            }
            onDismissed: {
                menuModel.activate(menuIndex, false);
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(modelIndex, {'icon': 'icon'});
            }
        }
    }

    Component {
        id: mediaPayerMenu;
        Menus.MediaPlayerMenu {
            objectName: "mediaPayerMenu"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var actionState: menuData && menuData.actionState || undefined

            playerIcon: menuData && menuData.icon || ""
            playerName: menuData && menuData.label || ""

            albumArt: getExtendedProperty(actionState, "art-url", "")
            song: getExtendedProperty(actionState, "title", "unknown")
            artist: getExtendedProperty(actionState, "artist", "unknown")
            album: getExtendedProperty(actionState, "album", "unknown")
            running: getExtendedProperty(actionState, "running", false)
            state: getExtendedProperty(actionState, "state", "")
            enabled: menuData && menuData.sensitive || false

            onTriggered: {
                model.activate(modelIndex);
            }
        }
    }

    Component {
        id: playbackItemMenu;
        Menus.PlaybackItemMenu {
            objectName: "playbackItemMenu"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined

            property var playAction: UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalPlayAction", "")
            }
            property var nextAction: UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalNextAction", "")
            }
            property var previousAction: UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalPreviousAction", "")
            }

            playing: playAction.state === "Playing"
            canPlay: playAction.valid
            canGoNext: nextAction.valid
            canGoPrevious: previousAction.valid
            enabled: menuData && menuData.sensitive || false

            onPlay: {
                playAction.activate();
            }
            onNext: {
                nextAction.activate();
            }
            onPrevious: {
                previousAction.activate();
            }
            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(modelIndex, {'x-canonical-play-action': 'string',
                                                              'x-canonical-next-action': 'string',
                                                              'x-canonical-previous-action': 'string'});
            }
        }
    }

    Component {
        id: transferMenu
        Menus.TransferMenu {
            objectName: "transferMenu"
            id: transfer
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined
            property var uid: getExtendedProperty(extendedData, "xCanonicalUid", undefined)

            text: menuData && menuData.label || ""
            iconSource: menuData && menuData.icon || "image://theme/save"
            maximum: 1.0
            enabled: menuData && menuData.sensitive || false
            removable: true
            confirmRemoval: true

            QDBusActionGroup {
                id: actionGroup
                busType: 1
                busName: rootModel.busName
                objectPath: rootModel.actions["indicator"]

                property QtObject activateAction: action("activate-transfer")
                property QtObject cancelAction: action("cancel-transfer")
                property QtObject pauseAction: action("pause-transfer")
                property QtObject resumeAction: action("resume-transfer")
                property QtObject transferStateAction: uid !== undefined ? action("transfer-state."+uid) : null

                Component.onCompleted: actionGroup.start()
            }

            property var transferState: {
                if (actionGroup.transferStateAction === null)
                    return undefined;
                return actionGroup.transferStateAction.valid ? actionGroup.transferStateAction.state : undefined
            }

            property var runningState : transferState !== undefined ? transferState["state"] : undefined
            property var secondsLeft : transferState !== undefined ? transferState["seconds-left"] : undefined

            active: runningState !== undefined && runningState !== Menus.TransferState.FINISHED
            progress : transferState !== undefined ? transferState["percent"] : 0.0

            property var timeRemaining: {
                if (secondsLeft === undefined) return undefined;

                var remaining = "";
                var hours = Math.floor(secondsLeft / (60 * 60));
                var minutes = Math.floor(secondsLeft / 60) % 60;
                var seconds = secondsLeft % 60;
                if (hours > 0) {
                    remaining += hours + (hours == 1 ? " hour" : " hours");
                }
                if (minutes > 0) {
                    if (remaining != "") remaining += ", ";
                    remaining += minutes + (minutes == 1 ? " minute" : " minutes");
                }
                // don't include seconds if hours > 0
                if (hours == 0 && minutes < 5 && seconds > 0) {
                    if (remaining != "") remaining += ", ";
                    remaining += seconds + (seconds == 1 ? " second" : " seconds");
                }
                if (remaining == "")
                    remaining = "0 seconds";
                return remaining + " remaining";
            }

            stateText: {
                switch (runningState) {
                    case Menus.TransferState.QUEUED:
                        return i18n.tr("In queue...");
                    case Menus.TransferState.HASHING:
                    case Menus.TransferState.PROCESSING:
                    case Menus.TransferState.RUNNING:
                        return timeRemaining === undefined ? "Downloading" : timeRemaining;
                    case Menus.TransferState.PAUSED:
                        return i18n.tr("Paused, tap to resume");
                    case Menus.TransferState.CANCELED:
                        return i18n.tr("Canceled");
                    case Menus.TransferState.FINISHED:
                        return i18n.tr("Finished");
                    case Menus.TransferState.ERROR:
                        return i18n.tr("Failed, tap to retry");
                }
                return "";
            }

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }
            onTriggered: {
                actionGroup.activateAction.activate(uid);
                shell.hideIndicatorMenu(UbuntuAnimation.BriskDuration);
            }
            onItemRemoved: {
                actionGroup.cancelAction.activate(uid);
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-uid': 'string'});
            }
        }
    }

    Component {
        id: bulkTransferMenu;
        ListItems.Standard {
            objectName: "bulkTransferMenu"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined

            iconSource: menuData && menuData.icon || ""
            enabled: menuData && menuData.sensitive || false
            text: menuData && menuData.label || ""
            showDivider: false

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }
            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-extra-label': 'string'});
            }

            control: Button {
                text: getExtendedProperty(extendedData, "xCanonicalExtraLabel", "")

                onClicked: {
                    menuModel.activate(menuIndex);
                    shell.hideIndicatorMenu(UbuntuAnimation.BriskDuration);
                }
            }
        }
    }

    function load(modelData) {
        if (modelData.type !== undefined) {
            var component = _map[modelData.type];
            if (component !== undefined) {
                return component;
            }
        }
        if (modelData.isCheck || modelData.isRadio) {
            return checkableMenu;
        }
        if (modelData.isSeparator) {
            return separatorMenu;
        }
        return standardMenu;
    }
}

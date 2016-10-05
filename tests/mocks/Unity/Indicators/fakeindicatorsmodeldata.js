var usageScenario = (typeof shell != 'undefined') ? shell.usageScenario : "desktop";

var fakeMenuData = {
    "fake-indicator-messages": [
        {
            "rowData": {
                "action": "indicator._header",
                "actionState": {
                    "icons": [ "image://theme/messages-new" ],
                    "label": "",
                    "title": "Messages (F)",
                    "visible": true
                },
                "icon": "",
                "isCheck": false,
                "isRadio": false,
                "isSeparator": false,
                "isToggled": false,
                "label": "",
                "sensitive": true,
                "type": "com.canonical.indicator.root"
            },
            "submenu": [
                {
                    "rowData": {
                        "label": "There's an updated system image.",
                        "sensitive": true,
                        "isSeparator": false,
                        "icon": "file:///usr/share/ubuntu/settings/system/icons/settings-system-update.svg",
                        "type": "com.canonical.indicator.messages.messageitem",
                        "ext": {
                                "icon": "file:///usr/share/ubuntu/settings/system/icons/settings-system-update.svg",
                                "xCanonicalAppIcon": "file:///usr/share/ubuntu/settings/system/system-settings.png",
                                "xCanonicalMessageActions": null,
                                "xCanonicalText": "Tap to open the system updater.",
                                "xCanonicalTime": ((new Date).getTime() - 350 * 1000) * 1000,
                        },
                        "action": "indicator.ubuntu-system-settings",
                        "actionState": {},
                        "isCheck": false,
                        "isRadio": false,
                        "isToggled": false,
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.telephony-service-sms.msg.MSG_ID",
                        "actionState": {},
                        "ext": {},
                        "icon": "file:///usr/share/telephony-service/assets/avatar-default@18.png",
                        "type": "com.canonical.indicator.messages.messageitem",
                        "ext": {
                            "icon": "file:///usr/share/telephony-service/assets/avatar-default@18.png",
                            "xCanonicalAppIcon": "image://theme/telephony-service-message",
                            "xCanonicalMessageActions": "",
                            "xCanonicalText": "This is a message sent to an awesome Ubuntu phone.",
                            "xCanonicalTime": ((new Date).getTime() - 35 * 1000) * 1000
                        },
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "+44391234567 - [SIM 1]",
                        "sensitive": true
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.remove-all",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Clear All",
                        "sensitive": true,
                        "type": "com.canonical.indicator.button"
                    }
                },
            ]
        }
    ],

    "fake-indicator-session": [
        {
            "rowData": {
                "action": "indicator._header",
                "actionState": {
                    "icons": [],
                    "label": "",
                    "title": "Session (F)",
                    "visible": usageScenario == "desktop"
                },
                "icon": "",
                "isCheck": false,
                "isRadio": false,
                "isSeparator": false,
                "isToggled": false,
                "label": "",
                "sensitive": true,
                "type": "com.canonical.indicator.root"
            },
            "submenu": [
                {
                    "rowData": {
                        "action": "indicator.about",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "About this " + usageScenario,
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.help",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Ubuntu Help",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": true,
                        "isToggled": false,
                        "label": "",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.settings",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "System Settings...",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": true,
                        "isToggled": false,
                        "label": "",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.switch-to-screensaver",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Lock",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.switch-to-guest",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Guest Session",
                        "sensitive": true,
                        "type": "indicator.guest-menu-item"
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.switch-to-user",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": true,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Marco",
                        "sensitive": true,
                        "type": "indicator.user-menu-item"
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.switch-to-user",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": true,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Unity8",
                        "sensitive": true,
                        "type": "indicator.user-menu-item"
                    }
                },
                {
                    "rowData": {
                        "action": "",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": true,
                        "isToggled": false,
                        "label": "",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.logout",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Logout...",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": true,
                        "isToggled": false,
                        "label": "",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.suspend",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Suspend",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.power-off",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Power off...",
                        "sensitive": true,
                        "type": ""
                    }
                }
            ]
        }
    ],

    "fake-indicator-power": [
        {
            "rowData": {
                "action": "indicator._header",
                "actionState": {
                    "icons": [ "image://theme/battery-020" ],
                    "label": "",
                    "title": "Battery (F)",
                    "visible": true
                },
                "icon": "",
                "isCheck": false,
                "isRadio": false,
                "isSeparator": false,
                "isToggled": false,
                "label": "",
                "sensitive": true,
                "type": "com.canonical.indicator.root"
            },
            "submenu": [
                {
                    "rowData": {
                        "action": "indicator.activate-statistics",
                        "actionState": {},
                        "ext": {},
                        "icon": "image://theme/battery-full-charged-symbolic",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Battery (full charged)",
                        "sensitive": true,
                        "type": "com.canonical.indicator.basic"
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.activate-statistics",
                        "actionState": {},
                        "ext": {},
                        "icon": "image://theme/battery-100",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Battery",
                        "sensitive": true,
                        "type": "com.canonical.indicator.basic"
                    }
                },
                {
                    "rowData": {
                        "action": "",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": true,
                        "isToggled": false,
                        "label": " ",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.show-time",
                        "actionState": false,
                        "ext": {},
                        "icon": "",
                        "isCheck": true,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Show time on menubar",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.show-percentage",
                        "actionState": false,
                        "ext": {},
                        "icon": "",
                        "isCheck": true,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Show percentage on menubar",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.activate-settings",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Power Settings...",
                        "sensitive": true,
                        "type": ""
                    }
                }
            ]
        }
    ],

    "fake-indicator-sound": [
        {
            "rowData": {
                "action": "indicator._header",
                "actionState": {
                    "icons": [ "image://theme/audio-volume-high" ],
                    "label": "",
                    "title": "Sound (F)",
                    "visible": true
                },
                "icon": "",
                "isCheck": false,
                "isRadio": false,
                "isSeparator": false,
                "isToggled": false,
                "label": "",
                "sensitive": true,
                "type": "com.canonical.indicator.root"
            },
            "submenu": [
                {
                    "rowData": {
                        "action": "indicator.silent-mode",
                        "actionState": true,
                        "ext": {},
                        "icon": "",
                        "isCheck": true,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Silent Mode",
                        "sensitive": true,
                        "type": "com.canonical.indicator.switch"
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.volume",
                        "actionState": 0.35,
                        "ext": {
                            "maxIcon": "image://theme/audio-volume-high-panel",
                            "maxValue": 1,
                            "minIcon": "image://theme/audio-volume-low-zero-panel",
                            "minValue": 0,
                            "xCanonicalSyncAction": "indicator.volume-sync"
                        },
                        "icon": "",
                        "isCheck": false,
                        "isRadio": true,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Volume",
                        "sensitive": true,
                        "type": "com.canonical.unity.slider"
                    }
                },
                {
                    "rowData": {
                        "action": "",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": true,
                        "isToggled": false,
                        "label": "",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.mediaplayer-app.desktop",
                        "actionState": {
                            "running": true,
                            "state": "Stopped"
                        },
                        "ext": {},
                        "icon": "image://theme/mediaplayer-app",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Media Player",
                        "sensitive": false,
                        "type": "com.canonical.unity.media-player"
                    }
                },
                {
                    "rowData": {
                        "actionState": {},
                        "ext": {
                            "action": ""
                        },
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "",
                        "sensitive": true,
                        "type": "com.canonical.unity.playback-item"
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.phone-settings",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Sound Settings…",
                        "sensitive": true,
                        "type": ""
                    }
                }
            ]
        }
    ],


   "fake-indicator-datetime": [
        {
            "rowData": {
                "action": "indicator._header",
                "actionState": {
                    "icons": [],
                    "label": "16.10",
                    "title": "Upcoming Events (F)",
                    "visible": true
                },
                "icon": "",
                "isCheck": false,
                "isRadio": false,
                "isSeparator": false,
                "isToggled": false,
                "label": "",
                "sensitive": true,
                "type": "com.canonical.indicator.root"
            },
            "submenu": [
                {
                    "rowData": {
                        "action": "indicator.phone.open-calendar-app",
                        "actionState": {},
                        "ext": {},
                        "icon": "image://theme/calendar",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Saturday, 31 December 2016",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "",
                        "actionState": {},
                        "ext": {},
                        "icon": "fake-indicator-datetime",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": true,
                        "isToggled": false,
                        "label": "",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.phone.open-alarm-app",
                        "actionState": {},
                        "ext": {},
                        "icon": "image://theme/clock",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Clock",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.phone.open-appointment",
                        "actionState": {},
                        "ext": {
                            "xCanonicalColor": Qt.rgba(32,74,135,1),
                            "xCanonicalTime": (new Date).getTime() / 1000 + 35000
                        },
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Finish Indicator mocks",
                        "sensitive": true,
                        "type": "com.canonical.indicator.appointment"
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.phone.open-appointment",
                        "actionState": {},
                        "ext": {
                            "xCanonicalColor": Qt.rgba(32,74,135,1),
                            "xCanonicalTime": (new Date).getTime() / 1000 + 50474
                        },
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Implement Desktop version",
                        "sensitive": true,
                        "type": "com.canonical.indicator.appointment"
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.phone.open-appointment",
                        "actionState": {},
                        "ext": {
                            "xCanonicalColor": Qt.rgba(32,74,135,1),
                            "xCanonicalTime": (new Date).getTime() / 1000 + 385000
                        },
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Ubuntu drinks event",
                        "sensitive": true,
                        "type": "com.canonical.indicator.appointment"
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.phone.open-appointment",
                        "actionState": {},
                        "ext": {
                            "xCanonicalColor": Qt.rgba(32,74,135,1),
                            "xCanonicalTime": (new Date).getTime() / 1000 + 3500050
                        },
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Land unity8",
                        "sensitive": true,
                        "type": "com.canonical.indicator.appointment"
                    }
                },
                {
                    "rowData": {
                        "action": "",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": true,
                        "isToggled": false,
                        "label": "",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.phone.open-settings-app",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Date and Time settings…",
                        "sensitive": true,
                        "type": ""
                    }
                }
            ]
        }
    ],


    "fake-indicator-files": [
        {
            "rowData": {
                "action": "indicator._header",
                "actionState": {
                    "icons": [],
                    "label": "Files",
                    "title": "Files",
                    "visible": true
                },
                "icon": "",
                "isCheck": false,
                "isRadio": false,
                "isSeparator": false,
                "isToggled": false,
                "label": "",
                "sensitive": true,
                "type": "com.canonical.indicator.root"
            },
            "submenu": [
                {
                    "rowData": {
                        "action": "indicator.pause-all",
                        "actionState": {},
                        "ext": {
                            "xCanonicalExtraLabel": "Pause all"
                        },
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "",
                        "sensitive": true,
                        "type": "com.canonical.indicator.button-section"
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.activate-transfer",
                        "actionState": {},
                        "ext": {
                            "xCanonicalUid": 1003
                        },
                        "icon": "image://theme/webbrowser-app",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Ubuntu daily.iso",
                        "sensitive": true,
                        "type": "com.canonical.indicator.transfer"
                    }
                },
                {
                    "rowData": {
                        "action": "",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": true,
                        "isToggled": false,
                        "label": "",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.clear-all",
                        "actionState": {},
                        "ext": {
                            "xCanonicalExtraLabel": "Clear all"
                        },
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Successful Transfers",
                        "sensitive": true,
                        "type": "com.canonical.indicator.button-section"
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.activate-transfer",
                        "actionState": {},
                        "ext": {
                            "xCanonicalUid": 1002
                        },
                        "icon": "image://theme/webbrowser-app",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Ubuntu Guide.pdf",
                        "sensitive": true,
                        "type": "com.canonical.indicator.transfer"
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.activate-transfer",
                        "actionState": {},
                        "ext": {
                            "xCanonicalUid": 1001
                        },
                        "icon": "image://theme/webbrowser-app",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Unity8 Hacking.pdf",
                        "sensitive": true,
                        "type": "com.canonical.indicator.transfer"
                    }
                }
            ]
        }
    ],

    "fake-indicator-network": [
        {
            "rowData": {
                "action": "indicator._header",
                "actionState": {
                    "icons": [],
                    "label": "",
                    "title": "Network",
                    "visible": true
                },
                "icon": "",
                "isCheck": false,
                "isRadio": false,
                "isSeparator": false,
                "isToggled": false,
                "label": "",
                "sensitive": true,
                "type": "com.canonical.indicator.root"
            },
            "submenu": [
                {
                    "rowData": {
                        "action": "indicator.airplane.enabled",
                        "actionState": false,
                        "ext": {},
                        "icon": "",
                        "isCheck": true,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Flight Mode",
                        "sensitive": true,
                        "type": "com.canonical.indicator.switch"
                    }
                },
                /* Anything to see here, since no fake modem actions are implemented
                {
                    "rowData": {
                        "actionState": false,
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": true,
                        "isToggled": false,
                        "label": "",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "actionState": false,
                        "ext": {
                            "xCanonicalModemConnectivityIconAction": "indicator.modem.1::connectivity-icon",
                            "xCanonicalModemLockedAction": "indicator.modem.1::locked",
                            "xCanonicalModemRoamingAction": "indicator.modem.1::roaming",
                            "xCanonicalModemSimIdentifierLabelAction": "indicator.modem.1::sim-identifier-label",
                            "xCanonicalModemStatusIconAction": "indicator.modem.1::status-icon",
                            "xCanonicalModemStatusLabelAction": "indicator.modem.1::status-label"
                        },
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "",
                        "sensitive": true,
                        "type": "com.canonical.indicator.network.modeminfoitem",
                        "visible": false
                    }
                },
                */
                {
                    "rowData": {
                        "action": "indicator.wifi.enable",
                        "actionState": true,
                        "ext": {},
                        "icon": "",
                        "isCheck": true,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": true,
                        "label": "Wi-Fi",
                        "sensitive": true,
                        "type": "com.canonical.indicator.switch"
                    }
                },
                {
                    "rowData": {
                        "action": "",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": true,
                        "isToggled": false,
                        "label": "",
                        "sensitive": true,
                        "type": ""
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.accesspoint.1",
                        "actionState": true,
                        "ext": {
                            "xCanonicalWifiApIsAdhoc": 0,
                            "xCanonicalWifiApIsSecure": 1,
                            "xCanonicalWifiApStrengthAction": "indicator.accesspoint.1::strength"
                        },
                        "icon": "",
                        "isCheck": true,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": true,
                        "label": "Canonical",
                        "sensitive": true,
                        "type": "unity.widgets.systemsettings.tablet.accesspoint"
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.accesspoint.2",
                        "actionState": false,
                        "ext": {
                            "xCanonicalWifiApIsAdhoc": 0,
                            "xCanonicalWifiApIsSecure": 1,
                            "xCanonicalWifiApStrengthAction": "indicator.accesspoint.2::strength"
                        },
                        "icon": "",
                        "isCheck": true,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Ubuntu",
                        "sensitive": true,
                        "type": "unity.widgets.systemsettings.tablet.accesspoint"
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.accesspoint.3",
                        "actionState": false,
                        "ext": {
                            "xCanonicalWifiApIsAdhoc": 0,
                            "xCanonicalWifiApIsSecure": 0,
                            "xCanonicalWifiApStrengthAction": "indicator.accesspoint.3::strength"
                        },
                        "icon": "",
                        "isCheck": true,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Linux",
                        "sensitive": true,
                        "type": "unity.widgets.systemsettings.tablet.accesspoint"
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.accesspoint.4",
                        "actionState": false,
                        "ext": {
                            "xCanonicalWifiApIsAdhoc": 0,
                            "xCanonicalWifiApIsSecure": 0,
                            "xCanonicalWifiApStrengthAction": "indicator.accesspoint.4::strength"
                        },
                        "icon": "",
                        "isCheck": true,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "for Human Beings",
                        "sensitive": true,
                        "type": "unity.widgets.systemsettings.tablet.accesspoint"
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.wifi.settings",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Wi-Fi settings…",
                        "sensitive": true,
                        "type": ""
                    }
                }
            ]
        }
    ],

    "fake-indicator-bluetooth": [
        {
            "rowData": {
                "action": "indicator._header",
                "actionState": {
                    "icons": [],
                    "label": "",
                    "title": "Network",
                    "visible": true
                },
                "icon": "",
                "isCheck": false,
                "isRadio": false,
                "isSeparator": false,
                "isToggled": false,
                "label": "",
                "sensitive": true,
                "type": "com.canonical.indicator.root"
            },
            "submenu": [
                {
                    "rowData": {
                        "action": "indicator.bluetooth.enable",
                        "actionState": true,
                        "ext": {},
                        "icon": "",
                        "isCheck": true,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": true,
                        "label": "Bluetooth",
                        "sensitive": true,
                        "type": "com.canonical.indicator.switch"
                    }
                },
                {
                    "rowData": {
                        "action": "indicator.bluetooth.settings",
                        "actionState": {},
                        "ext": {},
                        "icon": "",
                        "isCheck": false,
                        "isRadio": false,
                        "isSeparator": false,
                        "isToggled": false,
                        "label": "Bluetooth settings…",
                        "sensitive": true,
                        "type": ""
                    }
                }
            ]
        }
    ]
}

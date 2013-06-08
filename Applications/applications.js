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

// mimic qtubuntu's Application.Stage enum
var MainStage = 0;
var SideStage = 1;

var __availableApplications = {
    '/usr/share/applications/phone-app.desktop': {
        'name': i18n.tr("Phone"),
        'icon': 'phone-app',
        'exec': '/usr/bin/phone-app',
        'stage': SideStage
    },
    '/usr/share/applications/camera-app.desktop': {
        'name': i18n.tr("Camera"),
        'icon': 'camera',
        'fullscreen': true,
        'exec': '/usr/bin/camera-app --fullscreen'
    },
    '/usr/share/applications/gallery-app.desktop': {
        'name': i18n.tr("Gallery"),
        'icon': 'gallery',
        'exec': '/usr/bin/gallery-app'
    },
    '/usr/share/applications/facebook-webapp.desktop': {
        'name': i18n.tr("Facebook"),
        'icon': 'facebook',
        'exec': '/usr/bin/webbrowser-app --chromeless http://m.facebook.com',
        'stage': SideStage
    },
    '/usr/share/applications/webbrowser-app.desktop': {
        'name': i18n.tr("Browser"),
        'icon': 'browser',
        'exec': '/usr/bin/webbrowser-app'
    },
    '/usr/share/applications/twitter-webapp.desktop': {
        'name': i18n.tr("Twitter"),
        'icon': 'twitter',
        'exec': '/usr/bin/webbrowser-app --chromeless http://www.twitter.com',
        'stage': SideStage
    },
    '/usr/share/applications/gmail-webapp.desktop': {
        'name': i18n.tr("GMail"),
        'icon': 'gmail',
        'exec': '/usr/bin/webbrowser-app --chromeless http://m.gmail.com'
    },
    '/usr/share/applications/ubuntu-weather-app.desktop': {
        'name': i18n.tr("Weather"),
        'icon': 'weather',
        'exec': '/usr/bin/qmlscene /usr/share/ubuntu-weather-app/ubuntu-weather-app.qml',
        'stage': SideStage
    },
    '/usr/share/applications/notes-app.desktop': {
        'name': i18n.tr("Notepad"),
        'icon': 'notepad',
        'exec': '/usr/bin/qmlscene /usr/share/notes-app/NotesApp.qml',
        'stage': SideStage
    },
    '/usr/share/applications/ubuntu-calendar-app.desktop': {
        'name': i18n.tr("Calendar"),
        'icon': 'calendar',
        'exec': '/usr/bin/qmlscene /usr/share/ubuntu-calendar-app/calendar.qml',
        'stage': SideStage
    },
    '/usr/share/applications/mediaplayer-app.desktop': {
        'name': i18n.tr("Media Player"),
        'icon': 'mediaplayer-app',
        'fullscreen': true,
        'exec': '/usr/bin/mediaplayer-app'
    },
    '/usr/share/applications/evernote.desktop': {
        'name': i18n.tr("Evernote"),
        'icon': 'evernote',
        'exec': ''
    },
    '/usr/share/applications/map.desktop': {
        'name': i18n.tr("Map"),
        'icon': 'map',
        'exec': ''
    },
    '/usr/share/applications/pinterest.desktop': {
        'name': i18n.tr("Pinterest"),
        'icon': 'pinterest',
        'exec': ''
    },
    '/usr/share/applications/soundcloud.desktop': {
        'name': i18n.tr("SoundCloud"),
        'icon': 'soundcloud',
        'exec': ''
    },
    '/usr/share/applications/wikipedia.desktop': {
        'name': i18n.tr("Wikipedia"),
        'icon': 'wikipedia',
        'exec': ''
    },
    '/usr/share/applications/youtube.desktop': {
        'name': i18n.tr("YouTube"),
        'icon': 'youtube',
        'exec': ''
    },
}

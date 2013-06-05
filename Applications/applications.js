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
        'name': 'Phone',
        'icon': 'phone-app',
        'exec': '/usr/bin/phone-app',
        'stage': SideStage
    },
    '/usr/share/applications/camera-app.desktop': {
        'name': 'Camera',
        'icon': 'camera',
        'fullscreen': true,
        'exec': '/usr/bin/camera-app --fullscreen'
    },
    '/usr/share/applications/gallery-app.desktop': {
        'name': 'Gallery',
        'icon': 'gallery',
        'exec': '/usr/bin/gallery-app'
    },
    '/usr/share/applications/facebook-webapp.desktop': {
        'name': 'Facebook',
        'icon': 'facebook',
        'exec': '/usr/bin/webbrowser-app --chromeless http://m.facebook.com',
        'stage': SideStage
    },
    '/usr/share/applications/webbrowser-app.desktop': {
        'name': 'Browser',
        'icon': 'browser',
        'exec': '/usr/bin/webbrowser-app'
    },
    '/usr/share/applications/twitter-webapp.desktop': {
        'name': 'Twitter',
        'icon': 'twitter',
        'exec': '/usr/bin/webbrowser-app --chromeless http://www.twitter.com',
        'stage': SideStage
    },
    '/usr/share/applications/gmail-webapp.desktop': {
        'name': 'GMail',
        'icon': 'gmail',
        'exec': '/usr/bin/webbrowser-app --chromeless http://m.gmail.com'
    },
    '/usr/share/applications/ubuntu-weather-app.desktop': {
        'name': 'Weather',
        'icon': 'weather',
        'exec': '/usr/bin/qmlscene /usr/share/ubuntu-weather-app/ubuntu-weather-app.qml',
        'stage': SideStage
    },
    '/usr/share/applications/notes-app.desktop': {
        'name': 'Notepad',
        'icon': 'notepad',
        'exec': '/usr/bin/qmlscene /usr/share/notes-app/NotesApp.qml',
        'stage': SideStage
    },
    '/usr/share/applications/ubuntu-calendar-app.desktop': {
        'name': 'Calendar',
        'icon': 'calendar',
        'exec': '/usr/bin/qmlscene /usr/share/ubuntu-calendar-app/calendar.qml',
        'stage': SideStage
    },
    '/usr/share/applications/mediaplayer-app.desktop': {
        'name': 'Media Player',
        'icon': 'mediaplayer-app',
        'fullscreen': true,
        'exec': '/usr/bin/mediaplayer-app'
    },
    '/usr/share/applications/evernote.desktop': {
        'name': 'Evernote',
        'icon': 'evernote',
        'exec': ''
    },
    '/usr/share/applications/map.desktop': {
        'name': 'Map',
        'icon': 'map',
        'exec': ''
    },
    '/usr/share/applications/pinterest.desktop': {
        'name': 'Pinterest',
        'icon': 'pinterest',
        'exec': ''
    },
    '/usr/share/applications/soundcloud.desktop': {
        'name': 'SoundCloud',
        'icon': 'soundcloud',
        'exec': ''
    },
    '/usr/share/applications/wikipedia.desktop': {
        'name': 'Wikipedia',
        'icon': 'wikipedia',
        'exec': ''
    },
    '/usr/share/applications/youtube.desktop': {
        'name': 'YouTube',
        'icon': 'youtube',
        'exec': ''
    },
}

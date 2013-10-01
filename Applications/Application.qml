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

import QtQuick 2.0
import "applications.js" as ApplicationsModel
import Unity.Application 0.1

/* This class is temporary. It is meant to be API compatible with qthybris' Application
   class.
   This class can be removed as soon as qthybris' Application is instantiable from QML
   and its 'desktopFile' property becomes writable.
   This also requires qthybris to be easily compilable on the desktop.
*/
QtObject {
    id: application

    property string desktopFile
    property string name
    property string comment
    property string icon
    property string exec
    property string stage
    property bool fullscreen

    onDesktopFileChanged: {
        var applicationData = ApplicationsModel.__availableApplications[desktopFile];
        if (applicationData) {
            application.name = applicationData.name;
            application.icon = applicationData.icon;
            application.exec = applicationData.exec;
            application.stage = applicationData.stage ? applicationData.stage : ApplicationInfo.MainStage;
            application.fullscreen = applicationData.fullscreen ? applicationData.fullscreen : false;
        } else {
            application.name = "";
            application.icon = "";
            application.exec = "";
            application.stage = "";
            application.fullscreen = false;
        }
    }
}

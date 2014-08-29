/*
 * Copyright 2014 Canonical Ltd.
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
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

#include "desktopfilehandler.h"

#include <QStringList>
#include <QStandardPaths>
#include <QDir>
#include <QSettings>

DesktopFileHandler::DesktopFileHandler(QObject *parent):
    QObject(parent)
{

}

QString DesktopFileHandler::findDesktopFile(const QString &appId) const
{
    int dashPos = -1;
    QString helper = appId;

    QStringList searchDirs = QStandardPaths::standardLocations(QStandardPaths::ApplicationsLocation);
#ifdef LAUNCHER_TESTING
    searchDirs << "";
#endif

    QString path;
    do {
        if (dashPos != -1) {
            helper.replace(dashPos, 1, '/');
        }

        if (helper.contains("/")) {
            path += helper.split('/').first() + '/';
            helper.remove(QRegExp("^" + path));
        }

        Q_FOREACH(const QString &searchDirName, searchDirs) {
            QDir searchDir(searchDirName + "/" + path);
            Q_FOREACH(const QString &desktopFile, searchDir.entryList(QStringList() << "*.desktop")) {
                if (desktopFile.startsWith(helper)) {
                    QFileInfo fileInfo(searchDir, desktopFile);
                    return fileInfo.absoluteFilePath();
                }
            }
        }

        dashPos = helper.indexOf("-");
    } while (dashPos != -1);

    return QString();
}

QString DesktopFileHandler::displayName(const QString &appId) const
{
    QString desktopFile = findDesktopFile(appId);
    if (desktopFile.isEmpty()) {
        return QString();
    }

    QSettings settings(desktopFile, QSettings::IniFormat);
    return settings.value("Desktop Entry/Name").toString();
}

QString DesktopFileHandler::icon(const QString &appId) const
{
    QString desktopFile = findDesktopFile(appId);
    if (desktopFile.isEmpty()) {
        return QString();
    }

    QSettings settings(desktopFile, QSettings::IniFormat);
    QString iconString = settings.value("Desktop Entry/Icon").toString();
    QString pathString = settings.value("Desktop Entry/Path").toString();

    if (QFileInfo(iconString).exists()) {
        return QFileInfo(iconString).absoluteFilePath();
    } else if (QFileInfo(pathString + '/' + iconString).exists()) {
        return pathString + '/' + iconString;
    }
    return "image://theme/" + iconString;
}

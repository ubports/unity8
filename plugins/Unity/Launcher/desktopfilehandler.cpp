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
#include <QLocale>

#include <libintl.h>

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
    settings.beginGroup("Desktop Entry");

    // First try to find Name[xx_YY] and Name[xx] in .desktop file
    QString locale = QLocale::system().name();
    QString shortLocale = locale.split('_').first();

    if (locale != shortLocale && settings.contains(QString("Name[%1]").arg(locale))) {
        return settings.value(QString("Name[%1]").arg(locale)).toString();
    }

    if (settings.contains(QString("Name[%1]").arg(shortLocale))) {
        return settings.value(QString("Name[%1]").arg(shortLocale)).toString();
    }

    // No translation found in desktop file. Get the untranslated one and have a go with gettext.
    QString displayName = settings.value("Name").toString();

    if (settings.contains("X-Ubuntu-Gettext-Domain")) {
        const QString domain = settings.value("X-Ubuntu-Gettext-Domain").toString();
        return dgettext(domain.toUtf8().constData(), displayName.toUtf8().constData());
    }

    return displayName;
}

QString DesktopFileHandler::icon(const QString &appId) const
{
    QString desktopFile = findDesktopFile(appId);
    if (desktopFile.isEmpty()) {
        return QString();
    }

    QSettings settings(desktopFile, QSettings::IniFormat);
    settings.beginGroup("Desktop Entry");
    QString iconString = settings.value("Icon").toString();
    QString pathString = settings.value("Path").toString();

    if (QFileInfo(iconString).exists()) {
        return QFileInfo(iconString).absoluteFilePath();
    } else if (QFileInfo(pathString + '/' + iconString).exists()) {
        return pathString + '/' + iconString;
    }
    return "image://theme/" + iconString;
}

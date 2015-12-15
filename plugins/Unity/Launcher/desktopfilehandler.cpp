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

DesktopFileHandler::DesktopFileHandler(const QString &appId, QObject *parent):
    QObject(parent),
    m_appId(appId)
{
    load();
}

QString DesktopFileHandler::appId() const
{
    return m_appId;
}

void DesktopFileHandler::setAppId(const QString &appId)
{
    if (m_appId != appId) {
        m_appId = appId;
        load();
    }
}

QString DesktopFileHandler::filename() const
{
    return m_filename;
}

bool DesktopFileHandler::isValid() const
{
    return !m_filename.isEmpty();
}

void DesktopFileHandler::load()
{
    m_filename.clear();

    if (m_appId.isEmpty()) {
        return;
    }

    int dashPos = -1;
    QString helper = m_appId;

    QStringList searchDirs = QStandardPaths::standardLocations(QStandardPaths::ApplicationsLocation);
#ifdef LAUNCHER_TESTING
    searchDirs << QStringLiteral(".");
#endif

    QString path;
    do {
        if (dashPos != -1) {
            helper.replace(dashPos, 1, '/');
        }

        if (helper.contains('/')) {
            path += helper.split('/').at(0) + '/';
            helper.remove(QRegExp("^" + path));
        }

        Q_FOREACH(const QString &searchDirName, searchDirs) {
            QDir searchDir(searchDirName + "/" + path);
            const QString desktop = QStringLiteral("*.desktop");
            Q_FOREACH(const QString &desktopFile, searchDir.entryList(QStringList() << desktop)) {
                if (desktopFile.startsWith(helper)) {
                    QFileInfo fileInfo(searchDir, desktopFile);
                    m_filename = fileInfo.absoluteFilePath();
                    return;
                }
            }
        }

        dashPos = helper.indexOf('-');
    } while (dashPos != -1);
}

QString DesktopFileHandler::displayName() const
{
    if (!isValid()) {
        return QString();
    }

    QSettings settings(m_filename, QSettings::IniFormat);
    settings.setIniCodec("UTF-8");
    settings.beginGroup(QStringLiteral("Desktop Entry"));

    // First try to find Name[xx_YY] and Name[xx] in .desktop file
    const QString locale = QLocale().name();
    const QStringList splitLocale = locale.split(QLatin1Char('_'));
    const QString shortLocale = splitLocale.first();

    if (locale != shortLocale && settings.contains(QStringLiteral("Name[%1]").arg(locale))) {
        return settings.value(QStringLiteral("Name[%1]").arg(locale)).toString();
    }

    if (settings.contains(QStringLiteral("Name[%1]").arg(shortLocale))) {
        return settings.value(QStringLiteral("Name[%1]").arg(shortLocale)).toString();
    }

    // No translation found in desktop file. Get the untranslated one and have a go with gettext.
    QString displayName = settings.value(QStringLiteral("Name")).toString();

    if (settings.contains(QStringLiteral("X-Ubuntu-Gettext-Domain"))) {
        const QString domain = settings.value(QStringLiteral("X-Ubuntu-Gettext-Domain")).toString();
        return dgettext(domain.toUtf8().constData(), displayName.toUtf8().constData());
    }

    return displayName;
}

QString DesktopFileHandler::icon() const
{
    if (!isValid()) {
        return QString();
    }

    QSettings settings(m_filename, QSettings::IniFormat);
    settings.setIniCodec("UTF-8");
    settings.beginGroup(QStringLiteral("Desktop Entry"));
    QString iconString = settings.value(QStringLiteral("Icon")).toString();
    QString pathString = settings.value(QStringLiteral("Path")).toString();

    if (QFileInfo(iconString).exists()) {
        return QFileInfo(iconString).absoluteFilePath();
    } else if (QFileInfo(pathString + '/' + iconString).exists()) {
        return pathString + '/' + iconString;
    }
    return "image://theme/" + iconString;
}

/*
 * Copyright (C) 2019 UBports Foundation
 * Author(s): Marius Gripsgard <marius@ubports.com>
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

#include "xdgwatcher.h"

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QTextStream>

XdgWatcher::XdgWatcher(QObject* parent)
    : QObject(parent),
      m_watcher(new QFileSystemWatcher(this))
{
    connect(m_watcher, &QFileSystemWatcher::directoryChanged, this, &XdgWatcher::onDirectoryChanged);
    connect(m_watcher, &QFileSystemWatcher::fileChanged, this, &XdgWatcher::onFileChanged);

    const auto paths = QStandardPaths::standardLocations(QStandardPaths::ApplicationsLocation);
    for (const auto &path: paths) {
        const auto qdir = QDir(path);
        if (!qdir.exists()) {
            continue;
        }

        // Add the path itself to watch for newly added apps
        m_watcher->addPath(path);

        // Add watcher for eatch app to watch for changes
        const auto files = qdir.entryInfoList(QDir::Files);
        for (const auto &file: files) {
            if (file.suffix() == "desktop") {
                const auto path = file.absoluteFilePath();
                m_watcher->addPath(path);
                m_registry.insert(path, getAppId(file));
            }
        }
    }
}

// "Lomiri style" appID is filename without versionNumber after last "_"
const QString XdgWatcher::stripAppIdVersion(const QString rawAppID) const {
    auto appIdComponents = rawAppID.split("_");
    appIdComponents.removeLast();
    return appIdComponents.join("_");
}

// Standard appID see:
// https://standards.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html#desktop-file-id
const QString XdgWatcher::toStandardAppId(const QFileInfo fileInfo) const {
    const auto paths = QStandardPaths::standardLocations(QStandardPaths::ApplicationsLocation);
    for (const auto &path: paths) {
        if (fileInfo.absolutePath() == path) {
            break;
        }
        if (fileInfo.absolutePath().contains(path)) {
            auto fileStr = fileInfo.absoluteFilePath();
            fileStr.replace(path, "");
            fileStr.replace("/", "-");
            fileStr.replace(".desktop", "");
            return fileStr;
        }
    }
    return fileInfo.completeBaseName();
}

const QString XdgWatcher::getAppId(const QFileInfo fileInfo) const {
    // We need to open the file to check if its and Ual application
    // as we cant just rely on the app name as "normal" apps can also
    // contain 3 _ causing us to belive its an lomiri app
    // Example kde_org_kate would become kde_org
    QFile qFile(fileInfo.absoluteFilePath());
    qFile.open(QIODevice::ReadOnly);
    QTextStream fileStream(&qFile);
    QString line;
    while (fileStream.readLineInto(&line)) {
        if (line.startsWith("X-Lomiri-Application-ID=")) {
            auto rawAppID = line.replace("X-Lomiri-Application-ID=", "");
            qFile.close();
            return stripAppIdVersion(rawAppID);
        }
    }
    qFile.close();

    // If it's not an "Lomiri" appID, we follow freedesktop standard
    return toStandardAppId(fileInfo);
}

// Watch for newly added apps
void XdgWatcher::onDirectoryChanged(const QString &path) {
    const auto files = QDir(path).entryInfoList(QDir::Files);
    const auto watchedFiles = m_watcher->files();
    for (const auto &file: files) {
        const auto appPath = file.absoluteFilePath();
        if (file.suffix() == "desktop" && !watchedFiles.contains(appPath)) {
            m_watcher->addPath(appPath);

            const auto appId = getAppId(file);
            m_registry.insert(appPath, appId);
            Q_EMIT appAdded(appId);
        }
    }
}

void XdgWatcher::onFileChanged(const QString &path) {
    QFileInfo file(path);
    if (file.exists()) {
        // The file exists, this must be an modify event
        Q_EMIT appInfoChanged(m_registry.value(path));
    } else {
        // File does not exist, assume this is an remove event.
        // onDirectoryChanged will handle rename event
        Q_EMIT appRemoved(m_registry.take(path));
    }
}

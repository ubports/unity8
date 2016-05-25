/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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

#include "ScreenshotDirectory.h"

#include <QDir>
#include <QDateTime>
#include <QStandardPaths>
#include <QTemporaryDir>

#include <QDebug>

ScreenshotDirectory::ScreenshotDirectory(QObject *parent)
    : QObject(parent)
{
    QDir screenshotsDir;
    if (qEnvironmentVariableIsSet("UNITY_TESTING")) {
        QTemporaryDir tDir;
        tDir.setAutoRemove(false);
        screenshotsDir = tDir.path();
    } else {
        screenshotsDir = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    }
    screenshotsDir.mkpath(QStringLiteral("Screenshots"));
    screenshotsDir.cd(QStringLiteral("Screenshots"));
    if (screenshotsDir.exists()) {
        m_fileNamePrefix = screenshotsDir.absolutePath();
        m_fileNamePrefix.append("/screenshot");
    } else {
        qWarning() << "ScreenshotDirectory: failed to create directory at:" << screenshotsDir.absolutePath();
    }
}

QString ScreenshotDirectory::makeFileName() const
{
    if (m_fileNamePrefix.isEmpty()) {
        return QString();
    }

    QString fileName(m_fileNamePrefix);
    fileName.append(QDateTime::currentDateTime().toString(QStringLiteral("yyyyMMdd_hhmmsszzz")));
    fileName.append(".");
    fileName.append(format());
    return fileName;
}

QString ScreenshotDirectory::format() const
{
    //TODO: This should be configurable (perhaps through gsettings?)
    return QStringLiteral("png");
}

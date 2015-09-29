/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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

#include "screengrabber.h"

#include <QDir>
#include <QDateTime>
#include <QStandardPaths>
#include <QTemporaryDir>
#include <QtGui/QImage>
#include <QtGui/QGuiApplication>
#include <QtQuick/QQuickWindow>
#include <QtConcurrent/QtConcurrentRun>

#include <QDebug>

bool saveScreenshot(const QImage &screenshot, const QString &filename, const QString &format, int quality)
{
    if (!screenshot.save(filename, format.toLatin1().data(), quality)) {
        qWarning() << "ScreenGrabber: failed to save snapshot!";
        return false;
    }

    return true;
}

ScreenGrabber::ScreenGrabber(QObject *parent)
    : QObject(parent)
{
    QDir screenshotsDir;
    if (qEnvironmentVariableIsSet("UNITY_TESTING")) {
        qDebug() << "Using test environment";
        QTemporaryDir tDir;
        tDir.setAutoRemove(false);
        screenshotsDir = tDir.path();
    } else {
        qDebug() << "Using real environment";
        screenshotsDir = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    }
    screenshotsDir.mkpath(QStringLiteral("Screenshots"));
    screenshotsDir.cd(QStringLiteral("Screenshots"));
    if (screenshotsDir.exists()) {
        fileNamePrefix = screenshotsDir.absolutePath();
        fileNamePrefix.append("/screenshot");
    } else {
        qWarning() << "ScreenGrabber: failed to create directory at: " << screenshotsDir.absolutePath();
    }
}

void ScreenGrabber::captureAndSave()
{
    if (fileNamePrefix.isEmpty())
    {
        qWarning() << "ScreenShotter: no directory to save screenshot";
        return;
    }

    const QWindowList windows = QGuiApplication::topLevelWindows();
    if (windows.empty())
    {
        qWarning() << "ScreenShotter: no top level windows found!";
        return;
    }

    QQuickWindow *main_window = qobject_cast<QQuickWindow *>(windows[0]);
    if (!main_window)
    {
        qWarning() << "ScreenShotter: can only take screenshots of QQuickWindows";
        return;
    }

    const QImage screenshot = main_window->grabWindow();
    const QString filename = makeFileName();
    qDebug() << "Saving screenshot to" << filename;
    auto saveOp = QtConcurrent::run(saveScreenshot, screenshot, filename, getFormat(), screenshotQuality);
    if (saveOp.result()) {
        Q_EMIT screenshotSaved(filename);
    }
}

QString ScreenGrabber::makeFileName() const
{
    QString fileName(fileNamePrefix);
    fileName.append(QDateTime::currentDateTime().toString(QStringLiteral("yyyyMMdd_hhmmsszzz")));
    fileName.append(".");
    fileName.append(getFormat());
    return fileName;
}

QString ScreenGrabber::getFormat() const
{
    //TODO: This should be configurable (perhaps through gsettings?)
    return QStringLiteral("png");
}

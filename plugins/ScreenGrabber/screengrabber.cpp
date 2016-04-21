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

#include <QDebug>

QString saveScreenshot(const QImage &screenshot, const QString &filename, const QString &format, int quality)
{
    if (screenshot.save(filename, format.toLatin1().data(), quality)) {
        return filename;
    } else {
        qWarning() << "ScreenGrabber: failed to save snapshot!";
    }
    return QString();
}

ScreenGrabber::ScreenGrabber(QObject *parent)
    : QObject(parent)
{
    QObject::connect(&m_watcher,
                     &QFutureWatcher<QString>::finished,
                     this,
                     &ScreenGrabber::onScreenshotSaved);

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
        fileNamePrefix = screenshotsDir.absolutePath();
        fileNamePrefix.append("/screenshot");
    } else {
        qWarning() << "ScreenGrabber: failed to create directory at: " << screenshotsDir.absolutePath();
    }
}

void ScreenGrabber::captureAndSave(int angle)
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

    const QImage screenshot = main_window->grabWindow().transformed(QTransform().rotate(angle));
    const QString filename = makeFileName();
    qDebug() << "Saving screenshot to" << filename;
    QFuture<QString> saveFuture(QtConcurrent::run(saveScreenshot, screenshot, filename, getFormat(), screenshotQuality));
    m_watcher.setFuture(saveFuture);
}

void ScreenGrabber::onScreenshotSaved()
{
    const QString filename = m_watcher.future().result();
    if (!filename.isEmpty()) {
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

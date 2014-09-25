/*
 * Copyright (C) 2014 Canonical, Ltd.
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
 *
 * Authors: Alberto Aguirre <alberto.aguirre@canonical.com>
 */

#include "screenshotter.h"

#include <QDir>
#include <QDateTime>
#include <QStandardPaths>
#include <QtGui/QGuiApplication>
#include <QtQuick/QQuickWindow>

#include <QDebug>

ScreenShotter::ScreenShotter(QObject *parent)
    : QObject(parent),
      screenshotQuality(90)
{
    QDir screenshotsDir(QStandardPaths::displayName(QStandardPaths::PicturesLocation));
    screenshotsDir.mkdir("Screenshots");
    screenshotsDir.cd("Screenshots");
    if (screenshotsDir.exists())
    {
        fileNamePrefix = screenshotsDir.absolutePath();
        fileNamePrefix.append("/screenshot");
    }
    else
    {
        qWarning() << "ScreenShotter: failed to create directory at: " << screenshotsDir.absolutePath();
    }
}

void ScreenShotter::takeScreenshot()
{
    if (fileNamePrefix.isEmpty())
    {
        qWarning() << "ScreenShotter: no directory to save screenshot";
        return;
    }

    QWindowList windows = QGuiApplication::topLevelWindows();
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

    QImage snapshot = main_window->grabWindow();
    if (!snapshot.save(makeFileName(), getFormat().toLatin1().data(), screenshotQuality))
        qWarning() << "ScreenShotter: failed to save snapshot!";
}

QString ScreenShotter::makeFileName()
{
    QString fileName(fileNamePrefix);
    fileName.append(QDateTime::currentDateTime().toString("yyyymmdd_hhmmsszzz"));
    fileName.append(".");
    fileName.append(getFormat());
    return fileName;
}

QString ScreenShotter::getFormat()
{
    //TODO: Maybe this could be configurable
    return "jpg";
}

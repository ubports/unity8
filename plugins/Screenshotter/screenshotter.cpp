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

#include <QUuid>
#include <QChar>
#include <QString>
#include <QStringList>
#include <QStandardPaths>
#include <QtGui/QGuiApplication>
#include <QtQuick/QQuickWindow>

#include <QDebug>

ScreenShotter::ScreenShotter(QObject *parent)
    : QObject(parent),
      screenshotsDir(QStandardPaths::displayName(QStandardPaths::PicturesLocation)),
      screenshotQuality(90)
{
    screenshotsDir.mkdir("Screenshots");
    screenshotsDir.cd("Screenshots");
}

void ScreenShotter::takeScreenshot()
{
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
    if (!snapshot.save(generateName(), "JPG", screenshotQuality))
        qWarning() << "ScreenShotter: failed to save snapshot!";
}

QString ScreenShotter::generateUniqueNum()
{
    // First lets look for existing files using our numbering pattern
    QStringList nameFilter;
    nameFilter << "screenshot????.jpg";
    QStringList fileList = screenshotsDir.entryList(nameFilter, QDir::Files, QDir::Name | QDir::Reversed);

    if (!fileList.empty())
    {
        Q_FOREACH(QString const& fileName, fileList)
        {
            // Just the the four digit number
            QString fileNumber = fileName.mid(10, 4);
            bool ok = false;
            int num = fileNumber.toInt(&ok) + 1;
            if (!ok)
                continue;

            // OK it's an actual number
            if (num <= 9999)
            {
                // Produce a string that has the next sequential number, appending 0's when necessary
                return QString("%1").arg(num, 4, 10, QChar('0'));
            }
            else
            {
                // 10000 screenshots huh? ummm, well let's start using uuids then...
                QString uuid = QUuid::createUuid().toString();
                // Remove the curly brackets
                return uuid.mid(1, 36);
            }
        }
    }
    //No files exist using our numbering scheme
    return QString("0000");
}

QString ScreenShotter::generateName()
{
    QString fileName = screenshotsDir.absolutePath();
    fileName.append("/screenshot");
    fileName.append(generateUniqueNum());
    fileName.append(".jpg");
    return fileName;
}

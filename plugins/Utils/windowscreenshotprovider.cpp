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
 */

#include "windowscreenshotprovider.h"

#include <QGuiApplication>
#include <QQuickWindow>

WindowScreenshotProvider::WindowScreenshotProvider()
    : QQuickImageProvider(QQmlImageProviderBase::Image, 0)
{
}

// A very simple implementation where we assume that there's only one window and that it's a
// QQuickWindow. Thus the id parameter is irrelevant.
//
// Idea: Make the id contain the objectName of the QQuickWindow once we care about a multi-display
//       compositor?
//       Strictly speaking that could be the actual QWindow::winId(), but that's mostly a
//       meaningless arbitrary number.
QImage WindowScreenshotProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(id);
    Q_UNUSED(requestedSize);

    QWindowList windows = QGuiApplication::topLevelWindows();

    if (windows.count() != 1) {
        size->rwidth() = 0;
        size->rheight() = 0;
        return QImage();
    }

    QQuickWindow *quickWindow = qobject_cast<QQuickWindow *>(windows[0]);

    if (!quickWindow) {
        size->rwidth() = 0;
        size->rheight() = 0;
        return QImage();
    }

    QImage image = quickWindow->grabWindow();
    size->rwidth() = image.width();
    size->rheight() = image.height();
    return image;
}

/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "ApplicationScreenshotProvider.h"
#include "ApplicationManager.h"
#include "ApplicationInfo.h"

#include "paths.h"

#include <QDebug>
#include <QGuiApplication>
#include <QWindow>
#include <QQuickWindow>

ApplicationScreenshotProvider::ApplicationScreenshotProvider(ApplicationManager *appManager)
    : QQuickImageProvider(QQuickImageProvider::Image)
    , m_appManager(appManager)
{
}

QImage ApplicationScreenshotProvider::requestImage(const QString &imageId, QSize * size,
                                                     const QSize &requestedSize)
{
    // We ignore requestedSize here intentionally to avoid keeping scaled copies around
    Q_UNUSED(requestedSize)

    QString appId = imageId.split('/').first();

    ApplicationInfo* app = static_cast<ApplicationInfo*>(m_appManager->findApplication(appId));
    if (app == nullptr) {
        return QImage();
    }

    QString screenshot = app->screenshot();
    // QImage doesn't understand qrc:/// but we have QUrls in use which don't like the empty protcol ":/"
    screenshot.replace("qrc:///", ":/");

    QImage image;
    if (!image.load(screenshot)) {
        qWarning() << "failed loading app image" << screenshot;
    }


    if (app->stage() == ApplicationInfo::SideStage) {
        QByteArray gus = qgetenv("GRID_UNIT_PX");
        if (gus.isEmpty() || gus.toInt() == 0) {
            gus = "8";
        }
        image = image.scaledToWidth(gus.toInt() * 48);
    } else {
        // Lets scale main stage applications to be the size of the screen/window.
        QGuiApplication *unity = qobject_cast<QGuiApplication*>(qApp);
        Q_FOREACH (QWindow *win, unity->allWindows()) {
            QQuickWindow *quickWin = qobject_cast<QQuickWindow*>(win);
            if (quickWin) {
                image = image.scaledToWidth(quickWin->width());
                break;
            }
        }
    }

    size->setWidth(image.width());
    size->setHeight(image.height());

    return image;
}

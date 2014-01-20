/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#ifndef APPLICATIONSCREENSHOTPROVIDER_H
#define APPLICATIONSCREENSHOTPROVIDER_H

#include <QQuickImageProvider>

class ApplicationManager;
class ApplicationScreenshotProvider : public QQuickImageProvider
{
public:
    explicit ApplicationScreenshotProvider(ApplicationManager *appManager);

    QImage requestImage(const QString &appId, QSize *size, const QSize &requestedSize) override;

private:
    ApplicationManager* m_appManager;
};

#endif // APPLICATIONSCREENSHOTPROVIDER_H

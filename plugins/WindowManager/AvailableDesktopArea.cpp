/*
 * Copyright (C) 2017 Canonical, Ltd.
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

#include "AvailableDesktopArea.h"

#include <QGuiApplication>
#include <QQuickWindow>
#include <qpa/qplatformnativeinterface.h>

AvailableDesktopArea::AvailableDesktopArea(QQuickItem *parent)
    : QQuickItem(parent)
{
    connect(this, &QQuickItem::xChanged, this, &AvailableDesktopArea::updatePlatformWindowProperty);
    connect(this, &QQuickItem::yChanged, this, &AvailableDesktopArea::updatePlatformWindowProperty);
    connect(this, &QQuickItem::widthChanged, this, &AvailableDesktopArea::updatePlatformWindowProperty);
    connect(this, &QQuickItem::heightChanged, this, &AvailableDesktopArea::updatePlatformWindowProperty);
}

void AvailableDesktopArea::updatePlatformWindowProperty()
{
    if (!window()) {
        return;
    }

    QPlatformNativeInterface *nativeInterface = QGuiApplication::platformNativeInterface();

    QRect rect(x(), y(), width(), height());

    nativeInterface->setWindowProperty(window()->handle(), "availableDesktopArea", QVariant(rect));
}

void AvailableDesktopArea::itemChange(ItemChange change, const ItemChangeData &)
{
    if (change == ItemSceneChange) {
        updatePlatformWindowProperty();
    }
}

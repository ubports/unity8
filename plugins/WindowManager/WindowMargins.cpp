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

#include "WindowMargins.h"

#include <QGuiApplication>
#include <QQuickWindow>
#include <qpa/qplatformnativeinterface.h>

void WindowMargins::setNormal(QRectF value)
{
    if (m_normal == value) {
        return;
    }

    m_normal = value;

    if (window()) {
        QPlatformNativeInterface *nativeInterface = QGuiApplication::platformNativeInterface();
        nativeInterface->setWindowProperty(window()->handle(), "normalWindowMargins", QVariant(m_normal.toRect()));
    }

    Q_EMIT normalChanged();
}

QRectF WindowMargins::normal() const
{
    return m_normal;
}

void WindowMargins::setDialog(QRectF value)
{
    if (m_dialog == value) {
        return;
    }

    m_dialog = value;

    if (window()) {
        QPlatformNativeInterface *nativeInterface = QGuiApplication::platformNativeInterface();
        nativeInterface->setWindowProperty(window()->handle(), "dialogWindowMargins", QVariant(m_dialog.toRect()));
    }

    Q_EMIT dialogChanged();
}

QRectF WindowMargins::dialog() const
{
    return m_dialog;
}

void WindowMargins::itemChange(ItemChange change, const ItemChangeData &data)
{
    if (change == ItemSceneChange && data.window != nullptr) {
        QPlatformNativeInterface *nativeInterface = QGuiApplication::platformNativeInterface();
        if (!m_normal.isNull()) {
            nativeInterface->setWindowProperty(data.window->handle(), "normalWindowMargins", QVariant(m_normal.toRect()));
            nativeInterface->setWindowProperty(data.window->handle(), "dialogWindowMargins", QVariant(m_dialog.toRect()));
        }
    }
}

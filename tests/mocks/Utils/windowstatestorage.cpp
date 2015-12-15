/*
 * Copyright 2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include "windowstatestorage.h"

WindowStateStorage::WindowStateStorage(QObject *parent):
    QObject(parent)
{
}

void WindowStateStorage::setGeometry(const QVariantMap& geometry)
{
    if (geometry != m_geometry) {
        m_geometry = geometry;
        Q_EMIT geometryChanged(m_geometry);
    }
}

QVariantMap WindowStateStorage::geometry() const
{
    return m_geometry;
}

void WindowStateStorage::saveGeometry(const QString &windowId, const QRect &rect)
{
    m_geometry[windowId] = rect;
}

QRect WindowStateStorage::getGeometry(const QString &windowId, const QRect &defaultValue)
{
    if (!m_geometry.contains(windowId)) return defaultValue;
    return m_geometry.value(windowId).toRect();
}

void WindowStateStorage::clear()
{
    m_state.clear();
    m_geometry.clear();
}

void WindowStateStorage::saveState(const QString &windowId, WindowState state)
{
    m_state[windowId] = state;
}

WindowStateStorage::WindowState WindowStateStorage::getState(const QString &windowId, WindowStateStorage::WindowState defaultValue)
{
    if (!m_state.contains(windowId)) return defaultValue;
    return m_state.value(windowId);
}

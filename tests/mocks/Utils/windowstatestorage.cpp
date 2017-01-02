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

#include <unity/shell/application/ApplicationInfoInterface.h>

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

QRect WindowStateStorage::getGeometry(const QString &windowId, const QRect &defaultValue) const
{
    if (!m_geometry.contains(windowId)) return defaultValue;
    return m_geometry.value(windowId).toRect();
}

void WindowStateStorage::saveStage(const QString &appId, int stage)
{
    m_stage[appId] = stage;
    Q_EMIT stageSaved(appId, stage);
}

int WindowStateStorage::getStage(const QString &appId, int defaultValue) const
{
    return m_stage.value(appId, defaultValue);
}

void WindowStateStorage::clear()
{
    m_state.clear();
    m_geometry.clear();
    m_stage.clear();
}

void WindowStateStorage::saveState(const QString &windowId, WindowState state)
{
    m_state[windowId] = state;
}

WindowStateStorage::WindowState WindowStateStorage::getState(const QString &windowId, WindowStateStorage::WindowState defaultValue) const
{
    if (!m_state.contains(windowId)) return defaultValue;
    return m_state.value(windowId);
}

Mir::State WindowStateStorage::toMirState(WindowState state) const
{
    // assumes a single state (not an OR of several)
    switch (state) {
        case WindowStateMaximized:             return Mir::MaximizedState;
        case WindowStateMinimized:             return Mir::MinimizedState;
        case WindowStateFullscreen:            return Mir::FullscreenState;
        case WindowStateMaximizedLeft:         return Mir::MaximizedLeftState;
        case WindowStateMaximizedRight:        return Mir::MaximizedRightState;
        case WindowStateMaximizedHorizontally: return Mir::HorizMaximizedState;
        case WindowStateMaximizedVertically:   return Mir::VertMaximizedState;
        case WindowStateMaximizedTopLeft:      return Mir::MaximizedTopLeftState;
        case WindowStateMaximizedTopRight:     return Mir::MaximizedTopRightState;
        case WindowStateMaximizedBottomLeft:   return Mir::MaximizedBottomLeftState;
        case WindowStateMaximizedBottomRight:  return Mir::MaximizedBottomRightState;

        case WindowStateNormal:
        case WindowStateRestored:
        default:
            return Mir::RestoredState;
    }
}

/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#include "CursorImageInfo.h"

CursorImageInfo::CursorImageInfo(QObject *parent)
    : QObject(parent)
{
    m_updateTimer.setInterval(0);
    m_updateTimer.setSingleShot(true);
    connect(&m_updateTimer, &QTimer::timeout, this, &CursorImageInfo::update);
}

void CursorImageInfo::setCursorName(const QString &cursorName)
{
    if (cursorName != m_cursorName) {
        scheduleUpdate();
        m_cursorName = cursorName;
        Q_EMIT cursorNameChanged();
    }
}

void CursorImageInfo::setThemeName(const QString &themeName)
{
    if (m_themeName != themeName) {
        scheduleUpdate();
        m_themeName = themeName;
        Q_EMIT themeNameChanged();
    }
}

void CursorImageInfo::scheduleUpdate()
{
    if (!m_updateTimer.isActive()) {
        if (m_ready) {
            m_ready = false;
            Q_EMIT readyChanged();
        }
        m_updateTimer.start();
    }
}

void CursorImageInfo::update()
{
    m_cursorImage = CursorImageProvider::instance()->fetchCursor(m_themeName, m_cursorName);

    Q_EMIT hotspotChanged();
    Q_EMIT frameWidthChanged();
    Q_EMIT frameHeightChanged();
    Q_EMIT frameCountChanged();
    Q_EMIT frameDurationChanged();

    Q_ASSERT(!m_ready);
    m_ready = true;
    Q_EMIT readyChanged();
}

QPoint CursorImageInfo::hotspot() const
{
    if (m_cursorImage) {
        return m_cursorImage->hotspot;
    } else {
        return QPoint();
    }
}

qreal CursorImageInfo::frameWidth() const
{
    if (m_cursorImage) {
        return m_cursorImage->frameWidth;
    } else {
        return 0;
    }
}

qreal CursorImageInfo::frameHeight() const
{
    if (m_cursorImage) {
        return m_cursorImage->frameHeight;
    } else {
        return 0;
    }
}

int CursorImageInfo::frameCount() const
{
    if (m_cursorImage) {
        return m_cursorImage->frameCount;
    } else {
        return 0;
    }
}

int CursorImageInfo::frameDuration() const
{
    if (m_cursorImage) {
        return m_cursorImage->frameDuration;
    } else {
        return 0;
    }
}

bool CursorImageInfo::ready() const
{
    return m_ready;
}

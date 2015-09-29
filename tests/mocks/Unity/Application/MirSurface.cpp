/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "MirSurface.h"

#include <QDebug>

MirSurface::MirSurface(const QString& name,
        Mir::Type type,
        Mir::State state,
        const QUrl& screenshot,
        const QUrl &qmlFilePath)
    : unity::shell::application::MirSurfaceInterface(nullptr)
    , m_name(name)
    , m_type(type)
    , m_state(state)
    , m_orientationAngle(Mir::Angle0)
    , m_screenshotUrl(screenshot)
    , m_qmlFilePath(qmlFilePath)
    , m_live(true)
    , m_viewCount(0)
    , m_activeFocus(false)
    , m_width(-1)
    , m_height(-1)
{
//    qDebug() << "MirSurface::MirSurface() " << name;
}

MirSurface::~MirSurface()
{
//    qDebug() << "MirSurface::~MirSurface() " << name();
}

QString MirSurface::name() const
{
    return m_name;
}

Mir::Type MirSurface::type() const
{
    return m_type;
}

Mir::State MirSurface::state() const
{
    return m_state;
}

void MirSurface::setState(Mir::State state)
{
    if (state == m_state)
        return;

    m_state = state;
    Q_EMIT stateChanged(state);
}

bool MirSurface::live() const
{
    return m_live;
}

void MirSurface::setLive(bool live)
{
//    qDebug().nospace() << "MirSurface::setLive("<<live<<") " << name();
    if (live == m_live)
        return;

    m_live = live;
    Q_EMIT liveChanged(live);

    if (!m_live && m_viewCount == 0) {
        deleteLater();
    }
}

QUrl MirSurface::qmlFilePath() const
{
    return m_qmlFilePath;
}

QUrl MirSurface::screenshotUrl() const
{
    return m_screenshotUrl;
}

void MirSurface::setScreenshotUrl(QUrl screenshotUrl)
{
    if (screenshotUrl == m_screenshotUrl)
        return;

    m_screenshotUrl = screenshotUrl;
    Q_EMIT screenshotUrlChanged(screenshotUrl);
}

Mir::OrientationAngle MirSurface::orientationAngle() const
{
    return m_orientationAngle;
}

void MirSurface::setOrientationAngle(Mir::OrientationAngle angle)
{
    if (angle == m_orientationAngle)
        return;

    m_orientationAngle = angle;
    Q_EMIT orientationAngleChanged(angle);
}

void MirSurface::incrementViewCount()
{
    ++m_viewCount;
//    qDebug().nospace() << "MirSurface::incrementViewCount() viewCount(after)=" << m_viewCount << " " << name();
}

void MirSurface::decrementViewCount()
{
    --m_viewCount;
//    qDebug().nospace() << "MirSurface::decrementViewCount() viewCount(after)=" << m_viewCount << " " << name();

    Q_ASSERT(m_viewCount >= 0);

    if (!m_live && m_viewCount == 0) {
        deleteLater();
    }
}

int MirSurface::viewCount() const
{
    return m_viewCount;
}

bool MirSurface::activeFocus() const
{
    return m_activeFocus;
}

void MirSurface::setActiveFocus(bool value)
{
    if (m_activeFocus == value)
        return;

    m_activeFocus = value;

    Q_EMIT activeFocusChanged(value);
}

int MirSurface::width() const
{
    return m_width;
}

int MirSurface::height() const
{
    return m_height;
}

void MirSurface::resize(int width, int height)
{
    bool changed = false;
    if (width != m_width) {
        m_width = width;
        Q_EMIT widthChanged();
        changed = true;
    }

    if (m_height != height) {
        m_height = height;
        Q_EMIT heightChanged();
        changed = true;
    }

    if (changed) {
        Q_EMIT sizeChanged(QSize(width, height));
    }
}

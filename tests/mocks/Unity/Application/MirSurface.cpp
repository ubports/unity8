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
#include <QQmlEngine>

MirSurface::MirSurface(const QString& name,
        Mir::Type type,
        Mir::State state,
        const QUrl& screenshot,
        const QUrl &qmlFilePath,
        QObject *parent)
    : unity::shell::application::MirSurfaceInterface(parent)
    , m_name(name)
    , m_type(type)
    , m_state(state)
    , m_orientationAngle(Mir::Angle0)
    , m_screenshotUrl(screenshot)
    , m_qmlFilePath(qmlFilePath)
    , m_live(true)
    , m_visible(true)
    , m_activeFocus(false)
    , m_width(-1)
    , m_height(-1)
    , m_slowToResize(false)
    , m_shellChrome(Mir::NormalChrome)
{
//    qDebug() << "MirSurface::MirSurface() " << name;
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);

    m_delayedResizeTimer.setInterval(600);
    m_delayedResizeTimer.setSingleShot(true);
    connect(&m_delayedResizeTimer, &QTimer::timeout, this, &MirSurface::applyDelayedResize);
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

bool MirSurface::visible() const
{
    return m_visible;
}

void MirSurface::setLive(bool live)
{
//    qDebug().nospace() << "MirSurface::setLive("<<live<<") " << name();
    if (live == m_live)
        return;

    m_live = live;
    Q_EMIT liveChanged(live);

    if (!m_live && m_views.count() == 0) {
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

Mir::ShellChrome MirSurface::shellChrome() const
{
    return m_shellChrome;
}

void MirSurface::setShellChrome(Mir::ShellChrome shellChrome)
{
    if (shellChrome == m_shellChrome)
        return;

    m_shellChrome = shellChrome;
    Q_EMIT shellChromeChanged(shellChrome);
}

QString MirSurface::keymapLayout() const
{
    return m_keyMap.first;
}

QString MirSurface::keymapVariant() const
{
    return m_keyMap.second;
}

void MirSurface::setKeymap(const QString &layout, const QString &variant)
{
    if (layout.isEmpty()) {
        return;
    }
    m_keyMap = qMakePair(layout, variant);
    Q_EMIT keymapChanged(layout, variant);
}

void MirSurface::registerView(qintptr viewId)
{
    m_views.insert(viewId, MirSurface::View{false});
//    qDebug().nospace() << "MirSurface[" << name() << "]::registerView(" << viewId << ")"
//                                      << " after=" << m_views.count();
}

void MirSurface::unregisterView(qintptr viewId)
{
//    qDebug().nospace() << "MirSurface[" << name() << "]::unregisterView(" << viewId << ")"
//                                      << " after=" << m_views.count() << " live=" << m_live;
    m_views.remove(viewId);
    if (!m_live && m_views.count() == 0) {
        deleteLater();
    }
    updateVisibility();
}

void MirSurface::setViewVisibility(qintptr viewId, bool visible)
{
    if (!m_views.contains(viewId)) return;

    m_views[viewId].visible = visible;
    updateVisibility();
}

void MirSurface::updateVisibility()
{
    bool newVisible = false;
    QHashIterator<qintptr, View> i(m_views);
    while (i.hasNext()) {
        i.next();
        newVisible |= i.value().visible;
    }

    if (newVisible != visible()) {
//        qDebug().nospace() << "MirSurface[" << name() << "]::updateVisibility(" << newVisible << ")";

        m_visible = newVisible;
        Q_EMIT visibleChanged(m_visible);
    }
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
    if (m_slowToResize) {
        if (!m_delayedResizeTimer.isActive()) {
            m_delayedResize.setWidth(width);
            m_delayedResize.setHeight(height);
            m_delayedResizeTimer.start();
        } else {
            m_pendingResize.setWidth(width);
            m_pendingResize.setHeight(height);
        }
    } else {
        doResize(width, height);
    }
}

void MirSurface::applyDelayedResize()
{
    doResize(m_delayedResize.width(), m_delayedResize.height());
    m_delayedResize.setWidth(-1);
    m_delayedResize.setHeight(-1);

    if (m_pendingResize.isValid()) {
        QSize size = m_pendingResize;
        m_pendingResize.setWidth(-1);
        m_pendingResize.setHeight(-1);
        resize(size.width(), size.height());
    }
}

void MirSurface::doResize(int width, int height)
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

bool MirSurface::isSlowToResize() const
{
    return m_slowToResize;
}

void MirSurface::setSlowToResize(bool value)
{
    if (m_slowToResize != value) {
        m_slowToResize = value;
        Q_EMIT slowToResizeChanged();
        if (!m_slowToResize && m_delayedResizeTimer.isActive()) {
            m_delayedResizeTimer.stop();
            applyDelayedResize();
        }
    }
}

void MirSurface::setMinimumWidth(int value)
{
    if (value != m_minimumWidth) {
        m_minimumWidth = value;
        Q_EMIT minimumWidthChanged(m_minimumWidth);
    }
}

void MirSurface::setMaximumWidth(int value)
{
    if (value != m_maximumWidth) {
        m_maximumWidth = value;
        Q_EMIT maximumWidthChanged(m_maximumWidth);
    }
}

void MirSurface::setMinimumHeight(int value)
{
    if (value != m_minimumHeight) {
        m_minimumHeight = value;
        Q_EMIT minimumHeightChanged(m_minimumHeight);
    }
}

void MirSurface::setMaximumHeight(int value)
{
    if (value != m_maximumHeight) {
        m_maximumHeight = value;
        Q_EMIT maximumHeightChanged(m_maximumHeight);
    }
}

void MirSurface::setWidthIncrement(int value)
{
    if (value != m_widthIncrement) {
        m_widthIncrement = value;
        Q_EMIT widthIncrementChanged(m_widthIncrement);
    }
}

void MirSurface::setHeightIncrement(int value)
{
    if (value != m_heightIncrement) {
        m_heightIncrement = value;
        Q_EMIT heightIncrementChanged(m_heightIncrement);
    }
}

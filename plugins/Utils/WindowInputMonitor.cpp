/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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

#include "WindowInputMonitor.h"

#include <QQuickWindow>

using namespace UnityUtil;

WindowInputMonitor::WindowInputMonitor(QQuickItem *parent)
    : WindowInputMonitor(new Timer, new ElapsedTimer, parent)
{
}

WindowInputMonitor::WindowInputMonitor(UnityUtil::AbstractTimer *timer,
        UnityUtil::AbstractElapsedTimer *elapsedTimer,
        QQuickItem *parent)
    : QQuickItem(parent)
    , m_windowBeingTouched(false)
    , m_windowLastTouchedTimer(elapsedTimer)
    , m_activationTimer(timer)
{
    m_windowLastTouchedTimer->start();

    connect(this, &QQuickItem::windowChanged,
            this, &WindowInputMonitor::setupFilterOnWindow);

    connect(m_activationTimer, &UnityUtil::AbstractTimer::timeout,
        this, &WindowInputMonitor::emitActivatedIfNoTouchesAround);
    m_activationTimer->setInterval(msecsWithoutTouches);
    m_activationTimer->setSingleShot(true);
}

WindowInputMonitor::~WindowInputMonitor()
{
    delete m_windowLastTouchedTimer;
    delete m_activationTimer;
}

bool WindowInputMonitor::eventFilter(QObject *watched, QEvent *event)
{
    Q_ASSERT(!m_filteredWindow.isNull());
    Q_ASSERT(watched == static_cast<QObject*>(m_filteredWindow.data()));
    Q_UNUSED(watched);

    update(event);

    // We're only monitoring, never filtering out events
    return false;
}

void WindowInputMonitor::update(QEvent *event)
{
    if (event->type() == QEvent::KeyPress) {
        QKeyEvent *keyEvent = static_cast<QKeyEvent*>(event);

        if (m_pressedHomeKey == 0 && m_homeKeys.contains(keyEvent->key()) && !keyEvent->isAutoRepeat()
                && !m_activationTimer->isRunning()
                && !m_windowBeingTouched
                && m_windowLastTouchedTimer->elapsed() >= msecsWithoutTouches) {
            m_pressedHomeKey = keyEvent->key();
            m_activationTimer->start();
        }

    } else if (event->type() == QEvent::KeyRelease) {
        QKeyEvent *keyEvent = static_cast<QKeyEvent*>(event);

        if (keyEvent->key() == m_pressedHomeKey) {
            m_pressedHomeKey = 0;
        }

    } else if (event->type() == QEvent::TouchBegin) {

        m_activationTimer->stop();
        m_windowBeingTouched = true;
        Q_EMIT touchBegun();

    } else if (event->type() == QEvent::TouchEnd) {

        m_windowBeingTouched = false;
        m_windowLastTouchedTimer->start();

        QTouchEvent * touchEv = static_cast<QTouchEvent *>(event);
        if (touchEv && !touchEv->touchPoints().isEmpty()) {
            const QPointF pos = touchEv->touchPoints().last().screenPos();
            Q_EMIT touchEnded(pos);
        }
    }
}

void WindowInputMonitor::setupFilterOnWindow(QQuickWindow *window)
{
    if (!m_filteredWindow.isNull()) {
        m_filteredWindow->removeEventFilter(this);
        m_filteredWindow.clear();
    }

    if (window) {
        window->installEventFilter(this);
        m_filteredWindow = window;
    }
}

void WindowInputMonitor::emitActivatedIfNoTouchesAround()
{
    if (m_pressedHomeKey == 0 && !m_windowBeingTouched &&
            (m_windowLastTouchedTimer->elapsed() > msecsWithoutTouches)) {
        Q_EMIT homeKeyActivated();
    }
}

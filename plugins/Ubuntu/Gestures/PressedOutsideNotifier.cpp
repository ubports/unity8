/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#include "PressedOutsideNotifier.h"

#include <QMouseEvent>

PressedOutsideNotifier::PressedOutsideNotifier(QQuickItem *parent)
    : QQuickItem(parent)
{
    connect(this, &QQuickItem::enabledChanged,
            this, &PressedOutsideNotifier::setupOrTearDownEventFiltering);

    m_signalEmissionTimer.setSingleShot(true);
    m_signalEmissionTimer.setInterval(0); // times out on the next iteration of the event loop
    connect(&m_signalEmissionTimer, &QTimer::timeout,
            this, &PressedOutsideNotifier::pressedOutside);
}

bool PressedOutsideNotifier::eventFilter(QObject *watched, QEvent *event)
{
    Q_UNUSED(watched);
    Q_ASSERT(watched == m_filteredWindow);

    // We are already going to emit pressedOutside() anyway, thus no need
    // for new checks.
    // This case takes place when a QTouchEvent comes in and isn't handled by any item,
    // causing QQuickWindow to synthesize a QMouseEvent out of it, which would
    // be filtered by us as well and count as a second press, which is wrong.
    if (m_signalEmissionTimer.isActive()) {
        return false;
    }

    switch (event->type()) {
    case QEvent::MouseButtonPress: {
        QMouseEvent *mouseEvent = static_cast<QMouseEvent*>(event);
        QPointF p = mapFromScene(mouseEvent->windowPos());
        if (!contains(p)) {
            m_signalEmissionTimer.start();
        }
        break;
    }
    case QEvent::TouchBegin:
        processFilteredTouchBegin(static_cast<QTouchEvent*>(event));
    default:
        break;
    }

    // let the event be handled further
    return false;
}

void PressedOutsideNotifier::itemChange(ItemChange change, const ItemChangeData &value)
{
    if (change == QQuickItem::ItemSceneChange) {
        setupOrTearDownEventFiltering();
    }

    QQuickItem::itemChange(change, value);
}

void PressedOutsideNotifier::setupOrTearDownEventFiltering()
{
    if (isEnabled() && window()) {
        setupEventFiltering();
    } else if (m_filteredWindow) {
        tearDownEventFiltering();
    }
}

void PressedOutsideNotifier::setupEventFiltering()
{
    QQuickWindow *currentWindow = window();
    Q_ASSERT(currentWindow != nullptr);

    if (currentWindow == m_filteredWindow)
        return;

    if (m_filteredWindow) {
        m_filteredWindow->removeEventFilter(this);
    }

    currentWindow->installEventFilter(this);
    m_filteredWindow = currentWindow;
}

void PressedOutsideNotifier::tearDownEventFiltering()
{
    m_filteredWindow->removeEventFilter(this);
    m_filteredWindow.clear();
}

void PressedOutsideNotifier::processFilteredTouchBegin(QTouchEvent *event)
{
    const QList<QTouchEvent::TouchPoint> &touchPoints = event->touchPoints();
    for (int i = 0; i < touchPoints.count(); ++i) {
        const QTouchEvent::TouchPoint &touchPoint = touchPoints.at(i);
        if (touchPoint.state() == Qt::TouchPointPressed) {
            QPointF p = mapFromScene(touchPoint.pos());
            if (!contains(p)) {
                m_signalEmissionTimer.start();
                return;
            }
        }
    }
}

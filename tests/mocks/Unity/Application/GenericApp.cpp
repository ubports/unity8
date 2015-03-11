/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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

#include "GenericApp.h"
#include "Session.h"

#include <paths.h>

#include <QString>

#include <QDebug>

GenericApp::GenericApp(const QString& name,
                               GenericApp::Type type,
                               GenericApp::State state,
                               const QUrl& screenshot,
                               const QString &qmlFilePath,
                               QQuickItem *parent)
    : MirSurfaceItem(name, type, state, screenshot, qmlFilePath, parent)
    , m_touchPressCount(0)
    , m_touchReleaseCount(0)
{
}

GenericApp::~GenericApp()
{
}

void GenericApp::touchEvent(QTouchEvent * event)
{
    if (event->touchPointStates() & Qt::TouchPointPressed) {
        ++m_touchPressCount;
        Q_EMIT touchPressCountChanged(m_touchPressCount);
    } else if (event->touchPointStates() & Qt::TouchPointReleased) {
        ++m_touchReleaseCount;
        Q_EMIT touchReleaseCountChanged(m_touchReleaseCount);
    }
}

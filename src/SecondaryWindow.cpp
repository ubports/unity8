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

#include "SecondaryWindow.h"

// local
#include <paths.h>

#include <QQmlContext>

SecondaryWindow::SecondaryWindow(QQmlEngine *engine)
    : QQuickView(engine, nullptr)
{
    QByteArray pxpguEnv = qgetenv("GRID_UNIT_PX");
    bool ok;
    int pxpgu = pxpguEnv.toInt(&ok);
    if (!ok) {
        pxpgu = 8;
    }
    engine->rootContext()->setContextProperty(QStringLiteral("internalGu"), pxpgu);
    setResizeMode(QQuickView::SizeRootObjectToView);
    setColor("black");
    setTitle(QStringLiteral("Unity8 Shell - Secondary Screen"));

    QUrl source(::qmlDirectory() + "/DisabledScreenNotice.qml");
    setSource(source);
}

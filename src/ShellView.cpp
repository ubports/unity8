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

#include "ShellView.h"

// Qt
#include <QQmlContext>

// local
#include <paths.h>

ShellView::ShellView(QQmlEngine *engine, QObject *qmlArgs)
    : QQuickView(engine, nullptr)
{
    setResizeMode(QQuickView::SizeRootObjectToView);
    setColor("black");
    setTitle(QStringLiteral("Unity8"));

    rootContext()->setContextProperty(QStringLiteral("applicationArguments"), qmlArgs);

    QUrl source(::qmlDirectory() + "/OrientedShell.qml");
    setSource(source);
}

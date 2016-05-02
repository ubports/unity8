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
#include <QQuickItem>

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

    connect(this, &QWindow::widthChanged, this, &ShellView::onWidthChanged);
    connect(this, &QWindow::heightChanged, this, &ShellView::onHeightChanged);
}

void ShellView::onWidthChanged(int w)
{
    // For good measure in case SizeRootObjectToView doesn't fulfill its promise.
    //
    // There's at least one situation that's know to leave the root object with an outdated size.
    // (really looks like Qt bug)
    // Happens when starting unity8 with an external monitor already connected.
    // The QResizeEvent we get still has the size of the first screen and since the resize move is triggered
    // from the resize event handler, the root item doesn't get resized.
    // TODO: Confirm the Qt bug and submit a patch upstream
    if (rootObject()) {
        rootObject()->setWidth(w);
    }
}

void ShellView::onHeightChanged(int h)
{
    // See comment in ShellView::onWidthChanged()
    if (rootObject()) {
        rootObject()->setHeight(h);
    }
}

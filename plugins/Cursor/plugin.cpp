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

// Qt
#include <QtQml/qqml.h>
#include <QQmlContext>

// self
#include "plugin.h"

// local
#include "CursorImageInfo.h"
#include "CursorImageProvider.h"
#include "MousePointer.h"

void CursorPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Cursor"));
    qmlRegisterType<CursorImageInfo>(uri, 1, 1, "CursorImageInfo");
    qmlRegisterType<MousePointer>(uri, 1, 1, "MousePointer");
}

void CursorPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);

    engine->addImageProvider(QStringLiteral("cursor"), new CursorImageProvider());
}

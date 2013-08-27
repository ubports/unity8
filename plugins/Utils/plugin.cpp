/*
 * Copyright (C) 2012 Canonical, Ltd.
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
 *
 * Author: Michał Sawicz <michal.sawicz@canonical.com>
 */

// Qt
#include <QtQml/qqml.h>
#include <QtQuick/QQuickWindow>

// self
#include "plugin.h"

// local
#include "applicationpaths.h"
#include "qlimitproxymodelqml.h"
#include "qsortfilterproxymodelqml.h"
#include "ubuntuwindow.h"

static QObject* applicationsPathsSingleton(QQmlEngine* engine, QJSEngine* scriptEngine) {
  Q_UNUSED(engine);
  Q_UNUSED(scriptEngine);
  return new ApplicationPaths;
}

void UtilsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Utils"));
    qmlRegisterType<QAbstractItemModel>();
    qmlRegisterType<QLimitProxyModelQML>(uri, 0, 1, "LimitProxyModel");
    qmlRegisterType<QSortFilterProxyModelQML>(uri, 0, 1, "SortFilterProxyModel");
    qmlRegisterExtendedType<QQuickWindow, UbuntuWindow>(uri, 0, 1, "Window");
    qmlRegisterSingletonType<ApplicationPaths>(uri, 0, 1, "ApplicationPaths", applicationsPathsSingleton);
}

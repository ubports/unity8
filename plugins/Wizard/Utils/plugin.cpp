/*
 * Copyright (C) 2014 Canonical, Ltd.
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
#include <QDebug>
// self
#include "plugin.h"

// local
#include "qsortfilterproxymodelqml.h"
#include "system.h"

static QObject *system_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return new System();
}

void UtilsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Ubuntu.SystemSettings.Wizard.Utils"));
    qmlRegisterType<QAbstractItemModel>();
    qmlRegisterType<QSortFilterProxyModelQML>(uri, 0, 1, "SortFilterProxyModel");
    qmlRegisterSingletonType<System>(uri, 0, 1, "System", system_provider);
}

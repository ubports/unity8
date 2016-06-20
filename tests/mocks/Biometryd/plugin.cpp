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

#include "plugin.h"
#include "MockBiometryd.h"
#include "MockDevice.h"
#include "MockIdentifier.h"
#include "MockObserver.h"
#include "MockOperation.h"

#include <QtQml>

static QObject *biometryd_provider(QQmlEngine *, QJSEngine *)
{
    return new MockBiometryd();
}

void BackendPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Biometryd"));

    qmlRegisterType<MockObserver>(uri, 0, 0, "Observer");
    qmlRegisterSingletonType<MockBiometryd>(uri, 0, 0, "Biometryd", biometryd_provider);

    qRegisterMetaType<MockDevice*>();
    qRegisterMetaType<MockIdentifier*>();
    qRegisterMetaType<MockOperation*>();
}

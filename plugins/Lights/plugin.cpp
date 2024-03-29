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
 *
 * Author: Renato Araujo Oliveira Filho <renato.filho@canonical.com>
 */

#include "plugin.h"
#include "Lights.h"
#include "HfdLights.h"
#include "LegacyLights.h"

// libandroid-properties
#include <hybris/properties/properties.h>

#include <QtQml/qqml.h>

static QObject *lights_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    bool use_hfd = false;
    char buffer[PROP_VALUE_MAX];
    auto result = property_get("ro.build.version.sdk", buffer, "0");
    if (result) {
        auto sdkVersion = QString(buffer).toInt();
        if (sdkVersion >= 27 || sdkVersion == 0) {
            use_hfd = true;
        }
    }
    if (use_hfd) {
        return new HfdLights();
    } else {
        return new LegacyLights();
    }
}

void LightsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Lights"));
    qmlRegisterSingletonType<Lights>(uri, 0, 1, "Lights", lights_provider);
}

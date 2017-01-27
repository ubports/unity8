/*
 * Copyright (C) 2017 Canonical, Ltd.
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

#include "MockController.h"

#include <QtQml/qqml.h>

static QObject *mock_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(scriptEngine)
    auto controller = QLightDM::MockController::instance();
    engine->setObjectOwnership(controller, QQmlEngine::CppOwnership);
    return controller;
}

void LightDMControllerPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("LightDMController"));
    qmlRegisterSingletonType<QLightDM::MockController>(uri, 0, 1, "LightDMController", mock_provider);
}

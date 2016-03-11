/*
 * Copyright (C) 2013,2015 Canonical, Ltd.
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
#include "AxisVelocityCalculator.h"
#include "Direction.h"
#include "DirectionalDragArea.h"
#include "FloatingFlickable.h"
#include "PressedOutsideNotifier.h"
#include "TouchGate.h"
#include "TouchGestureArea.h"

#include <qqml.h>

static QObject* directionSingleton(QQmlEngine* engine, QJSEngine* scriptEngine) {
  Q_UNUSED(engine);
  Q_UNUSED(scriptEngine);
  return new Direction;
}

void UbuntuGesturesQmlPlugin::registerTypes(const char *uri)
{
    qmlRegisterSingletonType<Direction>(uri, 0, 1, "Direction", directionSingleton);
    qmlRegisterType<DirectionalDragArea>(uri, 0, 1, "DirectionalDragArea");
    qmlRegisterType<AxisVelocityCalculator>(uri, 0, 1, "AxisVelocityCalculator");
    qmlRegisterType<FloatingFlickable>(uri, 0, 1, "FloatingFlickable");
    qmlRegisterType<PressedOutsideNotifier>(uri, 0, 1, "PressedOutsideNotifier");
    qmlRegisterType<TouchGate>(uri, 0, 1, "TouchGate");
    qmlRegisterType<TouchGestureArea>(uri, 0, 1, "TouchGestureArea");
    qmlRegisterUncreatableType<GestureTouchPoint>(uri, 0, 1, "GestureTouchPoint", "Cannot create GestureTouchPoints");
}

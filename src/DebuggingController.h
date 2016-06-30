/*
 * Copyright (C) 2016 - Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License, as
 * published by the  Free Software Foundation; either version 2.1 or 3.0
 * of the License.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the applicable version of the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of both the GNU Lesser General Public
 * License along with this program. If not, see <http://www.gnu.org/licenses/>
 */


#ifndef DEBUGGINGCONTROLLER_H
#define DEBUGGINGCONTROLLER_H

#include <QQmlEngine>
#include <QQmlExtensionPlugin>

#include "unitydbusobject.h"

class DebuggingController: public UnityDBusObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.canonical.Unity8.Debugging")

public:
    DebuggingController(QObject *parent = nullptr);
    ~DebuggingController() = default;

public Q_SLOTS:
    /**
      * Set the QSG_VISUALIZE mode. This follows the vlues supported by Qt in
      * http://doc.qt.io/qt-5/qtquick-visualcanvas-scenegraph-renderer.html
      */
    Q_SCRIPTABLE void SetSceneGraphVisualizer(const QString &visualizer);

    /**
      * Slow down animations for better inspection.
      */
    Q_SCRIPTABLE void SetSlowAnimations(bool slowAnimations);

    /**
      * Set the QLoggingCategory filter rules.
      */
    Q_SCRIPTABLE void SetLoggingFilterRules(const QString &filterRules);
};
#endif // DEBUGGINGCONTROLLER_H

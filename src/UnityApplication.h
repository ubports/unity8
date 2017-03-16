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

#ifndef UNITYAPPLICATION_H
#define UNITYAPPLICATION_H

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QScopedPointer>

#include "ApplicationArguments.h"

#ifdef UNITY8_ENABLE_TOUCH_EMULATION
#include "MouseTouchAdaptor.h"
#endif

#include <qtmir/mirserverapplication.h>

class UnityApplication : public qtmir::MirServerApplication
{
    Q_OBJECT
public:
    UnityApplication(int & argc, char ** argv);
    virtual ~UnityApplication();

    void destroyResources();

private:
    void setupQmlEngine();
    ApplicationArguments m_qmlArgs;

    #ifdef UNITY8_ENABLE_TOUCH_EMULATION
    MouseTouchAdaptor *m_mouseTouchAdaptor{nullptr};
    #endif

    QQmlEngine *m_qmlEngine{nullptr};
};

#endif // UNITYAPPLICATION_H

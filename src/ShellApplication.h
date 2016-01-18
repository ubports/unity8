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

#ifndef SHELLAPPLICATION_H
#define SHELLAPPLICATION_H

#include <QGuiApplication>
#include <QQmlEngine>
#include <QQuickView>
#include <QScopedPointer>

#include "ApplicationArguments.h"

#ifdef UNITY8_ENABLE_TOUCH_EMULATION
#include "MouseTouchAdaptor.h"
#endif

#include "SecondaryWindow.h"
#include "ShellView.h"

class ShellApplication : public QGuiApplication
{
    Q_OBJECT
public:
    ShellApplication(int & argc, char ** argv, bool isMirServer);
    virtual ~ShellApplication();

    void destroyResources();
public Q_SLOTS:
    // called by qtmir
    void onScreenAboutToBeRemoved(QScreen *screen);

private Q_SLOTS:
    void onScreenAdded(QScreen*);

private:
    void setupQmlEngine(bool isMirServer);
    QString m_deviceName;
    ApplicationArguments m_qmlArgs;
    ShellView *m_shellView{nullptr};
    SecondaryWindow *m_secondaryWindow{nullptr};

    #ifdef UNITY8_ENABLE_TOUCH_EMULATION
    MouseTouchAdaptor *m_mouseTouchAdaptor{nullptr};
    #endif

    QQmlEngine *m_qmlEngine{nullptr};
};

#endif // SHELLAPPLICATION_H

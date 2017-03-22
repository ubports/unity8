/*
 * Copyright (C) 2017 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef SCREENATTACHED_H
#define SCREENATTACHED_H

#include "Screen.h"

#include <QQmlEngine>
#include <QtQml>

class QQuickWindow;

class ScreenAttached : public Screen
{
    Q_OBJECT
public:
    ScreenAttached(QObject* owner);

    WorkspaceModel* workspaces() const override;
    Workspace *currentWorkspace() const override;
    void setCurrentWorkspace(Workspace* workspace) override;

private Q_SLOTS:
    void windowChanged(QQuickWindow*);
    void screenChanged(QScreen*);
    void screenChanged2(Screen* screen);

private:
    QPointer<Screen> m_screen;
    QQuickWindow* m_window;
};

class WMScreen : public QObject
{
    Q_OBJECT
public:
    static ScreenAttached *qmlAttachedProperties(QObject *owner);
};

QML_DECLARE_TYPEINFO(WMScreen, QML_HAS_ATTACHED_PROPERTIES)

#endif // SCREENATTACHED_H

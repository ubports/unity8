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

#ifndef UNITY_SHELL_VIEW_H
#define UNITY_SHELL_VIEW_H

#include <QQuickView>

class ShellView : public QQuickView
{
    Q_OBJECT

public:
    ShellView(QQmlEngine *engine, QObject *qmlArgs);

private Q_SLOTS:
    void onWidthChanged(int);
    void onHeightChanged(int);
};

#endif // UNITY_SHELL_VIEW_H

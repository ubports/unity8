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

#ifndef ACTIVE_FOCUS_LOGGER_H
#define ACTIVE_FOCUS_LOGGER_H

#include <QObject>
#include <QQuickWindow>
#include <QPointer>

class ActiveFocusLogger : public QObject {
    Q_OBJECT

public:
    void setWindow(QQuickWindow *window);

private Q_SLOTS:
    void printActiveFocusInfo();

private:
    QPointer<QQuickWindow> m_window;
};

#endif // ACTIVE_FOCUS_LOGGER_H

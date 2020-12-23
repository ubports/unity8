/*
 * Copyright (C) 2021 UBports Foundation.
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
 * Authors: Alberto Mardegan <mardy@users.sourceforge.net>
 */

#ifndef LOMIRI_PROCESSCONTROL_H
#define LOMIRI_PROCESSCONTROL_H

#include <QObject>
#include <QScopedPointer>
#include <QStringList>

class ProcessControlPrivate;
class ProcessControl: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList awakenProcesses READ awakenProcesses
               NOTIFY awakenProcessesChanged)

public:
    explicit ProcessControl(QObject *parent = 0);
    ~ProcessControl();

    void setAwakenProcesses(const QStringList &processes);
    QStringList awakenProcesses() const;

Q_SIGNALS:
    void awakenProcessesChanged();

private:
    Q_DECLARE_PRIVATE(ProcessControl)
    QScopedPointer<ProcessControlPrivate> d_ptr;
};

#endif // LOMIRI_PROCESSCONTROL_H

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

#include "ProcessControl.h"

#include <QDebug>

class ProcessControlPrivate
{
public:
    ProcessControlPrivate(ProcessControl *q);

private:
    friend class ProcessControl;
    QStringList m_awakenProcesses;
};

ProcessControlPrivate::ProcessControlPrivate(ProcessControl *q)
{
}

ProcessControl::ProcessControl(QObject* parent):
    QObject(parent),
    d_ptr(new ProcessControlPrivate(this))
{
}

ProcessControl::~ProcessControl() = default;

void ProcessControl::setAwakenProcesses(const QStringList &processes)
{
    Q_D(ProcessControl);
    d->m_awakenProcesses = processes;
    Q_EMIT awakenProcessesChanged();
}

QStringList ProcessControl::awakenProcesses() const
{
    Q_D(const ProcessControl);
    return d->m_awakenProcesses;
}

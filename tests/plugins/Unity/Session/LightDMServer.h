/*
 * Copyright 2016 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the  Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * version 3 along with this program.  If not, see
 * <http://www.gnu.org/licenses/>
 */

#ifndef UNITY_LIGHTDMSERVER_H
#define UNITY_LIGHTDMSERVER_H

#include <QDBusContext>
#include <QObject>

class LightDMServer: public QObject, protected QDBusContext
{
    Q_OBJECT

public:
    explicit LightDMServer(QObject *logind, QObject *parent = nullptr);

public Q_SLOTS:
    void Lock();

private:
    QObject *m_logind;
};

#endif

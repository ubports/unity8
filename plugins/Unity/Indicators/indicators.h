/*
 * Copyright (C) 2012 Canonical, Ltd.
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
 * Author: Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef INDICATORS_H
#define INDICATORS_H

#include "unityindicatorsglobal.h"

#include <QObject>

class UNITYINDICATORS_EXPORT ActionState : public QObject
{
    Q_OBJECT
public:
    enum ActionStates {
      Label           = 0x00,
      IconSource      = 0x01,
      AccessableName  = 0x02,
      Visible         = 0x03,
    };
    Q_ENUM(ActionStates)

    ActionState(QObject*parent=0):QObject(parent) {}
};

class UNITYINDICATORS_EXPORT NetworkActionState : public QObject
{
    Q_OBJECT
public:
    enum NetworkActionStates {
      Connection      = 0x01,
      SignalStrength  = 0x02,
    };
    Q_ENUM(NetworkActionStates)

    NetworkActionState(QObject*parent=0):QObject(parent) {}
};

class UNITYINDICATORS_EXPORT NetworkConnection : public QObject
{
    Q_OBJECT
public:
    enum NetworkConnectionStates {
      Initial         = 0x00,
      Activating      = 0x01,
      Activated       = 0x02,
      Deactivating    = 0x03,
    };
    Q_ENUM(NetworkConnectionStates)

    NetworkConnection(QObject*parent=0):QObject(parent) {}
};

class UNITYINDICATORS_EXPORT IndicatorsModelRole : public QObject
{
    Q_OBJECT
public:
    enum Roles {
        Identifier = 0,
        Position,
        IndicatorProperties
    };
    Q_ENUM(Roles)

    IndicatorsModelRole(QObject*parent=0):QObject(parent) {}
};

class UNITYINDICATORS_EXPORT FlatMenuProxyModelRole : public QObject
{
    Q_OBJECT
public:
    enum Roles {
        Action  = Qt::DisplayRole + 1,
        Label,
        Extra,
        Depth,
        hasSection,
        hasSubMenu
    };
    Q_ENUM(Roles)

    FlatMenuProxyModelRole(QObject*parent=0):QObject(parent) {}
};

#endif // INDICATORS_H

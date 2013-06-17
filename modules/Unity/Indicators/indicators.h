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

class ActionState : public QObject
{
    Q_OBJECT
public:
    Q_ENUMS(ActionStates)
    enum ActionStates {
      Label           = 0x00,
      IconSource      = 0x01,
      AccessableName  = 0x02,
      Visible         = 0x03,
    };

    ActionState(QObject*parent=0):QObject(parent) {}
};

#endif // INDICATORS_H

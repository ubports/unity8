/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#ifndef SESSIONMODEL_H
#define SESSIONMODEL_H

// Local
#include "MirObjectModel.h"

class Session;
class SessionModel: public MirObjectModel<Session>
{
    Q_OBJECT
public:
    SessionModel(QObject *parent = 0): MirObjectModel(parent) {}

    Q_INVOKABLE int count() const { return rowCount(); }
};

Q_DECLARE_METATYPE(SessionModel*)

#endif // SESSIONMODEL_H

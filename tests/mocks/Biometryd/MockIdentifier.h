/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#ifndef MOCK_IDENTIFIER_H
#define MOCK_IDENTIFIER_H

#include <QObject>

#include "MockOperation.h"

class MockIdentifier : public QObject
{
    Q_OBJECT

public:
    explicit MockIdentifier(QObject *parent = 0);

    Q_INVOKABLE MockOperation *identifyUser();
};

Q_DECLARE_METATYPE(MockIdentifier*)

#endif // MOCK_IDENTIFIER_H

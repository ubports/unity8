/*
 * Copyright (C) 2013 Canonical, Ltd.
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
 * Authors: Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef MOCK_ACTIONSTATEPARSER_H
#define MOCK_ACTIONSTATEPARSER_H

#include <QObject>
#include <QVariant>

typedef struct _GVariant GVariant;

class Q_DECL_EXPORT ActionStateParser : public QObject
{
    Q_OBJECT
public:
    ActionStateParser(QObject* parent = 0):QObject(parent) {}
    virtual QVariant toQVariant(GVariant*) const { return QVariant(); }
};

#endif // MOCK_ACTIONSTATEPARSER_H

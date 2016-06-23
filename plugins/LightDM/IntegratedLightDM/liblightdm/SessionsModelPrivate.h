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
 *
 */

#ifndef UNITY_INTEGRATED_SESSIONSMODEL_PRIVATE_H
#define UNITY_INTEGRATED_SESSIONSMODEL_PRIVATE_H

#include <QtCore/QList>
#include <QtCore/QString>

namespace QLightDM
{
class SessionsModel;

class SessionItem
{
public:
    QString key;
    QString type; // unused
    QString name;
    QString comment; // unused
};

class SessionsModelPrivate
{
public:
    explicit SessionsModelPrivate(SessionsModel* parent=0);
    virtual ~SessionsModelPrivate() = default;

    QList<SessionItem> sessionItems;

protected:
    SessionsModel* const q_ptr;

private:
    Q_DECLARE_PUBLIC(SessionsModel)
};

} // namespace QLightDM

#endif // UNITY_INTEGRATED_SESSIONSMODEL_PRIVATE_H

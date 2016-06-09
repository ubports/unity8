/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#ifndef UNITY_MOCK_GREETER_PRIVATE_H
#define UNITY_MOCK_GREETER_PRIVATE_H

#include <QtCore/QObject>

namespace QLightDM
{
class Greeter;
class GreeterImpl;

class GreeterPrivate
{
public:
    explicit GreeterPrivate(Greeter* parent=0);
    virtual ~GreeterPrivate() = default;

    // These variables may not be used by all subclasses, that's no problem
    bool authenticated;
    QString authenticationUser;
    bool twoFactorDone;
    QString selectUserHint;

    QString mockMode;

    void handleAuthenticate();
    void handleRespond(const QString &response);

protected:
    Greeter * const q_ptr;

private:
    void handleAuthenticate_full();
    void handleRespond_full(const QString &response);
    Q_DECLARE_PUBLIC(Greeter)
};
}

#endif // UNITY_MOCK_GREETER_PRIVATE_H

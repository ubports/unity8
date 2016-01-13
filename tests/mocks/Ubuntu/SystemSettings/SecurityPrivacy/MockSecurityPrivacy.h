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

#ifndef MOCK_SECURITYPRIVACY_H
#define MOCK_SECURITYPRIVACY_H

#include <QObject>

class MockSecurityPrivacy : public QObject
{
    Q_OBJECT
    Q_ENUMS(SecurityType)
    Q_PROPERTY (SecurityType securityType
                READ getSecurityType
                NOTIFY securityTypeChanged)

public:
    enum SecurityType {
         Swipe,
         Passcode,
         Passphrase,
    };

    MockSecurityPrivacy(QObject *parent = 0);

    SecurityType getSecurityType();
    Q_INVOKABLE QString setSecurity(const QString &oldPasswd, const QString &newPasswd, SecurityType newType);

Q_SIGNALS:
    void securityTypeChanged();
    void setSecurityCalled(const QString &oldPasswd, const QString &newPasswd, SecurityType newType); // only in mock

private:
    SecurityType m_type;
};

#endif // MOCK_SECURITYPRIVACY_H

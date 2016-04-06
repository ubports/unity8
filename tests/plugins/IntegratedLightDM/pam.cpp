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
 */

#include "GreeterPrivate.h"

#include <QtTest>

#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>

class GreeterPamTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void init()
    {
        m_greeterpriv = new QLightDM::GreeterPrivate();
    }

    void cleanup()
    {
        delete m_greeterpriv;
        QTRY_COMPARE(QThreadPool::globalInstance()->activeThreadCount(), 0);
    }

    void testRapidFireAuthentication()
    {
        auto pw = getpwuid(getuid());
        m_greeterpriv->authenticationUser = pw->pw_name;
        for (int i = 0; i < 100; i++) {
            m_greeterpriv->handleAuthenticate();
        }
    }

private:
    QLightDM::GreeterPrivate *m_greeterpriv;
};

QTEST_GUILESS_MAIN(GreeterPamTest)

#include "pam.moc"

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

#include "UsersModel.h"

#include <glib.h>
#include <QDBusInterface>
#include <QDBusReply>
#include <QtTest>

class GreeterIntegratedTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void init()
    {
        m_accounts = new QDBusInterface(QStringLiteral("org.freedesktop.Accounts"),
                                        QStringLiteral("/org/freedesktop/Accounts"),
                                        QStringLiteral("org.freedesktop.Accounts"),
                                        QDBusConnection::sessionBus());
        QDBusReply<bool> addReply = m_accounts->call(QStringLiteral("AddUser"),
                                                     g_get_user_name());
        QVERIFY(addReply.isValid());
        QCOMPARE(addReply.value(), true);

        m_user = new QDBusInterface(QStringLiteral("org.freedesktop.Accounts"),
                                    QStringLiteral("/%1").arg(g_get_user_name()),
                                    QStringLiteral("org.freedesktop.DBus.Properties"),
                                    QDBusConnection::sessionBus());

        m_model = new QLightDM::UsersModel();
        QVERIFY(m_model);
    }

    void cleanup()
    {
        QDBusReply<bool> addReply = m_accounts->call(QStringLiteral("RemoveUser"),
                                                     g_get_user_name());
        QVERIFY(addReply.isValid());
        QCOMPARE(addReply.value(), true);

        delete m_model;
        delete m_accounts;
        delete m_user;
    }

    void testWatchRealName()
    {
        auto index = m_model->index(0, 0);

        QCOMPARE(m_model->data(index, QLightDM::UsersModel::RealNameRole).toString(),
                 QStringLiteral(""));

        // The real AccountsService doesn't let you set via dbus properties. You
        // have to call SetRealName instead (so that they can protect the call
        // via policykit). But our test server does let us.
        QVariant wrapped = QVariant::fromValue(QDBusVariant(QStringLiteral("Test User")));
        QDBusReply<void> reply = m_user->call(QStringLiteral("Set"),
                                              QStringLiteral("org.freedesktop.Accounts.User"),
                                              QStringLiteral("RealName"),
                                              wrapped);
        QVERIFY(reply.isValid());

        QTRY_COMPARE(m_model->data(index, QLightDM::UsersModel::RealNameRole).toString(),
                     QStringLiteral("Test User"));
    }

private:
    QLightDM::UsersModel *m_model;
    QDBusInterface *m_accounts;
    QDBusInterface *m_user;
};

QTEST_MAIN(GreeterIntegratedTest)

#include "integrated.moc"

/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the  Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * version 3 along with this program.  If not, see
 * <http://www.gnu.org/licenses/>
 *
 * Authored by: Michael Terry <michael.terry@canonical.com>
 */

#include "AccountsService.h"
#include "AccountsServiceDBusAdaptor.h"
#include <QSignalSpy>
#include <QTest>
#include <QDebug>
#include <QDBusReply>

template <class T>
QVariant dbusVariant(const T& value) { return QVariant::fromValue(QDBusVariant(value)); }

#define  ASSERT_DBUS_CALL(call) \
    { \
        QDBusReply<void> reply = call; \
        if (!reply.isValid()) QFAIL(reply.error().message().toLatin1()); \
    }

class AccountsServiceTest : public QObject
{
    Q_OBJECT

public:
    AccountsServiceTest(QObject* parent = 0)
        : QObject(parent)
        , m_userInterface(nullptr)
        , m_spy(this, &AccountsServiceTest::propertiesChanged)
    {
    }

private Q_SLOTS:

    void init() {
        QDBusReply<bool> addReply = QDBusInterface("org.freedesktop.Accounts",
                                                   "/org/freedesktop/Accounts",
                                                   "org.freedesktop.Accounts").call("AddUser", QTest::currentTestFunction());
        QVERIFY(addReply.isValid());
        QCOMPARE(addReply.value(), true);

        m_userInterface = new QDBusInterface("org.freedesktop.Accounts",
                                             QString("/%1").arg(QTest::currentTestFunction()),
                                             "org.freedesktop.DBus.Properties", QDBusConnection::sessionBus(), this);

        QVERIFY(QObject::connect(m_userInterface, SIGNAL(PropertiesChanged(QString, QVariantMap, QStringList)),
                                 this, SIGNAL(propertiesChanged(QString, QVariantMap, QStringList))));
    }

    void cleanup() {
        QDBusReply<bool> reply = QDBusInterface("org.freedesktop.Accounts",
                                                "/org/freedesktop/Accounts",
                                                "org.freedesktop.Accounts").call("RemoveUser", QTest::currentTestFunction());
        QVERIFY(reply.isValid());
        QCOMPARE(reply.value(), true);

        delete m_userInterface;
        m_spy.clear();
    }

    void testInvalids()
    {
        // Test various invalid calls
        AccountsServiceDBusAdaptor session;
        QCOMPARE(session.getUserPropertyAsync("NOPE", "com.canonical.unity.AccountsService", "demo-edges").value(), QVariant());
        QCOMPARE(session.getUserPropertyAsync(QTest::currentTestFunction(), "com.canonical.unity.AccountsService", "NOPE").value(), QVariant());
    }

    void testGetSetServiceDBusAdaptor()
    {
        AccountsServiceDBusAdaptor session;
        session.setUserPropertyAsync(QTest::currentTestFunction(), "com.canonical.unity.AccountsService", "demo-edges", QVariant(true)).waitForFinished();
        QCOMPARE(session.getUserPropertyAsync(QTest::currentTestFunction(), "com.canonical.unity.AccountsService", "demo-edges").value(), QVariant(true));
        session.setUserPropertyAsync(QTest::currentTestFunction(), "com.canonical.unity.AccountsService", "demo-edges", QVariant(false)).waitForFinished();
        QCOMPARE(session.getUserPropertyAsync(QTest::currentTestFunction(), "com.canonical.unity.AccountsService", "demo-edges").value(), QVariant(false));
    }

    void testGetSetService()
    {
        AccountsService session(this, QTest::currentTestFunction());

        QCOMPARE(session.demoEdges(), false);
        session.setDemoEdges(true);
        QCOMPARE(session.demoEdges(), true);

        QCOMPARE(session.failedLogins(), (uint)0);
        session.setFailedLogins(5);
        QCOMPARE(session.failedLogins(), (uint)5);

        QCOMPARE(session.hereEnabled(), false);
        session.setHereEnabled(true);
        QCOMPARE(session.hereEnabled(), true);
    }

    void testAsynchronousChangeForDemoEdges()
    {
        AccountsService session(this, QTest::currentTestFunction());

        QCOMPARE(session.demoEdges(), false);
        ASSERT_DBUS_CALL(m_userInterface->call("Set",
                                               "com.canonical.unity.AccountsService",
                                               "demo-edges",
                                               dbusVariant(true)));
        QTRY_COMPARE(session.demoEdges(), true);
    }

    void testAsynchronousChangeForFailedLogins()
    {
        AccountsService session(this, QTest::currentTestFunction());

        QCOMPARE(session.failedLogins(), (uint)0);
        ASSERT_DBUS_CALL(m_userInterface->asyncCall("Set",
                                                    "com.canonical.unity.AccountsService.Private",
                                                    "FailedLogins",
                                                    dbusVariant(5)));
        QTRY_COMPARE(session.failedLogins(), (uint)5);
    }

    void testAsynchronousChangeForStatsWelcomeScreen()
    {
        AccountsService session(this, QTest::currentTestFunction());

        QCOMPARE(session.statsWelcomeScreen(), true);
        ASSERT_DBUS_CALL(m_userInterface->asyncCall("Set",
                                                    "com.ubuntu.touch.AccountsService.SecurityPrivacy",
                                                    "StatsWelcomeScreen",
                                                    dbusVariant(false)));
        QTRY_COMPARE(session.statsWelcomeScreen(), false);
    }

    void testAsynchronousChangeForEnableLauncherWhileLocked()
    {
        AccountsService session(this, QTest::currentTestFunction());

        QCOMPARE(session.enableLauncherWhileLocked(), true);
        ASSERT_DBUS_CALL(m_userInterface->asyncCall("Set",
                                                    "com.ubuntu.AccountsService.SecurityPrivacy",
                                                    "EnableLauncherWhileLocked",
                                                    dbusVariant(false)));
        QTRY_COMPARE(session.enableLauncherWhileLocked(), false);
    }

    void testAsynchronousChangeForEnableIndicatorsWhileLocked()
    {
        AccountsService session(this, QTest::currentTestFunction());

        QCOMPARE(session.enableIndicatorsWhileLocked(), true);
        ASSERT_DBUS_CALL(m_userInterface->asyncCall("Set",
                                                    "com.ubuntu.AccountsService.SecurityPrivacy",
                                                    "EnableIndicatorsWhileLocked",
                                                    dbusVariant(false)));
        QTRY_COMPARE(session.enableIndicatorsWhileLocked(), false);
    }

    void testAsynchronousChangeForPasswordDisplayHint()
    {
        AccountsService session(this, QTest::currentTestFunction());

        QCOMPARE(session.passwordDisplayHint(), AccountsService::Keyboard);
        ASSERT_DBUS_CALL(m_userInterface->asyncCall("Set",
                                                    "com.ubuntu.AccountsService.SecurityPrivacy",
                                                    "PasswordDisplayHint",
                                                    dbusVariant(AccountsService::Numeric)));
        QTRY_COMPARE(session.passwordDisplayHint(), AccountsService::Numeric);
    }

    void testAsynchronousChangeForLicenseAccepted()
    {
        AccountsService session(this, QTest::currentTestFunction());

        QCOMPARE(session.hereEnabled(), false);
        ASSERT_DBUS_CALL(m_userInterface->asyncCall("Set",
                                                    "com.ubuntu.location.providers.here.AccountsService",
                                                    "LicenseAccepted",
                                                    dbusVariant(true)));
        QTRY_COMPARE(session.hereEnabled(), true);
    }

    void testAsynchronousChangeForLicenseBasePath()
    {
        AccountsService session(this, QTest::currentTestFunction());

        QCOMPARE(session.hereLicensePath(), QString());
        ASSERT_DBUS_CALL(m_userInterface->asyncCall("Set",
                                                    "com.ubuntu.location.providers.here.AccountsService",
                                                    "LicenseBasePath",
                                                    dbusVariant("/")));
        QTRY_COMPARE(session.hereLicensePath(), QString("/"));
    }

    void testAsynchronousChangeForBackgroundFile()
    {
        AccountsService session(this, QTest::currentTestFunction());

        QCOMPARE(session.backgroundFile(), QString());
        ASSERT_DBUS_CALL(m_userInterface->asyncCall("Set",
                                                   "org.freedesktop.Accounts.User",
                                                    "BackgroundFile",
                                                    dbusVariant("/test/BackgroundFile")));
        QTRY_COMPARE(session.backgroundFile(), QString("/test/BackgroundFile"));
    }

Q_SIGNALS:
    void propertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalid);

private:
    QDBusInterface* m_userInterface;
    QSignalSpy m_spy;
};

QTEST_MAIN(AccountsServiceTest)

#include "client.moc"

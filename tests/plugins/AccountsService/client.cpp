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
#include <QDBusMetaType>

using StringMap = QMap<QString,QString>;
using StringMapList = QList<StringMap>;
Q_DECLARE_METATYPE(StringMapList)

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
        , m_mousePrimaryButtonSpy(this, &AccountsServiceTest::setMousePrimaryButtonCalled)
    {
        m_uscInputInterface = new QDBusInterface("com.canonical.Unity.Input",
                                                 "/com/canonical/Unity/Input",
                                                 "com.canonical.Unity.Input",
                                                 QDBusConnection::sessionBus(),
                                                 this);

        QObject::connect(m_uscInputInterface, SIGNAL(setMousePrimaryButtonCalled(int)),
                         this, SIGNAL(setMousePrimaryButtonCalled(int)));

        qDBusRegisterMetaType<StringMap>();
        qDBusRegisterMetaType<StringMapList>();
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
        m_mousePrimaryButtonSpy.clear();
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

    void testMarkDemoEdgeCompleted()
    {
        AccountsService session(this, QTest::currentTestFunction());
        QSignalSpy changedSpy(&session, &AccountsService::demoEdgesCompletedChanged);

        QCOMPARE(changedSpy.count(), 0);
        QCOMPARE(session.demoEdgesCompleted(), QStringList());

        session.markDemoEdgeCompleted("testedge");
        QCOMPARE(changedSpy.count(), 1);
        QCOMPARE(session.demoEdgesCompleted(), QStringList() << "testedge");

        session.markDemoEdgeCompleted("testedge");
        QCOMPARE(changedSpy.count(), 1);
        QCOMPARE(session.demoEdgesCompleted(), QStringList() << "testedge");

        session.markDemoEdgeCompleted("testedge2");
        QCOMPARE(changedSpy.count(), 2);
        QCOMPARE(session.demoEdgesCompleted(), QStringList() << "testedge" << "testedge2");
    }

    void testAsynchronousChangeForDemoEdgesCompleted()
    {
        AccountsService session(this, QTest::currentTestFunction());
        QSignalSpy changedSpy(&session, &AccountsService::demoEdgesCompletedChanged);

        QCOMPARE(changedSpy.count(), 0);
        QCOMPARE(session.demoEdgesCompleted(), QStringList());

        ASSERT_DBUS_CALL(m_userInterface->call("Set",
                                               "com.canonical.unity.AccountsService",
                                               "DemoEdgesCompleted",
                                               dbusVariant(QStringList() << "testedge")));
        QTRY_COMPARE(changedSpy.count(), 1);
        QCOMPARE(session.demoEdgesCompleted(), QStringList() << "testedge");
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

    void testProxyOnStartup()
    {
        AccountsService session(this, QTest::currentTestFunction());

        QTRY_COMPARE(m_mousePrimaryButtonSpy.count(), 1);
        QList<QVariant> arguments = m_mousePrimaryButtonSpy.takeFirst();
        QCOMPARE(arguments.at(0).toInt(), 1);
    }

    void testProxyOnChange()
    {
        AccountsService session(this, QTest::currentTestFunction());
        QTRY_COMPARE(m_mousePrimaryButtonSpy.count(), 1);
        m_mousePrimaryButtonSpy.clear();

        ASSERT_DBUS_CALL(m_userInterface->asyncCall("Set",
                                                    "com.ubuntu.AccountsService.Input",
                                                    "MousePrimaryButton",
                                                    dbusVariant("left")));

        QTRY_COMPARE(m_mousePrimaryButtonSpy.count(), 1);
        QList<QVariant> arguments = m_mousePrimaryButtonSpy.takeFirst();
        QCOMPARE(arguments.at(0).toInt(), 0);
    }

    void testInvalidPrimaryButton()
    {
        AccountsService session(this, QTest::currentTestFunction());
        QTRY_COMPARE(m_mousePrimaryButtonSpy.count(), 1);
        m_mousePrimaryButtonSpy.clear();

        ASSERT_DBUS_CALL(m_userInterface->asyncCall("Set",
                                                    "com.ubuntu.AccountsService.Input",
                                                    "MousePrimaryButton",
                                                    dbusVariant("NOPE")));

        QTRY_COMPARE(m_mousePrimaryButtonSpy.count(), 1);
        QList<QVariant> arguments = m_mousePrimaryButtonSpy.takeFirst();
        QCOMPARE(arguments.at(0).toInt(), 0);
    }

    void testAsynchronousChangeForKeymaps()
    {
        AccountsService session(this, QTest::currentTestFunction());

        QCOMPARE(session.keymaps(), {"us"});

        StringMapList inputSources;
        StringMap map1;
        map1.insert("xkb", "cz+qwerty");
        inputSources.append(map1);
        StringMap map2;
        map2.insert("xkb", "fr");
        inputSources.append(map2);

        ASSERT_DBUS_CALL(m_userInterface->asyncCall("Set",
                                                    "org.freedesktop.Accounts.User",
                                                    "InputSources",
                                                    QVariant::fromValue(QDBusVariant(QVariant::fromValue(inputSources)))));
        QStringList result = {"cz+qwerty", "fr"};
        QTRY_COMPARE(session.keymaps(), result);
    }

Q_SIGNALS:
    void propertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalid);
    void setMousePrimaryButtonCalled(int button);

private:
    QDBusInterface* m_uscInputInterface;
    QDBusInterface* m_userInterface;
    QSignalSpy m_spy;
    QSignalSpy m_mousePrimaryButtonSpy;
};

QTEST_MAIN(AccountsServiceTest)

#include "client.moc"

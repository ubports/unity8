/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Michael Terry <michael.terry@canonical.com>
 */

#include "launcherbackend.h"

#include <QtTest>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusVariant>


class LauncherBackendTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void initTestCase()
    {
        // As we want to test absolute file paths in the .desktop file, we need to modify the
        // sample file and replace the path in there with the current build dir.
        QSettings settings(QDir::currentPath() + "/click-icon.desktop", QSettings::IniFormat);
        settings.setValue("Desktop Entry/Path", QDir::currentPath());
    }

    void testFileNames()
    {
        LauncherBackend backend;

        backend.setStoredApplications(QStringList() << "rel-icon" << "abs-icon" << "invalid");
        QCOMPARE(backend.storedApplications(), QStringList() << "rel-icon" << "abs-icon");
    }

    void testIcon_data() {
        QTest::addColumn<QString>("appId");
        QTest::addColumn<QString>("expectedIcon");

        // Needs to expand a relative icon to the absolute path
        QTest::newRow("relative icon path") << "rel-icon" << QDir::currentPath() + "/rel-icon.svg";

        // In case an icon is not found on disk, it needs to fallback on image://theme/ for it
        QTest::newRow("fallback on theme") << "abs-icon" << "image://theme//path/to/icon.png";

        // Click packages have a relative icon path but an absolute path as a separate entry
        QTest::newRow("click package icon") << "click-icon" << QDir::currentPath() + "/click-icon.svg";
    }

    void testIcon() {
        QFETCH(QString, appId);
        QFETCH(QString, expectedIcon);

        LauncherBackend backend;
        backend.setStoredApplications(QStringList() << appId);

        QCOMPARE(backend.icon(appId), expectedIcon);
    }

    void testGetItem_data() {
        QTest::addColumn<QString>("appId");
        QTest::addColumn<bool>("exists");

        QTest::newRow("Exists") << "rel-icon" << true;
        QTest::newRow("Doesn't Exist") << "does-not-exist" << false;
    }

    void testGetItem() {
        QFETCH(QString, appId);
        QFETCH(bool, exists);

        LauncherBackend backend;
        auto item = backend.getItem(appId);

        if (exists) {
            QVERIFY(item != nullptr);
        } else {
            QVERIFY(item == nullptr);
        }
    }

    void testCount_data() {
        QTest::addColumn<QString>("appId");
        QTest::addColumn<bool>("setCount");
        QTest::addColumn<int>("inCount");
        QTest::addColumn<bool>("countVisible");
        QTest::addColumn<int>("expectedCount");

        /* Get baseline data on things working */
        QTest::newRow("Baseline") << "rel-icon" << false << 0 << false << -1;

        /* Valid count, but not visible */
        QTest::newRow("Not visible") << "rel-icon" << true << 42 << false << -1;

        /* Turn it on */
        QTest::newRow("Visible Count") << "rel-icon" << true << 42 << true << 42;

        /* Invalide app to load */
        QTest::newRow("Invalid App ID") << "this-app-doesnt-exist" << true << 42 << true << -1;
    }

    void testCount() {
        QFETCH(QString, appId);
        QFETCH(bool, setCount);
        QFETCH(int, inCount);
        QFETCH(bool, countVisible);
        QFETCH(int, expectedCount);

        LauncherBackend backend;

        if (setCount)
            backend.setCount(appId, inCount);
        backend.setCountVisible(appId, countVisible);

        QCOMPARE(backend.count(appId), expectedCount);
    }

    void testDbusName_data() {
        QTest::addColumn<QString>("decoded");
        QTest::addColumn<QString>("encoded");

        /* Passthrough test */
        QTest::newRow("Passthrough") << "fine" << "fine";

        /* Number as first characeter */
        QTest::newRow("Number first") << "31337" << "_331337";

        /* Underscore test */
        QTest::newRow("Underscore test") << "this_is_c_style_namespacing" << "this_5Fis_5Fc_5Fstyle_5Fnamespacing";

        /* Hyphen test */
        QTest::newRow("Hyphen test") << "typical-application" << "typical_2Dapplication";

        /* Japanese test */
        QTest::newRow("日本語 test") << "日本語" << "_E6_97_A5_E6_9C_AC_E8_AA_9E";
    }

    void testDbusName() {
        QFETCH(QString, decoded);
        QFETCH(QString, encoded);

        QString encodeOut = LauncherBackend::encodeAppId(decoded);
        QCOMPARE(encoded, encodeOut);

        QString decodeOut = LauncherBackend::decodeAppId(encoded);
        QCOMPARE(decoded, decodeOut);
    }

    void testDbusIface_data() {
        QTest::addColumn<QString>("appId");
        QTest::addColumn<bool>("setCount");
        QTest::addColumn<int>("inCount");
        QTest::addColumn<bool>("countVisible");
        QTest::addColumn<int>("expectedCount");

        /* Get baseline data on things working */
        QTest::newRow("Baseline") << "rel-icon" << false << 0 << false << -1;

        /* Turn it on */
        QTest::newRow("Visible Count") << "rel-icon" << true << 42 << true << 42;

        /* Invalide app to load */
        QTest::newRow("Invalid App ID") << "this-app-doesnt-exist" << true << 42 << true << -1;
    }

    void testDbusIface() {
        QFETCH(QString, appId);
        QFETCH(bool, setCount);
        QFETCH(int, inCount);
        QFETCH(bool, countVisible);
        QFETCH(int, expectedCount);

        QDBusConnection con = QDBusConnection::sessionBus();
        QDBusMessage message;
        QDBusMessage reply;

        LauncherBackend backend;

        if (setCount) {
            message = QDBusMessage::createMethodCall("com.canonical.Unity.Launcher",
                                                     "/com/canonical/Unity/Launcher/" + LauncherBackend::encodeAppId(appId),
                                                     "org.freedesktop.DBus.Properties",
                                                     "Set");
            QVariantList cargs;
            cargs.append(QString("com.canonical.Unity.Launcher.Item"));
            cargs.append(QString("count"));
            cargs.append(QVariant::fromValue(QDBusVariant(inCount)));

            message.setArguments(cargs);
            reply = con.call(message);
            QCOMPARE(reply.type(), QDBusMessage::ReplyMessage);
        }

        /* Set countVisible */
        message = QDBusMessage::createMethodCall("com.canonical.Unity.Launcher",
                                                 "/com/canonical/Unity/Launcher/" + LauncherBackend::encodeAppId(appId),
                                                 "org.freedesktop.DBus.Properties",
                                                 "Set");
        QVariantList cvargs;
        cvargs.append(QString("com.canonical.Unity.Launcher.Item"));
        cvargs.append(QString("countVisible"));
        cvargs.append(QVariant::fromValue(QDBusVariant(countVisible)));

        message.setArguments(cvargs);
        reply = con.call(message);
        QCOMPARE(reply.type(), QDBusMessage::ReplyMessage);

        /* Get value */
        message = QDBusMessage::createMethodCall("com.canonical.Unity.Launcher",
                                                 "/com/canonical/Unity/Launcher/" + LauncherBackend::encodeAppId(appId),
                                                 "org.freedesktop.DBus.Properties",
                                                 "Get");
        QVariantList getargs;
        getargs.append(QString("com.canonical.Unity.Launcher.Item"));
        getargs.append(QString("count"));

        message.setArguments(getargs);
        reply = con.call(message);
        QCOMPARE(reply.type(), QDBusMessage::ReplyMessage);
        QCOMPARE(reply.arguments()[0].value<QDBusVariant>().variant().toInt(), expectedCount);
    }
};

QTEST_GUILESS_MAIN(LauncherBackendTest)
#include "launcherbackendtest.moc"

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
    }

    void testDbusName() {
        QFETCH(QString, decoded);
        QFETCH(QString, encoded);

        QString decodeOut = LauncherBackend::decodeAppId(encoded);
        QCOMPARE(decoded, decodeOut);

        QString encodeOut = LauncherBackend::encodeAppId(encoded);
        QCOMPARE(encoded, encodeOut);
    }
};

QTEST_GUILESS_MAIN(LauncherBackendTest)
#include "launcherbackendtest.moc"

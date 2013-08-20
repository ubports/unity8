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
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#include "launcherbackend.h"

#include <QtTest>
#include <QDebug>

class LauncherBackendTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void testFileNames()
    {
        LauncherBackend backend(false);

        auto apps = QStringList() << "one.desktop" << "two" << "/full";
        backend.setStoredApplications(apps);

        QCOMPARE(backend.desktopFile("one.desktop"), QString("/usr/share/applications/one.desktop"));
        QCOMPARE(backend.desktopFile("two"), QString("/usr/share/applications/two"));
        QCOMPARE(backend.desktopFile("/full"), QString("/full"));
        QCOMPARE(backend.storedApplications(), QStringList() << "/usr/share/applications/one.desktop" << "/usr/share/applications/two" << "/full");

        QCOMPARE(backend.desktopFile("full"), QString(""));

        QCOMPARE(backend.desktopFile("/usr/share/applications/one.desktop"), QString("/usr/share/applications/one.desktop"));
    }

    void testDesktopReading()
    {
        LauncherBackend backend(false);

        auto apps = QStringList() << SRCDIR "/rel-icon.desktop" << SRCDIR "/abs-icon.desktop" << SRCDIR "/no-icon.desktop" << SRCDIR "/no-name.desktop" << SRCDIR "/no-exist.desktop";
        backend.setStoredApplications(apps);

        QCOMPARE(backend.displayName(SRCDIR "/rel-icon.desktop"), QString("Relative Icon"));
        QCOMPARE(backend.icon(SRCDIR "/rel-icon.desktop"), QString("image://gicon/rel-icon"));

        QCOMPARE(backend.displayName(SRCDIR "/abs-icon.desktop"), QString("Absolute Icon"));
        QCOMPARE(backend.icon(SRCDIR "/abs-icon.desktop"), QString("/path/to/icon.png"));

        QCOMPARE(backend.displayName(SRCDIR "/no-icon.desktop"), QString("No Icon"));
        QCOMPARE(backend.icon(SRCDIR "/no-icon.desktop"), QString(""));

        QCOMPARE(backend.displayName(SRCDIR "/no-name.desktop"), QString(""));
        QCOMPARE(backend.icon(SRCDIR "/no-name.desktop"), QString("image://gicon/no-name"));

        QCOMPARE(backend.displayName(SRCDIR "/no-exist.desktop"), QString(""));
        QCOMPARE(backend.icon(SRCDIR "/no-exist.desktop"), QString(""));
    }

    void testPinning()
    {
        LauncherBackend backend(false);

        // Confirm that default entries are all pinned
        auto defaultApps = backend.storedApplications();
        QVERIFY(defaultApps.size() > 0);
        for (auto app: defaultApps) {
            QCOMPARE(backend.isPinned(app), true);
        }

        backend.setStoredApplications(QStringList() << "one" << "two");
        QCOMPARE(backend.isPinned("one"), false);
        QCOMPARE(backend.isPinned("two"), false);

        backend.setPinned("two", true);
        QCOMPARE(backend.isPinned("two"), true);

        backend.setStoredApplications(QStringList() << "one" << "two" << "three");
        QCOMPARE(backend.isPinned("two"), true);
        QCOMPARE(backend.isPinned("three"), false);

        backend.setPinned("three", true);
        backend.setStoredApplications(QStringList() << "one" << "two");
        QCOMPARE(backend.isPinned("two"), true);
        QCOMPARE(backend.isPinned("three"), false); // doesn't exist anymore!
    }
};

QTEST_GUILESS_MAIN(LauncherBackendTest)
#include "launcherbackendtest.moc"

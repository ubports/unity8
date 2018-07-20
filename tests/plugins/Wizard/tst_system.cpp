/*
 * Copyright (C) 2014 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "System.h"

#include <QDebug>
#include <QObject>
#include <QSignalSpy>
#include <QTemporaryDir>
#include <QTest>

class SystemTest: public QObject
{
    Q_OBJECT

public:
    SystemTest();

private Q_SLOTS:
    void testEnable();
    void testDisable();
    void testNoticeChanges();
    void testUpdate();

private:
    void enable();
    void enableUpdateOnly();
    void disable();
    bool isEnabled();
    bool updateIsEnabled();

    QTemporaryDir dir;
    QDir enableDir;
    QFile enableUpdateWizardFile;
};

SystemTest::SystemTest()
{
    System system;
    qputenv("HOME", dir.path().toUtf8());
    enableDir.setPath(dir.path() + "/.config/ubuntu-system-settings/wizard-has-run/");
    QString updateFileName = enableDir.filePath(QString::number(system.CURRENT_VERSION));
    enableUpdateWizardFile.setFileName(updateFileName);
}

void SystemTest::enable()
{
    enableDir.removeRecursively();
    QCOMPARE(isEnabled(), true);
}

void SystemTest::disable()
{
    enableDir.mkpath(".");
    enableUpdateWizardFile.open(QIODevice::WriteOnly);
    enableUpdateWizardFile.close();
    QCOMPARE(isEnabled(), false);
    QCOMPARE(updateIsEnabled(), false);
}

bool SystemTest::isEnabled()
{
    return !enableDir.exists();
}

void SystemTest::enableUpdateOnly()
{
    disable();
    enableUpdateWizardFile.remove();
    QCOMPARE(updateIsEnabled(), true);
}

bool SystemTest::updateIsEnabled()
{
    return !enableUpdateWizardFile.exists();
}

void SystemTest::testEnable()
{
    disable();

    System system;
    QVERIFY(!system.wizardEnabled());

    system.setWizardEnabled(true);
    QVERIFY(system.wizardEnabled());
    QVERIFY(isEnabled());
}

void SystemTest::testDisable()
{
    enable();

    System system;
    QVERIFY(system.wizardEnabled());

    system.setWizardEnabled(false);
    QVERIFY(!system.wizardEnabled());
    QVERIFY(!isEnabled());
}

void SystemTest::testUpdate()
{
    enableUpdateOnly();

    System system;
    QVERIFY(system.wizardEnabled());
    QVERIFY(system.versionToShow() == system.CURRENT_VERSION);

    system.setWizardEnabled(false);
    QVERIFY(!system.wizardEnabled());
    QVERIFY(!isEnabled());
    QVERIFY(!updateIsEnabled());
}

void SystemTest::testNoticeChanges()
{
    enable();

    System system;
    QSignalSpy spy(&system, SIGNAL(wizardEnabledChanged()));

    // System only guarantees its signals work correcty when using its own set
    // methods (i.e. it won't necessarily notice if we modify the file behind
    // the scenes).  This is because watching all parent directories of the
    // wizard-has-run file with QFileSystemWatcher is a nightmare and waste of
    // resources for the corner case it is.  So we'll just test the set method.

    system.setWizardEnabled(false);
    QTRY_COMPARE(spy.count(), 1);

    system.setWizardEnabled(true);
    QTRY_COMPARE(spy.count(), 2);

    system.setWizardEnabled(false);
    QTRY_COMPARE(spy.count(), 3);

    system.setWizardEnabled(true);
    QTRY_COMPARE(spy.count(), 4);
}

QTEST_MAIN(SystemTest)
#include "tst_system.moc"

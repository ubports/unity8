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

// local
#include "deviceconfigparser.h"

// Qt
#include <QTest>
#include <QDebug>
#include <QSettings>

class DeviceConfigParserTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void initTestCase() {
    }

    void testDefaults()
    {
        DeviceConfigParser p;
        p.setName("nonexistent");

        QCOMPARE(p.supportedOrientations(), Qt::PortraitOrientation | Qt::InvertedPortraitOrientation | Qt::LandscapeOrientation | Qt::InvertedLandscapeOrientation);
        QCOMPARE(p.primaryOrientation(), Qt::PrimaryOrientation);
        QCOMPARE(p.portraitOrientation(), Qt::PortraitOrientation);
        QCOMPARE(p.invertedPortraitOrientation(), Qt::InvertedPortraitOrientation);
        QCOMPARE(p.landscapeOrientation(), Qt::LandscapeOrientation);
        QCOMPARE(p.invertedLandscapeOrientation(), Qt::InvertedLandscapeOrientation);
    }

    void testCustomFile() {
        QSettings s("./devices.conf", QSettings::IniFormat);
        s.beginGroup("fakedevice");

        s.setValue("SupportedOrientations", QStringList() << "Portrait" << "Landscape" << "InvertedLandscape");
        s.setValue("PrimaryOrientation", "InvertedLandscape");
        s.sync();

        DeviceConfigParser p;
        p.setName("fakedevice");

        QCOMPARE(p.supportedOrientations(), Qt::PortraitOrientation | Qt::LandscapeOrientation | Qt::InvertedLandscapeOrientation);
        QCOMPARE(p.primaryOrientation(), Qt::InvertedLandscapeOrientation);
        QCOMPARE(p.portraitOrientation(), Qt::PortraitOrientation);
        QCOMPARE(p.invertedPortraitOrientation(), Qt::InvertedPortraitOrientation);
        QCOMPARE(p.landscapeOrientation(), Qt::LandscapeOrientation);
        QCOMPARE(p.invertedLandscapeOrientation(), Qt::InvertedLandscapeOrientation);
    }

};

QTEST_GUILESS_MAIN(DeviceConfigParserTest)

#include "DeviceConfigParserTest.moc"

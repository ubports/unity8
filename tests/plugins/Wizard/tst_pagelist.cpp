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

#include "PageList.h"

#include <QDebug>
#include <QObject>
#include <QTemporaryDir>
#include <QTest>
#include <QSettings>

#define PAGES_PATH "Wizard/Pages"

class PageListTest: public QObject
{
    Q_OBJECT

public:
    PageListTest() {}

private Q_SLOTS:
    void testCollect();
    void testIterate();
    void testIgnoreNonNumbered();
    void testIgnoreNonQml();
    void testIgnoreDuplicates();
    void testDisabled();
    void testSkipUntilLastPage();

private:
    void fillRoot(const QTemporaryDir &root);
    void makeFile(const QTemporaryDir &root, const QString &dir, const QString &filename);
};

void PageListTest::fillRoot(const QTemporaryDir &root)
{
    QVERIFY(root.isValid());
    QDir rootDir = root.path();
    QVERIFY(rootDir.mkpath(QString("a/") + PAGES_PATH));
    QVERIFY(rootDir.mkpath(QString("b/") + PAGES_PATH));
    QVERIFY(rootDir.mkpath(QString("c/") + PAGES_PATH));
    qputenv("XDG_DATA_DIRS", QString(rootDir.path() + "/a:" +
                                     rootDir.path() + "/b:" +
                                     rootDir.path() + "/c").toLatin1());
}

void PageListTest::makeFile(const QTemporaryDir &root, const QString &dir, const QString &filename)
{
    QFile file(root.path() + "/" + dir + "/" + PAGES_PATH + "/" + filename);
    QVERIFY(file.open(QIODevice::WriteOnly));
    file.close();
    QVERIFY(file.exists());
}

void PageListTest::testCollect()
{
    QTemporaryDir root;
    fillRoot(root);
    makeFile(root, "a", "3.qml");
    makeFile(root, "b", "1.qml");
    makeFile(root, "c", "2.qml");

    PageList pageList;
    QCOMPARE(pageList.entries(), QStringList() << "1.qml" << "2.qml" << "3.qml");
    QCOMPARE(pageList.paths(), QStringList() << root.path() + "/b/" + PAGES_PATH + "/1.qml"
                                             << root.path() + "/c/" + PAGES_PATH + "/2.qml"
                                             << root.path() + "/a/" + PAGES_PATH + "/3.qml");
}

void PageListTest::testIterate()
{
    QTemporaryDir root;
    fillRoot(root);
    makeFile(root, "a", "1.qml");
    makeFile(root, "a", "2.qml");
    makeFile(root, "a", "3.qml");

    PageList pageList;
    QCOMPARE(pageList.index(), -1);
    QCOMPARE(pageList.next(), QString(root.path() + "/a/" + PAGES_PATH + "/1.qml"));
    QCOMPARE(pageList.prev(), QString());
    QCOMPARE(pageList.next(), QString(root.path() + "/a/" + PAGES_PATH + "/2.qml"));
    QCOMPARE(pageList.prev(), QString(root.path() + "/a/" + PAGES_PATH + "/1.qml"));
    QCOMPARE(pageList.index(), 0);
    QCOMPARE(pageList.next(), QString(root.path() + "/a/" + PAGES_PATH + "/2.qml"));
    QCOMPARE(pageList.next(), QString(root.path() + "/a/" + PAGES_PATH + "/3.qml"));
    QCOMPARE(pageList.index(), 2);
    QCOMPARE(pageList.next(), QString());
    QCOMPARE(pageList.index(), 2);
}

void PageListTest::testIgnoreNonNumbered()
{
    QTemporaryDir root;
    fillRoot(root);
    makeFile(root, "a", "1.qml");
    makeFile(root, "a", "nope.qml");

    PageList pageList;
    QCOMPARE(pageList.entries(), QStringList() << "1.qml");
}

void PageListTest::testIgnoreNonQml()
{
    QTemporaryDir root;
    fillRoot(root);
    makeFile(root, "a", "1.qml");
    makeFile(root, "a", "2");
    makeFile(root, "a", "2.txt");

    PageList pageList;
    QCOMPARE(pageList.entries(), QStringList() << "1.qml");
}

void PageListTest::testIgnoreDuplicates()
{
    QTemporaryDir root;
    fillRoot(root);
    makeFile(root, "a", "1.qml");
    makeFile(root, "b", "1.qml");

    PageList pageList;
    QCOMPARE(pageList.paths(), QStringList() << root.path() + "/a/" + PAGES_PATH + "/1.qml");
}

void PageListTest::testDisabled()
{
    QTemporaryDir root;
    fillRoot(root);
    makeFile(root, "a", "1.qml.disabled"); // before the fact
    makeFile(root, "b", "1.qml");
    makeFile(root, "b", "2.qml");
    makeFile(root, "b", "2.qml.disabled"); // same dir
    makeFile(root, "b", "3.qml");
    makeFile(root, "b", "4.qml"); // only survivor
    makeFile(root, "c", "3.qml.disabled"); // after the fact

    PageList pageList;
    QCOMPARE(pageList.entries(), QStringList() << "4.qml");
}

void PageListTest::testSkipUntilLastPage() {
    PageList * pageList = nullptr;
    QTemporaryDir root;
    fillRoot(root);

    makeFile(root, "a", "1.qml");
    makeFile(root, "a", "2.qml");
    makeFile(root, "a", "3.qml");

    // normal run
    pageList = new PageList;
    QCOMPARE(pageList->numPages(), 3);
    delete pageList; pageList = nullptr;

    // after system update had been installed, have the last page only
    QSettings settings;
    settings.setValue(QStringLiteral("Wizard/SkipUntilFinishedPage"), true);
    pageList = new PageList;
    QCOMPARE(pageList->entries(), {QStringLiteral("3.qml")}); // only the last page should be in the list
    delete pageList; pageList = nullptr;

    // normal run again
    pageList = new PageList;
    QCOMPARE(pageList->numPages(), 3);
    delete pageList; pageList = nullptr;
}

QTEST_MAIN(PageListTest)
#include "tst_pagelist.moc"

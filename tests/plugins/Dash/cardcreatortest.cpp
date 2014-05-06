/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#include <QDir>
#include <QQmlEngine>
#include <QQuickItem>
#include <QQuickView>
#include <QtTestGui>

class CardCreatorTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void initTestCase()
    {
    }

    void init()
    {
        view = new QQuickView();
        view->engine()->addImportPath(BUILT_PLUGINS_DIR);
        view->setSource(QUrl::fromLocalFile(DASHVIEWSTEST_FOLDER "/cardcreatortest.qml"));
        view->show();
        QTest::qWaitForWindowExposed(view);
    }

    void cleanup()
    {
        delete view;
    }

    void testKnownCases() 
    {
        const QString templateString("template: ");
        const QString componentsString("components: ");
        const QString resultString("result: ");

        const QString testDirPath = DASHVIEWSTEST_FOLDER "/cardcreator/";
        QDir d(testDirPath);
        const QStringList testFiles = d.entryList(QStringList() << "*.tst");
        foreach(const QString &testFileName, testFiles) {
            QFile testFile(testDirPath + testFileName);
            QVERIFY(testFile.open(QIODevice::ReadOnly));
            QTextStream ts(&testFile);
            const QStringList lines = ts.readAll().split("\n");

            QVERIFY(lines[0].startsWith(templateString));
            QVERIFY(lines[1].startsWith(componentsString));
            QVERIFY(lines[2].startsWith(resultString));
            const QString templateJSON = lines[0].mid(templateString.length());
            const QString componentsJSON = lines[1].mid(componentsString.length());
            const QString resultFileName = lines[2].mid(resultString.length());

            QVariant cardStringResult;
            QMetaObject::invokeMethod(view->rootObject(), "cardString", Q_RETURN_ARG(QVariant, cardStringResult), Q_ARG(QVariant, templateJSON), Q_ARG(QVariant, componentsJSON));

            QFile testResultFile(testDirPath + resultFileName);
            QVERIFY(testResultFile.open(QIODevice::ReadOnly));
            QTextStream ts2(&testResultFile);
            const QString expectedResult = ts2.readAll();
            QCOMPARE(cardStringResult.toString().simplified(), expectedResult.simplified());

            QVariant createCardComponentResult;
            QMetaObject::invokeMethod(view->rootObject(), "createCardComponent", Q_RETURN_ARG(QVariant, createCardComponentResult), Q_ARG(QVariant, templateJSON), Q_ARG(QVariant, componentsJSON));
            QVERIFY(createCardComponentResult.toBool());
        }
    }

private:
    QQuickView *view;
};

QTEST_MAIN(CardCreatorTest)

#include "cardcreatortest.moc"

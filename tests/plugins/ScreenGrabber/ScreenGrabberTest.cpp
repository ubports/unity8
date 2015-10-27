/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "screengrabber.h"

#include <QtTest>
#include <QtQuick/QQuickView>
#include <QtQuick/QQuickItem>
#include <QQmlEngine>

class ScreenGrabberTest: public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void initTestCase()
    {
        m_view = new QQuickView();
        m_view->engine()->addImportPath(BUILT_PLUGINS_DIR);
        m_view->setSource(QUrl::fromLocalFile(CURRENT_SOURCE_DIR "/grabber.qml"));
        m_grabber = dynamic_cast<ScreenGrabber*>(m_view->rootObject()->property("grabber").value<QObject*>());
        QVERIFY(m_grabber);
        m_view->show();
        QTest::qWaitForWindowExposed(m_view);
    }

    void cleanupTestCase()
    {
        delete m_view;
        m_view = nullptr;
        QTRY_COMPARE(QThreadPool::globalInstance()->activeThreadCount(), 0);
    }

    void testGrabScreenshot()
    {
        QSignalSpy grabberSpy(m_grabber, &ScreenGrabber::screenshotSaved);
        m_grabber->captureAndSave();
        QTRY_VERIFY(grabberSpy.count() == 1);
        const QVariantList args = grabberSpy.takeFirst();
        QVERIFY(args.count() == 1); // verify we got a non-empty filename where the screenshot has been saved
        QVERIFY(!args.first().toString().isEmpty());
    }

    void testRotatedScreenshot()
    {
        QSignalSpy grabberSpy(m_grabber, &ScreenGrabber::screenshotSaved);
        m_grabber->captureAndSave(90); // rotate by 90°
        const QVariantList args = grabberSpy.takeFirst();
        const QString filename = args.first().toString();
        QVERIFY(!filename.isEmpty());
        QImage img(filename);
        QVERIFY(img.height() > img.width()); // verify that the image got rotated by 90° (height > width)
    }

private:
    QQuickView *m_view;
    ScreenGrabber *m_grabber = nullptr;
};

QTEST_MAIN(ScreenGrabberTest)

#include "ScreenGrabberTest.moc"

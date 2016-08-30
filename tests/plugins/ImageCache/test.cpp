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

#include <QCoreApplication>
#include <QFileInfo>
#include <QImageReader>
#include <QQuickView>
#include <QTemporaryDir>
#include <QtTestGui>
#include <private/qquickimage_p.h>
#include <time.h>
#include <utime.h>

Q_DECLARE_METATYPE(QQuickImage::Status)

class ImageCacheTest : public QObject
{
    Q_OBJECT

private:

    void setUpImage(const QString &name, const QSize &sourceSize = QSize())
    {
        QString url = "image://unity8imagecache/file://" + sourceFile(name);
        image->setProperty("sourceSize", sourceSize);
        image->setProperty("source", url);
    }

    void waitForImage(QQuickImage::Status status = QQuickImage::Ready)
    {
        QTRY_COMPARE(image->property("status"), QVariant((int)status));
    }

    QSize cachedImageSize(const QString &filename)
    {
        QImageReader reader(filename);
        return reader.size();
    }

    QString sourceFile(const QString &name)
    {
        return CURRENT_SOURCE_DIR "/graphics/" + name;
    }

    QString cachedFile(bool isPath, const QString &name)
    {
        if (isPath)
            return home->path() + "/.cache/unity8/imagecache/paths" + sourceFile(name);
        else
            return home->path() + "/.cache/unity8/imagecache/names/" + name;
    }

    void createCachedImage(const QString &name, const QString &cachePath, const QSize &cacheSize, time_t mtime_in = 0)
    {
        QString origPath = sourceFile(name);
        QImageReader origImage(origPath);
        origImage.setScaledSize(cacheSize);
        auto format = origImage.format(); // can't get this after reading

        QImage cacheImage(origImage.read());
        QVERIFY(!cacheImage.isNull());

        QFileInfo(cachePath).dir().mkpath(QStringLiteral("."));
        QVERIFY(cacheImage.save(cachePath, format, 100));

        // Make file a few seconds old, so we can more easily tell if it gets updated
        auto mtime = mtime_in == 0 ? QFileInfo(cachePath).lastModified().toTime_t() - 5 : mtime_in;
        struct utimbuf timebuffer;
        timebuffer.modtime = mtime;
        timebuffer.actime = timebuffer.modtime;
        QCOMPARE(utime(cachePath.toUtf8().data(), &timebuffer), 0);
    }

private Q_SLOTS:

    void init()
    {
        home = new QTemporaryDir();
        QVERIFY(home->isValid());
        qputenv("HOME", home->path().toUtf8());

        view = new QQuickView();
        view->setSource(QUrl::fromLocalFile(CURRENT_SOURCE_DIR "/test.qml"));
        image = view->rootObject();

        view->show();
        QTest::qWaitForWindowExposed(view);

        waitForImage(QQuickImage::Null);
    }

    void cleanup()
    {
        delete view;
        delete home;
    }

    void testFileNotFound()
    {
        setUpImage("NOTHERE");
        waitForImage(QQuickImage::Error);
        QVERIFY(!QFile::exists(cachedFile(true, "NOTHERE")));
    }

    void testNoSourceSize()
    {
        setUpImage("wide.jpg");
        waitForImage();
        QVERIFY(!QFile::exists(cachedFile(true, "wide.jpg")));
    }

    void testNoScalingUp()
    {
        setUpImage("wide.jpg", QSize(1000, 1000));
        waitForImage();
        QVERIFY(!QFile::exists(cachedFile(true, "wide.jpg")));
    }

    void testFullSourceSize()
    {
        setUpImage("wide.jpg", QSize(100, 100));
        waitForImage();
        QCOMPARE(cachedImageSize(cachedFile(true, "wide.jpg")), QSize(100, 100));
    }

    void testWidthSourceSize()
    {
        setUpImage("wide.jpg", QSize(100, 0));
        waitForImage();
        // wide.jpg is 500x200
        QCOMPARE(cachedImageSize(cachedFile(true, "wide.jpg")), QSize(100, 40));
    }

    void testHeightSourceSize()
    {
        setUpImage("wide.jpg", QSize(0, 100));
        waitForImage();
        // wide.jpg is 500x200
        QCOMPARE(cachedImageSize(cachedFile(true, "wide.jpg")), QSize(250, 100));
    }

    void testNameArg()
    {
        setUpImage("wide.jpg?name=foo", QSize(0, 100));
        waitForImage();
        QVERIFY(!QFile::exists(cachedFile(true, ""))); // check for dir itself
        QVERIFY(QFile::exists(cachedFile(false, "foo")));
    }

    void testLoadCache()
    {
        auto cacheName = cachedFile(false, "foo");
        createCachedImage("wide.jpg", cacheName, QSize(250, 100));
        auto mtime = QFileInfo(cacheName).lastModified();

        auto now = time(NULL);
        QVERIFY(QFileInfo(cacheName).lastModified().toTime_t() < now); // sanity check

        setUpImage("wide.jpg?name=foo", QSize(0, 100));
        waitForImage();
        QCOMPARE(QFileInfo(cacheName).lastModified(), mtime); // wasn't recreated
    }

    void testDifferentSize()
    {
        auto cacheName = cachedFile(false, "foo");
        createCachedImage("wide.jpg", cacheName, QSize(250, 100));

        auto now = time(NULL);
        QVERIFY(QFileInfo(cacheName).lastModified().toTime_t() < now); // sanity check

        setUpImage("wide.jpg?name=foo", QSize(100, 0));
        waitForImage();
        QVERIFY(QFileInfo(cacheName).lastModified().toTime_t() >= now); // was recreated
    }

    void testStaleCache()
    {
        auto sourceName = sourceFile("wide.jpg");
        auto mtime = QFileInfo(sourceName).lastModified().toTime_t() - 5;

        auto cacheName = cachedFile(false, "foo");
        createCachedImage("wide.jpg", cacheName, QSize(250, 100), mtime);

        auto now = time(NULL);
        QVERIFY(QFileInfo(cacheName).lastModified().toTime_t() < now); // sanity check

        setUpImage("wide.jpg?name=foo", QSize(0, 100));
        waitForImage();
        QVERIFY(QFileInfo(cacheName).lastModified().toTime_t() >= now); // was recreated
    }

private:
    QQuickView *view;
    QObject *image;
    QTemporaryDir *home;
};

QTEST_MAIN(ImageCacheTest)

#include "test.moc"

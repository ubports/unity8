/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#include "listviewwithpageheader.h"

#include <QAbstractItemModel>
#include <QQmlEngine>
#include <QQuickView>
#include <QSignalSpy>
#include <QtTestGui>
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-pedantic"
#include <private/qqmllistmodel_p.h>
#include <private/qquickanimation_p.h>
#include <private/qquickitem_p.h>
#pragma GCC diagnostic pop

class ListViewWithPageHeaderTestSection : public QObject
{
    Q_OBJECT

private:
    void verifyItem(int visibleIndex, qreal pos, qreal height, bool culled, const QString &sectionHeader, bool sectionHeaderCulled)
    {
        QTRY_VERIFY(visibleIndex < lvwph->m_visibleItems.count());
        QTRY_COMPARE(lvwph->m_visibleItems[visibleIndex]->y(), pos);
        QTRY_COMPARE(lvwph->m_visibleItems[visibleIndex]->height(), height);
        QCOMPARE(QQuickItemPrivate::get(lvwph->m_visibleItems[visibleIndex]->m_item)->culled, culled);
        QCOMPARE(section(lvwph->m_visibleItems[visibleIndex]->sectionItem()), sectionHeader);
        if (!sectionHeader.isNull()) {
            QCOMPARE(QQuickItemPrivate::get(lvwph->m_visibleItems[visibleIndex]->sectionItem())->culled, sectionHeaderCulled);
            QCOMPARE(sectionDelegateIndex(lvwph->m_visibleItems[visibleIndex]->sectionItem()), lvwph->m_firstVisibleIndex + visibleIndex);
        }
    }

    void changeContentY(qreal change)
    {
        const qreal dest = lvwph->contentY() + change;
        if (dest > lvwph->contentY()) {
            const qreal jump = 25;
            while (lvwph->contentY() + jump < dest) {
                lvwph->setContentY(lvwph->contentY() + jump);
                QTest::qWait(1);
            }
        } else {
            const qreal jump = -25;
            while (lvwph->contentY() + jump > dest) {
                lvwph->setContentY(lvwph->contentY() + jump);
                QTest::qWait(1);
            }
        }
        lvwph->setContentY(dest);
        QTest::qWait(1);
    }

    void scrollToTop()
    {
        const qreal jump = -25;
        while (!lvwph->isAtYBeginning()) {
            if (lvwph->contentY() + jump > -lvwph->minYExtent()) {
                lvwph->setContentY(lvwph->contentY() + jump);
            } else {
                lvwph->setContentY(lvwph->contentY() - 1);
            }
            QTest::qWait(1);
        }
    }

    void scrollToBottom()
    {
        const qreal jump = 25;
        while (!lvwph->isAtYEnd()) {
            if (lvwph->contentY() + lvwph->height() + jump < lvwph->contentHeight()) {
                lvwph->setContentY(lvwph->contentY() + jump);
            } else {
                lvwph->setContentY(lvwph->contentY() + 1);
            }
            QTest::qWait(1);
        }
    }

    void verifyInitialTopPosition()
    {
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 190., false, "Agressive", false);
        verifyItem(1, 240., 240., false, "Regular", false);
        verifyItem(2, 480., 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    bool hasSectionHeaderProperty(QQuickItem *item) const
    {
        return item ? QQmlEngine::contextForObject(item)->parentContext()->contextProperty(QLatin1String("hasSectionHeader")).toBool() : false;
    }

    QString section(QQuickItem *item) const
    {
        return item ? item->property("text").toString() : QString();
    }

    int sectionDelegateIndex(QQuickItem *item) const
    {
        return item ? item->property("delegateIndex").toInt() : -1;
    }

private Q_SLOTS:

    void initTestCase()
    {
    }

    void init()
    {
        view = new QQuickView();
        view->setSource(QUrl::fromLocalFile(DASHVIEWSTEST_FOLDER "/listviewwithpageheadertestsection.qml"));
        lvwph = dynamic_cast<ListViewWithPageHeader*>(view->rootObject()->findChild<QQuickFlickable*>());
        model = view->rootObject()->findChild<QQmlListModel*>();
        otherDelegate = view->rootObject()->findChild<QQmlComponent*>();
        QVERIFY(lvwph);
        QVERIFY(model);
        QVERIFY(otherDelegate);
        view->show();
        QTest::qWaitForWindowExposed(view);

        verifyInitialTopPosition();
    }

    void cleanup()
    {
        delete view;
    }

    void testCreationDeletion()
    {
        // Nothing, init/cleanup already tests this
    }

    void testDrag1PixelUp()
    {
        lvwph->setContentY(lvwph->contentY() + 1);
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 49., 190., false, "Agressive", false);
        verifyItem(1, 239., 240., false, "Regular", false);
        verifyItem(2, 479., 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 1.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 1.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testHeaderDetachDragDown()
    {
        QTest::mousePress(view, Qt::LeftButton, Qt::NoModifier, QPoint(0, 0));
        QTest::qWait(100);
        QTest::mouseMove(view, QPoint(0, 5));
        QTest::qWait(100);
        QTest::mouseMove(view, QPoint(0, 10));
        QTest::qWait(100);
        QTest::mouseMove(view, QPoint(0, 15));
        QTest::qWait(100);
        QTest::mouseMove(view, QPoint(0, 20));
        QTest::qWait(100);
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 55., 190., false, "Agressive", false);
        verifyItem(1, 245., 240., false, "Regular", false);
        verifyItem(2, 485., 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), -5.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), -5.);
        QCOMPARE(lvwph->m_headerItem->height(), 55.);
        QCOMPARE(lvwph->contentY(), -5.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);

        QTest::mouseRelease(view, Qt::LeftButton, Qt::NoModifier, QPoint(0, 15));

        verifyInitialTopPosition();
    }

    void testDrag375PixelUp()
    {
        changeContentY(375);
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -325., 190., true, "Agressive", true);
        verifyItem(1, -135, 240., false, "Regular", true);
        verifyItem(2, 105, 390., false, "Mild", false);
        verifyItem(3, 495, 390., false, "Bold", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 375.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 375.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Regular"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 1);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testDrag520PixelUp()
    {
        changeContentY(520);
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 1);
        verifyItem(0, -280., 240., true, "Regular", true);
        verifyItem(1, -40, 390., false, "Mild", true);
        verifyItem(2, 350, 390., false, "Bold", false);
        verifyItem(3, 740, 350., true, QString(), true);
        QCOMPARE(lvwph->m_minYExtent, 152.5);
        QCOMPARE(lvwph->m_clipItem->y(), 520.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 520.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Mild"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 2);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testDragHeaderUpThenShow()
    {
        changeContentY(120);
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -70., 190., false, "Agressive", true);
        verifyItem(1, 120., 240., false, "Regular", false);
        verifyItem(2, 360., 390., false, "Mild", false);
        verifyItem(3, 750., 390., true, "Bold", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 120.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 120.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Agressive"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 0);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        changeContentY(-30);
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -70., 190., false, "Agressive", true);
        verifyItem(1, 120., 240., false, "Regular", false);
        verifyItem(2, 360., 390., false, "Mild", false);
        verifyItem(3, 750., 390., true, "Bold", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 120.);
        QCOMPARE(lvwph->m_clipItem->clip(), true);
        QTRY_COMPARE(lvwph->m_headerItem->y(), 70.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 90.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 30.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Agressive"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 0);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testDragHeaderUpThenShowWithoutHidingTotally()
    {
        changeContentY(10);
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 40., 190., false, "Agressive", false);
        verifyItem(1, 230., 240., false, "Regular", false);
        verifyItem(2, 470., 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 10.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 10.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);

        changeContentY(-1);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 41., 190., false, "Agressive", false);
        verifyItem(1, 231., 240., false, "Regular", false);
        verifyItem(2, 471., 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 9.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QTRY_COMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 9.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testPositionAtBeginningIndex0Visible()
    {
        changeContentY(375);
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -325., 190., true, "Agressive", true);
        verifyItem(1, -135, 240., false, "Regular", true);
        verifyItem(2, 105, 390., false, "Mild", false);
        verifyItem(3, 495, 390., false, "Bold", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 375.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 375.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Regular"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 1);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        lvwph->positionAtBeginning();

        verifyInitialTopPosition();
    }

    void testPositionAtBeginningIndex0NotVisible()
    {
        changeContentY(520);
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 1);
        verifyItem(0, -280., 240., true, "Regular", true);
        verifyItem(1, -40, 390., false, "Mild", true);
        verifyItem(2, 350, 390., false, "Bold", false);
        verifyItem(3, 740, 350., true, QString(), true);
        QCOMPARE(lvwph->m_minYExtent, 152.5);
        QCOMPARE(lvwph->m_clipItem->y(), 520.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 520.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Mild"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 2);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        lvwph->positionAtBeginning();

        verifyInitialTopPosition();
    }

    void testIndex0GrowOnScreen()
    {
        model->setProperty(0, "size", 400);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 440., false, "Agressive", false);
        verifyItem(1, 490., 240., false, "Regular", false);
        verifyItem(2, 730., 390., true, "Mild", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testIndex0GrowOffScreen()
    {
        changeContentY(375);
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -325., 190., true, "Agressive", true);
        verifyItem(1, -135, 240., false, "Regular", true);
        verifyItem(2, 105, 390., false, "Mild", false);
        verifyItem(3, 495, 390., false, "Bold", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 375.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 375.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Regular"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 1);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        model->setProperty(0, "size", 400);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -575., 440., true, "Agressive", true);
        verifyItem(1, -135, 240., false, "Regular", true);
        verifyItem(2, 105, 390., false, "Mild", false);
        verifyItem(3, 495, 390., false, "Bold", false);
        QCOMPARE(lvwph->m_minYExtent, 250.);
        QCOMPARE(lvwph->m_clipItem->y(), 375.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 375.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Regular"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 1);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        scrollToTop();

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 440., false, "Agressive", false);
        verifyItem(1, 490, 240., false, "Regular", false);
        verifyItem(2, 730, 390., true, "Mild", true);
        QCOMPARE(lvwph->m_minYExtent, 250.);
        QCOMPARE(lvwph->m_clipItem->y(), -250.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), -250.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), -250.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);

        changeContentY(30);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 20., 440., false, "Agressive", false);
        verifyItem(1, 460, 240., false, "Regular", false);
        verifyItem(2, 700, 390., true, "Mild", true);
        QCOMPARE(lvwph->m_minYExtent, 250.);
        QCOMPARE(lvwph->m_clipItem->y(), -220.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), -250.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), -220.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testIndex0GrowNotCreated()
    {
        changeContentY(520);
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 1);
        verifyItem(0, -280., 240., true, "Regular", true);
        verifyItem(1, -40, 390., false, "Mild", true);
        verifyItem(2, 350, 390., false, "Bold", false);
        verifyItem(3, 740, 350., true, QString(), true);
        QCOMPARE(lvwph->m_minYExtent, 152.5);
        QCOMPARE(lvwph->m_clipItem->y(), 520.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 520.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Mild"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 2);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        model->setProperty(0, "size", 400);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 1);
        verifyItem(0, -280., 240., true, "Regular", true);
        verifyItem(1, -40, 390., false, "Mild", true);
        verifyItem(2, 350, 390., false, "Bold", false);
        verifyItem(3, 740, 350., true, QString(), true);
        QCOMPARE(lvwph->m_minYExtent, 152.5);
        QCOMPARE(lvwph->m_clipItem->y(), 520.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 520.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Mild"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 2);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        scrollToTop();

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 440., false, "Agressive", false);
        verifyItem(1, 490, 240., false, "Regular", false);
        verifyItem(2, 730, 390., true, "Mild", true);
        QCOMPARE(lvwph->m_minYExtent, 250.);
        QCOMPARE(lvwph->m_clipItem->y(), -250.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), -250.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), -250.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testShowHideShowHeaderAtBottom()
    {
        scrollToBottom();
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 3);
        verifyItem(0, -588., 390., true, "Bold", true);
        verifyItem(1, -198, 350., false, QString(), true);
        verifyItem(2, 152, 390., false, "Lazy", false);
        QCOMPARE(lvwph->m_minYExtent, 310.);
        QCOMPARE(lvwph->m_clipItem->y(), 1458.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 1458.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Bold"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 3);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        changeContentY(-30);
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 3);
        verifyItem(0, -588., 390., true, "Bold", true);
        verifyItem(1, -198, 350., false, QString(), true);
        verifyItem(2, 152, 390., false, "Lazy", false);
        QCOMPARE(lvwph->m_minYExtent, 310.);
        QCOMPARE(lvwph->m_clipItem->y(), 1458.);
        QCOMPARE(lvwph->m_clipItem->clip(), true);
        QCOMPARE(lvwph->m_headerItem->y(), 1408.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 1428.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 30.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Bold"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 3);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        changeContentY(30);
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 3);
        verifyItem(0, -588., 390., true, "Bold", true);
        verifyItem(1, -198, 350., false, QString(), true);
        verifyItem(2, 152, 390., false, "Lazy", false);
        QCOMPARE(lvwph->m_minYExtent, 310.);
        QCOMPARE(lvwph->m_clipItem->y(), 1458.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), -310.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 1458.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Bold"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 3);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        changeContentY(-30);
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 3);
        verifyItem(0, -588., 390., true, "Bold", true);
        verifyItem(1, -198, 350., false, QString(), true);
        verifyItem(2, 152, 390., false, "Lazy", false);
        QCOMPARE(lvwph->m_minYExtent, 310.);
        QCOMPARE(lvwph->m_clipItem->y(), 1458.);
        QCOMPARE(lvwph->m_clipItem->clip(), true);
        QCOMPARE(lvwph->m_headerItem->y(), 1408.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 1428.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 30.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Bold"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 3);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testChangeDelegateAtBottom()
    {
        scrollToBottom();
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 3);
        verifyItem(0, -588., 390., true, "Bold", true);
        verifyItem(1, -198, 350., false, QString(), true);
        verifyItem(2, 152, 390., false, "Lazy", false);
        QCOMPARE(lvwph->m_minYExtent, 310.);
        QCOMPARE(lvwph->m_clipItem->y(), 1458.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 1458.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Bold"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 3);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        lvwph->setDelegate(otherDelegate);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 6);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 75., false, "Agressive", false);
        verifyItem(1, 125, 75., false, "Regular", false);
        verifyItem(2, 200, 75., false, "Mild", false);
        verifyItem(3, 275, 75., false, "Bold", false);
        verifyItem(4, 350, 35., false, QString(), true);
        verifyItem(5, 385, 75., false, "Lazy", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testSetEmptyHeaderAtTop()
    {
        lvwph->setHeader(nullptr);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 0., 190., false, "Agressive", false);
        verifyItem(1, 190., 240., false, "Regular", false);
        verifyItem(2, 430., 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem, (QQuickItem*)nullptr);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testSetEmptyHeaderAtBottom()
    {
        scrollToBottom();
        lvwph->setHeader(nullptr);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 3);
        verifyItem(0, -588., 390., true, "Bold", true);
        verifyItem(1, -198, 350., false, QString(), true);
        verifyItem(2, 152, 390., false, "Lazy", false);
        QCOMPARE(lvwph->m_minYExtent, 260.);
        QCOMPARE(lvwph->m_clipItem->y(), 1458.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem, (QQuickItem*)nullptr);
        QCOMPARE(lvwph->contentY(), 1458.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Bold"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 3);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        scrollToTop();

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 0., 190., false, "Agressive", false);
        verifyItem(1, 190., 240., false, "Regular", false);
        verifyItem(2, 430., 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, -50.);
        QCOMPARE(lvwph->m_clipItem->y(), 50.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem, (QQuickItem*)nullptr);
        QCOMPARE(lvwph->contentY(), 50.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testSetEmptyHeaderWhenPartlyShownClipped()
    {
        scrollToBottom();
        changeContentY(-30);
        lvwph->setHeader(nullptr);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 3);
        verifyItem(0, -588., 390., true, "Bold", true);
        verifyItem(1, -198, 350., false, QString(), true);
        verifyItem(2, 152, 390., false, "Lazy", false);
        QCOMPARE(lvwph->m_minYExtent, 290.);
        QCOMPARE(lvwph->m_clipItem->y(), 1428.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem, (QQuickItem*)nullptr);
        QCOMPARE(lvwph->contentY(), 1428.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QTRY_VERIFY(lvwph->isAtYEnd());
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Bold"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 3);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        scrollToTop();

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 0., 190., false, "Agressive", false);
        verifyItem(1, 190., 240., false, "Regular", false);
        verifyItem(2, 430., 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, -20.);
        QCOMPARE(lvwph->m_clipItem->y(), 20.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem, (QQuickItem*)nullptr);
        QCOMPARE(lvwph->contentY(), 20.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testSetEmptyHeaderWhenPartlyShownNotClipped()
    {
        changeContentY(30);
        lvwph->setHeader(nullptr);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -30., 190., false, "Agressive", true);
        verifyItem(1, 160., 240., false, "Regular", false);
        verifyItem(2, 400., 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 30.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem, (QQuickItem*)nullptr);
        QCOMPARE(lvwph->contentY(), 30.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Agressive"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 0);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testSetNullDelegate()
    {
        lvwph->setDelegate(nullptr);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 0);
        QCOMPARE(lvwph->m_firstVisibleIndex, -1);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QTRY_COMPARE(lvwph->contentHeight(), 50.);
        QVERIFY(lvwph->isAtYBeginning());
        QVERIFY(lvwph->isAtYEnd());
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testInsertItems()
    {
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 1), Q_ARG(QVariant, 100), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 1), Q_ARG(QVariant, 125), Q_ARG(QVariant, "Regular"));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 5);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 190., false, "Agressive", false);
        verifyItem(1, 240., 165., false, "Regular", false);
        verifyItem(2, 405., 140., false, "Agressive", false);
        verifyItem(3, 545., 240., true, "Regular", true);
        verifyItem(4, 785., 390., true, "Mild", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testInsertItemsStealSectionItem()
    {
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 1), Q_ARG(QVariant, 125), Q_ARG(QVariant, "Regular"));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 190., false, "Agressive", false);
        verifyItem(1, 240., 165., false, "Regular", false);
        verifyItem(2, 405., 200., false, QString(), true);
        verifyItem(3, 605., 390., true, "Mild", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }


    void testInsertItemsOnNotShownPosition()
    {
        changeContentY(800);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QTRY_COMPARE(lvwph->m_firstVisibleIndex, 2);
        verifyItem(0, -320., 390., false, "Mild", true);
        verifyItem(1, 70, 390., false, "Bold", false);
        verifyItem(2, 460, 350., false, QString(), false);
        verifyItem(3, 810, 390., true, "Lazy", true);
        QCOMPARE(lvwph->m_minYExtent, 330.);
        QCOMPARE(lvwph->m_clipItem->y(), 800.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 800.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Mild"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 2);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 1), Q_ARG(QVariant, 100), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 1), Q_ARG(QVariant, 125), Q_ARG(QVariant, "Regular"));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 4);
        verifyItem(0, -320., 390., false, "Mild", true);
        verifyItem(1, 70, 390., false, "Bold", false);
        verifyItem(2, 460, 350., false, QString(), false);
        verifyItem(3, 810, 390., true, "Lazy", true);
        QCOMPARE(lvwph->m_minYExtent, 1090.);
        QCOMPARE(lvwph->m_clipItem->y(), 800.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 800.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Mild"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 4);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        scrollToTop();

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 5);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 190., false, "Agressive", false);
        verifyItem(1, 240., 165., false, "Regular", false);
        verifyItem(2, 405., 140., false, "Agressive", false);
        verifyItem(3, 545., 240., true, "Regular", true);
        verifyItem(4, 785., 390., true, "Mild", true);
        QCOMPARE(lvwph->m_minYExtent, 305.);
        QCOMPARE(lvwph->m_clipItem->y(), -305.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), -305.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), -305.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testInsertItemsAtEndOfViewport()
    {
        changeContentY(60);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -10., 190., false, "Agressive", true);
        verifyItem(1, 180., 240., false, "Regular", false);
        verifyItem(2, 420., 390., false, "Mild", false);
        verifyItem(3, 810., 390., true, "Bold", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 60.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 60.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Agressive"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 0);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 3), Q_ARG(QVariant, 100), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 3), Q_ARG(QVariant, 125), Q_ARG(QVariant, "Regular"));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -10., 190., false, "Agressive", true);
        verifyItem(1, 180., 240., false, "Regular", false);
        verifyItem(2, 420., 390., false, "Mild", false);
        verifyItem(3, 810., 165., true, "Regular", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 60.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 60.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Agressive"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 0);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testInsertItemsBeforeValidIndex()
    {
        changeContentY(520);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 1);
        verifyItem(0, -280., 240., true, "Regular", true);
        verifyItem(1, -40, 390., false, "Mild", true);
        verifyItem(2, 350, 390., false, "Bold", false);
        verifyItem(3, 740, 350., true, QString(), true);
        QCOMPARE(lvwph->m_minYExtent, 152.5);
        QCOMPARE(lvwph->m_clipItem->y(), 520.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 520.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Mild"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 2);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 1), Q_ARG(QVariant, 100), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 1), Q_ARG(QVariant, 125), Q_ARG(QVariant, "Regular"));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 3);
        verifyItem(0, -280., 240., true, "Regular", true);
        verifyItem(1, -40, 390., false, "Mild", true);
        verifyItem(2, 350, 390., false, "Bold", false);
        verifyItem(3, 740, 350., true, QString(), true);
        QCOMPARE(lvwph->m_minYExtent, 837.5);
        QCOMPARE(lvwph->m_clipItem->y(), 520.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 520.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Mild"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 4);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testInsertItemsBeforeViewport()
    {
        changeContentY(375);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -325., 190., true, "Agressive", true);
        verifyItem(1, -135, 240., false, "Regular", true);
        verifyItem(2, 105, 390., false, "Mild", false);
        verifyItem(3, 495, 390., false, "Bold", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 375.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 375.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Regular"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 1);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 1), Q_ARG(QVariant, 100), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 1), Q_ARG(QVariant, 125), Q_ARG(QVariant, "Regular"));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 2);
        verifyItem(0, -275., 140., true, "Agressive", true);
        verifyItem(1, -135., 240., false, "Regular", true);
        verifyItem(2, 105, 390., false, "Mild", false);
        verifyItem(3, 495, 390., false, "Bold", false);
        QCOMPARE(lvwph->m_minYExtent, 530.);
        QCOMPARE(lvwph->m_clipItem->y(), 375.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 375.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Regular"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 3);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        scrollToTop();

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 5);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 190., false, "Agressive", false);
        verifyItem(1, 240., 165., false, "Regular", false);
        verifyItem(2, 405., 140., false, "Agressive", false);
        verifyItem(3, 545., 240., true, "Regular", true);
        verifyItem(4, 785., 390., true, "Mild", true);
        QCOMPARE(lvwph->m_minYExtent, 305.);
        QCOMPARE(lvwph->m_clipItem->y(), -305.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), -305.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), -305.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testInsertItemsAtBottom()
    {
        scrollToBottom();

        QVERIFY(lvwph->isAtYEnd());

        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 100), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 125), Q_ARG(QVariant, "Regular"));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 5);
        QCOMPARE(lvwph->m_firstVisibleIndex, 3);
        verifyItem(0, -588., 390., true, "Bold", true);
        verifyItem(1, -198, 350., false, QString(), true);
        verifyItem(2, 152, 390., false, "Lazy", false);
        verifyItem(3, 542, 165., true, "Regular", true);
        verifyItem(4, 707, 140., true, "Agressive", true);
        QCOMPARE(lvwph->m_minYExtent, 41.);
        QCOMPARE(lvwph->m_clipItem->y(), 1458.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 1458.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!lvwph->isAtYEnd());
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Bold"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 3);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        scrollToBottom();

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 4);
        verifyItem(0, -503., 350., true, QString(), true);
        verifyItem(1, -153, 390., false, "Lazy", true);
        verifyItem(2, 237, 165., false, "Regular", false);
        verifyItem(3, 402, 140., false, "Agressive", false);
        QCOMPARE(lvwph->m_minYExtent, -165.);
        QCOMPARE(lvwph->m_clipItem->y(), 1763.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 1763.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(lvwph->isAtYEnd());
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Lazy"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 5);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testInsertItemAtTop()
    {
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 75), Q_ARG(QVariant, "Agressive"));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 115., false, "Agressive", false);
        verifyItem(1, 165., 150., false, QString(), false);
        verifyItem(2, 315., 240., false, "Regular", false);
        verifyItem(3, 555., 390., true, "Mild", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(lvwph->isAtYBeginning());
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testInsertItem10SmallItemsAtTopWhenAtBottom()
    {
        scrollToBottom();

        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 75), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 75), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 75), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 75), Q_ARG(QVariant, "Regular"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 75), Q_ARG(QVariant, "Regular"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 75), Q_ARG(QVariant, "Regular"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 75), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 75), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 75), Q_ARG(QVariant, "Regular"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 75), Q_ARG(QVariant, "Agressive"));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 13);
        verifyItem(0, -588., 390., true, "Bold", true);
        verifyItem(1, -198, 350., false, QString(), true);
        verifyItem(2, 152, 390., false, "Lazy", false);
        QCOMPARE(lvwph->m_minYExtent, 12230./3.);
        QCOMPARE(lvwph->m_clipItem->y(), 1458.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 1458.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Bold"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 13);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        changeContentY(-1700);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 10);
        QCOMPARE(lvwph->m_firstVisibleIndex, 3);
        verifyItem(0, -323., 75., true, QString(), true);
        verifyItem(1, -248., 115., true, "Regular", true);
        verifyItem(2, -133., 75., true, QString(), true);
        verifyItem(3, -58., 75., false, QString(), true);
        verifyItem(4, 17., 115., false, "Agressive", false);
        verifyItem(5, 132., 75., false, QString(), true);
        verifyItem(6, 207., 75., false, QString(), true);
        verifyItem(7, 282., 150., false, QString(), true);
        verifyItem(8, 432., 240., false, "Regular", false);
        QCOMPARE(lvwph->m_minYExtent, 980.5);
        QCOMPARE(lvwph->m_clipItem->y(), -192.);
        QCOMPARE(lvwph->m_clipItem->clip(), true);
        QCOMPARE(lvwph->m_headerItem->y(), -242.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), -242.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 50.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Regular"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 4);
        QCOMPARE(lvwph->m_topSectionItem->y(), -23.);
    }

    void testInsertToEmpty()
    {
        QMetaObject::invokeMethod(model, "removeItems", Q_ARG(QVariant, 0), Q_ARG(QVariant, 6));
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 0);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);

        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 100), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 1), Q_ARG(QVariant, 125), Q_ARG(QVariant, "Regular"));
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 2);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 140., false, "Agressive", false);
        verifyItem(1, 190., 165., false, "Regular", false);
    }

    void testRemoveItemsAtTop()
    {
        QMetaObject::invokeMethod(model, "removeItems", Q_ARG(QVariant, 0), Q_ARG(QVariant, 2));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 2);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 390., false, "Mild", false);
        verifyItem(1, 440., 390., false, "Bold", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(lvwph->isAtYBeginning());
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testRemoveNonCreatedItemsAtTopWhenAtBottom()
    {
        scrollToBottom();

        QMetaObject::invokeMethod(model, "removeItems", Q_ARG(QVariant, 0), Q_ARG(QVariant, 2));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 1);
        verifyItem(0, -588., 390., true, "Bold", true);
        verifyItem(1, -198, 350., false, QString(), true);
        verifyItem(2, 152, 390., false, "Lazy", false);
        QCOMPARE(lvwph->m_minYExtent, -1330./3.);
        QCOMPARE(lvwph->m_clipItem->y(), 1458.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 1458.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Bold"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 1);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testRemoveLastItemsAtBottom()
    {
        scrollToBottom();

        QMetaObject::invokeMethod(model, "removeItems", Q_ARG(QVariant, 4), Q_ARG(QVariant, 2));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 1);
        verifyItem(0, -478., 240., true, "Regular", true);
        verifyItem(1, -238, 390., false, "Mild", true);
        verifyItem(2, 152, 390., false, "Bold", false);
        QCOMPARE(lvwph->m_minYExtent, 150.);
        QCOMPARE(lvwph->m_clipItem->y(), 718.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 718.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Mild"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 2);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testRemoveItemOutOfViewport()
    {
        changeContentY(520);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 1);
        verifyItem(0, -280., 240., true, "Regular", true);
        verifyItem(1, -40, 390., false, "Mild", true);
        verifyItem(2, 350, 390., false, "Bold", false);
        verifyItem(3, 740, 350., true, QString(), true);
        QCOMPARE(lvwph->m_minYExtent, 152.5);
        QCOMPARE(lvwph->m_clipItem->y(), 520.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 520.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Mild"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 2);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        QMetaObject::invokeMethod(model, "removeItems", Q_ARG(QVariant, 1), Q_ARG(QVariant, 1));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -230., 190., true, "Agressive", true);
        verifyItem(1, -40, 390., false, "Mild", true);
        verifyItem(2, 350, 390., false, "Bold", false);
        verifyItem(3, 740, 350., true, QString(), true);
        QCOMPARE(lvwph->m_minYExtent, -240.);
        QCOMPARE(lvwph->m_clipItem->y(), 520.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 520.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Mild"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 1);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testRemoveFirstOfCategory()
    {
        changeContentY(520);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 1);
        verifyItem(0, -280., 240., true, "Regular", true);
        verifyItem(1, -40, 390., false, "Mild", true);
        verifyItem(2, 350, 390., false, "Bold", false);
        verifyItem(3, 740, 350., true, QString(), true);
        QCOMPARE(lvwph->m_minYExtent, 152.5);
        QCOMPARE(lvwph->m_clipItem->y(), 520.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 520.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Mild"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 2);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        QMetaObject::invokeMethod(model, "removeItems", Q_ARG(QVariant, 3), Q_ARG(QVariant, 1));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 1);
        verifyItem(0, -280., 240., true, "Regular", true);
        verifyItem(1, -40, 390., false, "Mild", true);
        verifyItem(2, 350, 390., false, "Bold", false);
        verifyItem(3, 740, 390., true, "Lazy", true);
        QCOMPARE(lvwph->m_minYExtent, 162.5);
        QCOMPARE(lvwph->m_clipItem->y(), 520.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 520.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Mild"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 2);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testAddSecondToCulledCategoryOfTwo()
    {
        // Do some setup
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 25), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 25), Q_ARG(QVariant, "Agressive"));

        changeContentY(200);

        // Very the items are culled
        verifyItem(0, -150., 65., true, "Agressive", true);
        verifyItem(1, -85, 25., true, QString(), true);

        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 1), Q_ARG(QVariant, 25), Q_ARG(QVariant, "Agressive"));

        // Very the new item is there correctly
        verifyItem(0, -175., 65., true, "Agressive", true);
        verifyItem(1, -110, 25., true, QString(), true);
        verifyItem(2, -85, 25., true, QString(), true);
    }

    void testMoveFirstItems()
    {
        QMetaObject::invokeMethod(model, "moveItems", Q_ARG(QVariant, 0), Q_ARG(QVariant, 1), Q_ARG(QVariant, 1));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 240., false, "Regular", false);
        verifyItem(1, 290., 190., false, "Agressive", false);
        verifyItem(2, 480., 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testMoveFirstOutOfVisibleItems()
    {
        QMetaObject::invokeMethod(model, "moveItems", Q_ARG(QVariant, 0), Q_ARG(QVariant, 4), Q_ARG(QVariant, 1));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 240., false, "Regular", false);
        verifyItem(1, 290., 390., false, "Mild", false);
        verifyItem(2, 680., 390., true, "Bold", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testMoveFirstToLastAtBottom()
    {
        scrollToBottom();

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 3);
        verifyItem(0, -588., 390., true, "Bold", true);
        verifyItem(1, -198, 350., false, QString(), true);
        verifyItem(2, 152, 390., false, "Lazy", false);
        QCOMPARE(lvwph->m_minYExtent, 310.);
        QCOMPARE(lvwph->m_clipItem->y(), 1458.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 1458.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Bold"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 3);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        QMetaObject::invokeMethod(model, "moveItems", Q_ARG(QVariant, 0), Q_ARG(QVariant, 5), Q_ARG(QVariant, 1));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 2);
        verifyItem(0, -588., 390., true, "Bold", true);
        verifyItem(1, -198, 350., false, QString(), true);
        verifyItem(2, 152, 390., false, "Lazy", false);
        verifyItem(3, 542, 190., true, "Agressive", true);
        QCOMPARE(lvwph->m_minYExtent, -160.);
        QCOMPARE(lvwph->m_clipItem->y(), 1458.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 1458.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!lvwph->isAtYEnd());
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Bold"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 2);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testChangeSizeVisibleItemNotOnViewport()
    {
        changeContentY(490);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 5);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -440., 190., true, "Agressive", true);
        verifyItem(1, -250., 240., true, "Regular", true);
        verifyItem(2, -10, 390., false, "Mild", true);
        verifyItem(3, 380, 390., false, "Bold", false);
        verifyItem(4, 770, 350., true, QString(), true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 490.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 490.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Mild"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 2);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        model->setProperty(1, "size", 100);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 5);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -340., 190., true, "Agressive", true);
        verifyItem(1, -150., 140., true, "Regular", true);
        verifyItem(2, -10, 390., false, "Mild", true);
        verifyItem(3, 380, 390., false, "Bold", false);
        verifyItem(4, 770, 350., true, QString(), true);
        QCOMPARE(lvwph->m_minYExtent, -100.);
        QCOMPARE(lvwph->m_clipItem->y(), 490.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 490.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Mild"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 2);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testShowHeaderHalfShown()
    {
        changeContentY(20);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 30., 190., false, "Agressive", false);
        verifyItem(1, 220, 240., false, "Regular", false);
        verifyItem(2, 460, 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 20.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 20.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);

        lvwph->showHeader();

        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -20., 190., false, "Agressive", true);
        verifyItem(1, 170, 240., false, "Regular", false);
        verifyItem(2, 410, 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 20.);
        QCOMPARE(lvwph->m_clipItem->y(), 50.);
        QCOMPARE(lvwph->m_clipItem->clip(), true);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 50.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Agressive"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 0);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        scrollToTop();

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 190., false, "Agressive", false);
        verifyItem(1, 240., 240., false, "Regular", false);
        verifyItem(2, 480., 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 20.);
        QCOMPARE(lvwph->m_clipItem->y(), -20.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), -20.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), -20.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testShowHeaderCloseToTheTop()
    {
        changeContentY(375);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -325., 190., true, "Agressive", true);
        verifyItem(1, -135, 240., false, "Regular", true);
        verifyItem(2, 105, 390., false, "Mild", false);
        verifyItem(3, 495, 390., false, "Bold", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 375.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 375.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Regular"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 1);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        lvwph->showHeader();

        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -375., 190., true, "Agressive", true);
        verifyItem(1, -185, 240., false, "Regular", true);
        verifyItem(2, 55, 390., false, "Mild", false);
        verifyItem(3, 445, 390., false, "Bold", false);
        QCOMPARE(lvwph->m_minYExtent, 50.);
        QCOMPARE(lvwph->m_clipItem->y(), 375.);
        QCOMPARE(lvwph->m_clipItem->clip(), true);
        QCOMPARE(lvwph->m_headerItem->y(), 325.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 325.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 50.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Regular"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 1);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        scrollToTop();

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 190., false, "Agressive", false);
        verifyItem(1, 240., 240., false, "Regular", false);
        verifyItem(2, 480., 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 50.);
        QCOMPARE(lvwph->m_clipItem->y(), -50.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), -50.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), -50.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testShowHeaderAtBottom()
    {
        scrollToBottom();

        lvwph->showHeader();

        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());
        QTRY_VERIFY (lvwph->isAtYEnd());
    }

    void growWindow()
    {
        view->rootObject()->setHeight(850);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 5);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 190., false, "Agressive", false);
        verifyItem(1, 240., 240., false, "Regular", false);
        verifyItem(2, 480., 390., false, "Mild", false);
        verifyItem(3, 870., 390., true, "Bold", true);
        verifyItem(4, 1260., 350., true, QString(), true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
    }

    void growWindowAtBottom()
    {
        // Need a bunch small items at the bottom to trigger the problem
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Regular"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Regular"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Regular"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Regular"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Regular"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Regular"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 6), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Agressive"));

        scrollToBottom();

        view->rootObject()->setHeight(850);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 21);
        QCOMPARE(lvwph->m_firstVisibleIndex, 5);
        verifyItem(0, -660., 390., true, "Lazy", true);
        verifyItem(1, -270., 90., true, "Agressive", true);
        verifyItem(2, -180, 50., true, QString(), true);
        verifyItem(3, -130, 50., true, QString(), true);
        verifyItem(4, -80, 50., true, QString(), true);
        verifyItem(5, -30, 50., false, QString(), true);
        verifyItem(6, 20, 50., false, QString(), true);
        verifyItem(7, 70, 50., false, QString(), true);
        verifyItem(8, 120, 50., false, QString(), true);
        verifyItem(9, 170, 90., false, "Regular", false);
        verifyItem(10, 260, 50., false, QString(), true);
        verifyItem(11, 310, 50., false, QString(), true);
        verifyItem(12, 360, 50., false, QString(), true);
        verifyItem(13, 410, 50., false, QString(), true);
        verifyItem(14, 460, 50., false, QString(), true);
        verifyItem(15, 510, 90., false, "Agressive", false);
        verifyItem(16, 600, 50., false, QString(), true);
        verifyItem(17, 650, 50., false, QString(), true);
        verifyItem(18, 700, 50., false, QString(), true);
        verifyItem(19, 750, 50., false, QString(), true);
        verifyItem(20, 800, 50., false, QString(), true);
        QCOMPARE(lvwph->m_clipItem->y(), lvwph->contentY());
        QCOMPARE(lvwph->m_minYExtent, 5 * 1510./21. + 660 - lvwph->contentY() + 50);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
    }

    void testCullOnBottomEdge()
    {
        changeContentY(240);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -190., 190., true, "Agressive", true);
        verifyItem(1, 0., 240., false, "Regular", false);
        verifyItem(2, 240., 390., false, "Mild", false);
        verifyItem(3, 630., 390., true, "Bold", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 240.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 240.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testSectionItemCullOnFirstSectionItemTopEdge()
    {
        changeContentY(50);

        verifyItem(0, 0., 190., false, "Agressive", false);
        verifyItem(1, 190., 240., false, "Regular", false);
        verifyItem(2, 430., 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 50.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 50.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testSectionItemCullOnSecondSectionItemTopEdge()
    {
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 50), Q_ARG(QVariant, "Agressive"));

        changeContentY(5);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 5);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 45., 90., false, "Agressive", false);
        verifyItem(1, 135., 50., false, QString(), false);
        verifyItem(2, 185., 150., false, QString(), false);
        verifyItem(3, 335., 240., false, "Regular", false);
        verifyItem(4, 575., 390., true, "Mild", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 5.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 5.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);

        changeContentY(135);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 5);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -90., 90., true, "Agressive", true);
        verifyItem(1, 0., 50., false, QString(), false);
        verifyItem(2, 50., 150., false, QString(), false);
        verifyItem(3, 200., 240., false, "Regular", false);
        verifyItem(4, 440., 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 140.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 140.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Agressive"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 0);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testMaximizeVisibleArea()
    {
        bool res = lvwph->maximizeVisibleArea(2);
        QVERIFY(res);
        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -278., 190., true, "Agressive", true);
        verifyItem(1, -88., 240., false, "Regular", true);
        verifyItem(2, 152, 390., false, "Mild", false);
        verifyItem(3, 542, 390., true, "Bold", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 328.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 328.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Regular"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 1);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testMaximizeVisibleAreaVisibleItems()
    {
        bool res = lvwph->maximizeVisibleArea(0);
        QVERIFY(res);
        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());

        verifyInitialTopPosition();

        res = lvwph->maximizeVisibleArea(1);
        QVERIFY(res);
        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());

        verifyInitialTopPosition();
    }

    void testMaximizeVisibleAreaInvalidIndexes()
    {
        bool res = lvwph->maximizeVisibleArea(-1);
        QVERIFY(!res);
        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());

        verifyInitialTopPosition();

        res = lvwph->maximizeVisibleArea(1000);
        QVERIFY(!res);
        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());

        verifyInitialTopPosition();

        res = lvwph->maximizeVisibleArea(3);
        QVERIFY(!res);
        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());

        verifyInitialTopPosition();
    }

    void testMaximizeVisibleAreaBigElement()
    {
        model->setProperty(2, "size", 4000);
        verifyItem(2, 480, 4040., false, "Mild", false);

        bool res = lvwph->maximizeVisibleArea(2);
        QVERIFY(res);
        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -430., 190., true, "Agressive", true);
        verifyItem(1, -240., 240., true, "Regular", true);
        verifyItem(2, 0, 4040., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 480.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 480.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testMaximizeVisibleAreaScrollDown()
    {
        changeContentY(350);
        bool res = lvwph->maximizeVisibleArea(1);
        QVERIFY(res);
        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -190., 190., true, "Agressive", true);
        verifyItem(1, 0., 240., false, "Regular", false);
        verifyItem(2, 240, 390., false, "Mild", false);
        verifyItem(3, 630, 390., true, "Bold", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 240.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 240.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testMaximizeVisibleAreaScrollDownBigElement()
    {
        model->setProperty(1, "size", 1000);
        changeContentY(1150);
        bool res = lvwph->maximizeVisibleArea(1);
        QVERIFY(res);
        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 2);
        QCOMPARE(lvwph->m_firstVisibleIndex, 1);
        verifyItem(0, -498., 1040., false, "Regular", true);
        verifyItem(1, 542., 390., true, "Mild", true);
        QCOMPARE(lvwph->m_minYExtent, 525.);
        QCOMPARE(lvwph->m_clipItem->y(), 738.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 738.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Regular"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 1);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testMaximizeVisibleAreaBigElementInTheMiddle()
    {
        model->setProperty(1, "size", 1000);
        changeContentY(650);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 2);
        QCOMPARE(lvwph->m_firstVisibleIndex, 1);
        verifyItem(0, -410., 1040., false, "Regular", true);
        verifyItem(1, 630., 390., true, "Mild", true);
        QCOMPARE(lvwph->m_minYExtent, 525.);
        QCOMPARE(lvwph->m_clipItem->y(), 650.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 650.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Regular"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 1);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        bool res = lvwph->maximizeVisibleArea(1);
        QVERIFY(res);
        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 2);
        QCOMPARE(lvwph->m_firstVisibleIndex, 1);
        verifyItem(0, -410., 1040., false, "Regular", true);
        verifyItem(1, 630., 390., true, "Mild", true);
        QCOMPARE(lvwph->m_minYExtent, 525.);
        QCOMPARE(lvwph->m_clipItem->y(), 650.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 650.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Regular"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 1);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testMaximizeVisibleAreaTopWithHalfPageHeader()
    {
        changeContentY(430);
        changeContentY(-30);

        bool res = lvwph->maximizeVisibleArea(1);
        QVERIFY(res);
        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -190., 190., true, "Agressive", true);
        verifyItem(1, 0., 240., false, "Regular", false);
        verifyItem(2, 240, 390., false, "Mild", false);
        verifyItem(3, 630, 390., true, "Bold", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 240.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 240.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void testMaximizeVisibleAreaBottomWithHalfPageHeader()
    {
        changeContentY(430);
        changeContentY(-30);

        bool res = lvwph->maximizeVisibleArea(3);
        QVERIFY(res);
        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 1);
        verifyItem(0, -478., 240., true, "Regular", true);
        verifyItem(1, -238., 390., false, "Mild", true);
        verifyItem(2, 152, 390., false, "Bold", false);
        verifyItem(3, 542, 350., true, QString(), true);
        QCOMPARE(lvwph->m_minYExtent, 152.5);
        QCOMPARE(lvwph->m_clipItem->y(), 718.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 718.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Mild"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 2);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testMaximizeVisibleAreaTopSecondSectionItemStickySection()
    {
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 100), Q_ARG(QVariant, "Agressive"));
        changeContentY(250);
        bool res = lvwph->maximizeVisibleArea(1);
        QVERIFY(res);
        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -100., 140., false, "Agressive", true);
        verifyItem(1, 40., 150., false, QString(), true);
        verifyItem(2, 190, 240., false, "Regular", false);
        verifyItem(3, 430, 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 150.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 150.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Agressive"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 0);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);

        changeContentY(20);
        res = lvwph->maximizeVisibleArea(1);
        QVERIFY(res);
        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 4);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -100., 140., false, "Agressive", true);
        verifyItem(1, 40., 150., false, QString(), true);
        verifyItem(2, 190, 240., false, "Regular", false);
        verifyItem(3, 430, 390., false, "Mild", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 150.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 150.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(!QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
        QCOMPARE(section(lvwph->m_topSectionItem), QString("Agressive"));
        QCOMPARE(sectionDelegateIndex(lvwph->m_topSectionItem), 0);
        QCOMPARE(lvwph->m_topSectionItem->y(), 0.);
    }

    void testMaximizeVisibleAreaWithItemResize()
    {
        model->setProperty(0, "size", 1000);

        bool res = lvwph->maximizeVisibleArea(1);
        QVERIFY(res);
        QTRY_VERIFY(!lvwph->m_contentYAnimation->isRunning());

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 3);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, -738., 1040., false, "Agressive", true);
        verifyItem(1, 302., 240., false, "Regular", false);
        verifyItem(2, 542, 390., true, "Mild", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 788.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 788.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
    }

    void addingRemoveItemsShouldNotChangeContentY()
    {
        QSignalSpy spy(lvwph, &ListViewWithPageHeader::contentYChanged);
        QMetaObject::invokeMethod(model, "insertItem", Q_ARG(QVariant, 0), Q_ARG(QVariant, 150), Q_ARG(QVariant, "Agressive"));
        QMetaObject::invokeMethod(model, "removeItems", Q_ARG(QVariant, 1), Q_ARG(QVariant, 6));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 1);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 190., false, "Agressive", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);

        QCOMPARE(spy.count(), 0);
    }

    void testDownAndUp()
    {
        QMetaObject::invokeMethod(model, "removeItems", Q_ARG(QVariant, 1), Q_ARG(QVariant, 5));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 1);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 190., false, "Agressive", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);

        QTest::qWait(1);
        QCoreApplication::instance()->processEvents();

        changeContentY(-15);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 1);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 65., 190., false, "Agressive", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), -15.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), -15.);
        QCOMPARE(lvwph->m_headerItem->height(), 65.);
        QCOMPARE(lvwph->contentY(), -15.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);

        changeContentY(25);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 1);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 40., 190., false, "Agressive", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 10.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 10.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);


        QTest::mouseClick(view, Qt::LeftButton, Qt::NoModifier, QPoint(0, 0));

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 1);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 190., false, "Agressive", false);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    void changeSectionProperty()
    {
        model->setProperty(1, "type", "Rojo");
        verifyItem(1, 240., 240., false, "Rojo", false);

        model->setProperty(1, "type", "Agressive");
        verifyItem(1, 240., 200., false, QString(), true);

        model->setProperty(1, "type", "Rojo");
        verifyItem(1, 240., 240., false, "Rojo", false);

        model->setProperty(1, "type", "Mild");
        verifyItem(1, 240., 240., false, "Mild", false);
        verifyItem(2, 480., 350., false, QString(), false);

        model->setProperty(1, "type", "Rojo");
        verifyItem(1, 240., 240., false, "Rojo", false);
        verifyItem(2, 480., 390., false, "Mild", false);

        model->setProperty(2, "type", "Agressive");
        verifyItem(2, 480., 390., false, "Agressive", false);

        model->setProperty(1, "type", "Agressive");
        verifyItem(1, 240., 200., false, QString(), true);
        verifyItem(2, 440., 350., false, QString(), false);

        model->setProperty(1, "type", "Rojo");
        verifyItem(1, 240., 240., false, "Rojo", false);
        verifyItem(2, 480., 390., false, "Agressive", false);
    }

    void firstItemSectionHeightChange()
    {
        QMetaObject::invokeMethod(model, "removeItems", Q_ARG(QVariant, 1), Q_ARG(QVariant, 5));
        model->setProperty(0, "type", "halfheight");
        verifyItem(0, 50., 170., false, "halfheight", false);
    }

    void secondItemSectionHeightChange()
    {
        QMetaObject::invokeMethod(model, "removeItems", Q_ARG(QVariant, 2), Q_ARG(QVariant, 4));
        model->setProperty(1, "type", "halfheight");
        verifyItem(0, 50., 190., false, "Agressive", false);
        verifyItem(1, 240., 220., false, "halfheight", false);
    }

private:
    QQuickView *view;
    ListViewWithPageHeader *lvwph;
    QQmlListModel *model;
    QQmlComponent *otherDelegate;
};

QTEST_MAIN(ListViewWithPageHeaderTestSection)

#include "listviewwithpageheadersectiontest.moc"

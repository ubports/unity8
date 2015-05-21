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

#include <QQuickView>
#include <QtTestGui>
#include <QDebug>
#include <QGuiApplication>
#include <QQuickView>
#include <QtQml/qqml.h>
#include <QStringListModel>
#include <QQmlContext>
#include <QQmlEngine>
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-pedantic"
#include <private/qquickitem_p.h>
#pragma GCC diagnostic pop

#include "horizontaljournal.h"

class WidthModel : public QAbstractListModel {
public:
    QHash<int, QByteArray> roleNames() const override
    {
        QHash<int, QByteArray> roles;
        roles.insert(Qt::DisplayRole, "modelWidth");
        return roles;
    }

    int rowCount(const QModelIndex & /*parent*/) const override
    {
        return m_list.count();
    }

    QVariant data(const QModelIndex &index, int /*role*/) const override
    {
        return m_list[index.row()];
    }

    QStringList stringList() const
    {
        return m_list;
    }

    void setStringList(const QStringList &list)
    {
        beginResetModel();
        m_list = list;
        endResetModel();
    }

    void addString(const QString& string)
    {
        beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
        m_list << string;
        endInsertRows();
    }

    void removeLast()
    {
        beginRemoveRows(QModelIndex(), m_list.count() - 1, m_list.count() - 1);
        m_list.takeLast();
        endRemoveRows();
    }

private:
    QStringList m_list;
};

class HorizontalJournalTest : public QObject
{
    Q_OBJECT

private:
    void verifyItem(const QQuickItem *item, int modelIndex, qreal x, qreal y, bool visible)
    {
        QTRY_COMPARE(item->x(), x);
        QTRY_COMPARE(item->y(), y);
        QTRY_COMPARE(item->width(), model->stringList()[modelIndex].toDouble());
        QTRY_COMPARE(QQuickItemPrivate::get(item)->culled, !visible);
    }

    void checkInitialPositions()
    {
        QTRY_COMPARE(hj->m_firstVisibleIndex, 0);
        QTRY_COMPARE(hj->m_visibleItems.count(), 14);
        verifyItem(hj->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(hj->m_visibleItems[ 1],  1, 110,   0, true);
        verifyItem(hj->m_visibleItems[ 2],  2, 170,   0, true);
        verifyItem(hj->m_visibleItems[ 3],  3, 305,   0, true);
        verifyItem(hj->m_visibleItems[ 4],  4, 325,   0, true);
        verifyItem(hj->m_visibleItems[ 5],  5, 375,   0, true);
        verifyItem(hj->m_visibleItems[ 6],  6,   0, 160, true);
        verifyItem(hj->m_visibleItems[ 7],  7, 210, 160, true);
        verifyItem(hj->m_visibleItems[ 8],  8,   0, 320, true);
        verifyItem(hj->m_visibleItems[ 9],  9, 170, 320, true);
        verifyItem(hj->m_visibleItems[10], 10, 200, 320, true);
        verifyItem(hj->m_visibleItems[11], 11, 230, 320, true);
        verifyItem(hj->m_visibleItems[12], 12, 305, 320, true);
        verifyItem(hj->m_visibleItems[13], 13,   0, 480, false);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition.count(), 4);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[ 5], 375.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[ 7], 210.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[12], 305.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[13],   0.);
        QCOMPARE(hj->implicitHeight(), 900.);
    }

private Q_SLOTS:
    void init()
    {
        view = new QQuickView();
        view->setResizeMode(QQuickView::SizeRootObjectToView);

        model = new WidthModel();
        QStringList widthList;
        widthList << "100" << "50" << "125" << "10" << "40" << "70" << "200" << "110" << "160" << "20" << "20" << "65" << "80" << "200" << "300" << "130" << "400" << "300" << "500" << "10";
        model->setStringList(widthList);

        view->setSource(QUrl::fromLocalFile(DASHVIEWSTEST_FOLDER "/horizontaljournaltest.qml"));

        view->show();
        view->resize(470, 400);
        QTest::qWaitForWindowExposed(view);

        hj = dynamic_cast<HorizontalJournal*>(view->rootObject()->findChild<QObject*>("hj"));
        hj->setModel(model);

        checkInitialPositions();
    }

    void cleanup()
    {
        delete view;
        delete model;
    }

    void testWidthResize()
    {
        view->resize(629, 400);
        QTRY_COMPARE(hj->width(), 629.);

        QTRY_COMPARE(hj->m_firstVisibleIndex, 0);
        QTRY_COMPARE(hj->m_visibleItems.count(), 17);
        verifyItem(hj->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(hj->m_visibleItems[ 1],  1, 110,   0, true);
        verifyItem(hj->m_visibleItems[ 2],  2, 170,   0, true);
        verifyItem(hj->m_visibleItems[ 3],  3, 305,   0, true);
        verifyItem(hj->m_visibleItems[ 4],  4, 325,   0, true);
        verifyItem(hj->m_visibleItems[ 5],  5, 375,   0, true);
        verifyItem(hj->m_visibleItems[ 6],  6,   0, 160, true);
        verifyItem(hj->m_visibleItems[ 7],  7, 210, 160, true);
        verifyItem(hj->m_visibleItems[ 8],  8, 330, 160, true);
        verifyItem(hj->m_visibleItems[ 9],  9, 500, 160, true);
        verifyItem(hj->m_visibleItems[10], 10, 530, 160, true);
        verifyItem(hj->m_visibleItems[11], 11, 560, 160, true);
        verifyItem(hj->m_visibleItems[12], 12,   0, 320, true);
        verifyItem(hj->m_visibleItems[13], 13,  90, 320, true);
        verifyItem(hj->m_visibleItems[14], 14, 300, 320, true);
        verifyItem(hj->m_visibleItems[15], 15,   0, 480, false);
        verifyItem(hj->m_visibleItems[16], 16, 140, 480, false);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition.count(), 4);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[ 5], 375.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[11], 560.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[14], 300.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[16], 140.);
        QCOMPARE(hj->implicitHeight(), 630. + 3. * 630. / 17.);

        view->resize(470, 400);

        // This is exactly the same block as the first again
        checkInitialPositions();
    }

    void testColumnSpacing()
    {
        hj->setColumnSpacing(11);

        QTRY_COMPARE(hj->m_needsRelayout, false);
        QTRY_COMPARE(hj->m_firstVisibleIndex, 0);
        QTRY_COMPARE(hj->m_visibleItems.count(), 14);
        verifyItem(hj->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(hj->m_visibleItems[ 1],  1, 111,   0, true);
        verifyItem(hj->m_visibleItems[ 2],  2, 172,   0, true);
        verifyItem(hj->m_visibleItems[ 3],  3, 308,   0, true);
        verifyItem(hj->m_visibleItems[ 4],  4, 329,   0, true);
        verifyItem(hj->m_visibleItems[ 5],  5, 380,   0, true);
        verifyItem(hj->m_visibleItems[ 6],  6,   0, 160, true);
        verifyItem(hj->m_visibleItems[ 7],  7, 211, 160, true);
        verifyItem(hj->m_visibleItems[ 8],  8,   0, 320, true);
        verifyItem(hj->m_visibleItems[ 9],  9, 171, 320, true);
        verifyItem(hj->m_visibleItems[10], 10, 202, 320, true);
        verifyItem(hj->m_visibleItems[11], 11, 233, 320, true);
        verifyItem(hj->m_visibleItems[12], 12, 309, 320, true);
        verifyItem(hj->m_visibleItems[13], 13,   0, 480, false);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition.count(), 4);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[ 5], 380.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[ 7], 211.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[12], 309.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[13],   0.);
        QCOMPARE(hj->implicitHeight(), 900.);

        hj->setColumnSpacing(10);
        QTRY_COMPARE(hj->m_needsRelayout, false);

        // This is exactly the same block as the first again
        checkInitialPositions();
    }

    void testRowSpacing()
    {
        hj->setRowSpacing(11);

        QTRY_COMPARE(hj->m_needsRelayout, false);
        QTRY_COMPARE(hj->m_needsRelayout, false);
        QTRY_COMPARE(hj->m_firstVisibleIndex, 0);
        QTRY_COMPARE(hj->m_visibleItems.count(), 14);
        verifyItem(hj->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(hj->m_visibleItems[ 1],  1, 110,   0, true);
        verifyItem(hj->m_visibleItems[ 2],  2, 170,   0, true);
        verifyItem(hj->m_visibleItems[ 3],  3, 305,   0, true);
        verifyItem(hj->m_visibleItems[ 4],  4, 325,   0, true);
        verifyItem(hj->m_visibleItems[ 5],  5, 375,   0, true);
        verifyItem(hj->m_visibleItems[ 6],  6,   0, 161, true);
        verifyItem(hj->m_visibleItems[ 7],  7, 210, 161, true);
        verifyItem(hj->m_visibleItems[ 8],  8,   0, 322, true);
        verifyItem(hj->m_visibleItems[ 9],  9, 170, 322, true);
        verifyItem(hj->m_visibleItems[10], 10, 200, 322, true);
        verifyItem(hj->m_visibleItems[11], 11, 230, 322, true);
        verifyItem(hj->m_visibleItems[12], 12, 305, 322, true);
        verifyItem(hj->m_visibleItems[13], 13,   0, 483, false);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition.count(), 4);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[ 5], 375.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[ 7], 210.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[12], 305.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[13],   0.);
        QCOMPARE(hj->implicitHeight(), 633. + 6. * 633. / 14.);

        hj->setRowSpacing(10);
        QTRY_COMPARE(hj->m_needsRelayout, false);

        // This is exactly the same block as the first again
        checkInitialPositions();
    }

    void testDelegateCreationRanges()
    {
        hj->setDisplayMarginBeginning(-300);
        hj->setDisplayMarginEnd(-(hj->height() - view->height()));

        QTRY_COMPARE(hj->m_firstVisibleIndex, 6);
        QTRY_COMPARE(hj->m_visibleItems.count(), 7);
        verifyItem(hj->m_visibleItems[0],  6,   0, 160, true);
        verifyItem(hj->m_visibleItems[1],  7, 210, 160, true);
        verifyItem(hj->m_visibleItems[2],  8,   0, 320, true);
        verifyItem(hj->m_visibleItems[3],  9, 170, 320, true);
        verifyItem(hj->m_visibleItems[4], 10, 200, 320, true);
        verifyItem(hj->m_visibleItems[5], 11, 230, 320, true);
        verifyItem(hj->m_visibleItems[6], 12, 305, 320, true);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[ 5], 375.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[ 7], 210.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[12], 305.);

        hj->setDisplayMarginBeginning(0);
        hj->setDisplayMarginEnd(0);

        // This is exactly the same block as the first again
        checkInitialPositions();
    }


    void testRowHeightChange()
    {
        hj->setRowHeight(200);
        QTRY_COMPARE(hj->m_firstVisibleIndex, 0);
        QTRY_COMPARE(hj->m_visibleItems.count(), 13);
        verifyItem(hj->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(hj->m_visibleItems[ 1],  1, 110,   0, true);
        verifyItem(hj->m_visibleItems[ 2],  2, 170,   0, true);
        verifyItem(hj->m_visibleItems[ 3],  3, 305,   0, true);
        verifyItem(hj->m_visibleItems[ 4],  4, 325,   0, true);
        verifyItem(hj->m_visibleItems[ 5],  5, 375,   0, true);
        verifyItem(hj->m_visibleItems[ 6],  6,   0, 210, true);
        verifyItem(hj->m_visibleItems[ 7],  7, 210, 210, true);
        verifyItem(hj->m_visibleItems[ 8],  8,   0, 420, false);
        verifyItem(hj->m_visibleItems[ 9],  9, 170, 420, false);
        verifyItem(hj->m_visibleItems[10], 10, 200, 420, false);
        verifyItem(hj->m_visibleItems[11], 11, 230, 420, false);
        verifyItem(hj->m_visibleItems[12], 12, 305, 420, false);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition.count(), 3);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[ 5], 375.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[ 7], 210.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[12], 305.);
        QCOMPARE(hj->implicitHeight(), 620. + 7. * 620. / 13.);

        hj->setRowHeight(150);

        // This is exactly the same block as the first again
        checkInitialPositions();
    }

    void testChangeModel()
    {
        WidthModel *model2 = new WidthModel();
        QStringList list2;
        list2 << "100" << "50" << "125" << "25" << "50" << "50";
        model2->setStringList(list2);
        hj->setModel(model2);
        delete model;
        model = model2;

        QTRY_COMPARE(hj->m_firstVisibleIndex, 0);
        QTRY_COMPARE(hj->m_visibleItems.count(), 6);
        verifyItem(hj->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(hj->m_visibleItems[ 1],  1, 110,   0, true);
        verifyItem(hj->m_visibleItems[ 2],  2, 170,   0, true);
        verifyItem(hj->m_visibleItems[ 3],  3, 305,   0, true);
        verifyItem(hj->m_visibleItems[ 4],  4, 340,   0, true);
        verifyItem(hj->m_visibleItems[ 5],  5, 400,   0, true);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition.count(), 0);
        QCOMPARE(hj->implicitHeight(), 150.);
    }

    void testModelReset()
    {
        QStringList widthList;
        widthList << "100" << "50" << "125" << "25" << "50" << "50";
        model->setStringList(widthList);

        QTRY_COMPARE(hj->m_firstVisibleIndex, 0);
        QTRY_COMPARE(hj->m_visibleItems.count(), 6);
        verifyItem(hj->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(hj->m_visibleItems[ 1],  1, 110,   0, true);
        verifyItem(hj->m_visibleItems[ 2],  2, 170,   0, true);
        verifyItem(hj->m_visibleItems[ 3],  3, 305,   0, true);
        verifyItem(hj->m_visibleItems[ 4],  4, 340,   0, true);
        verifyItem(hj->m_visibleItems[ 5],  5, 400,   0, true);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition.count(), 0);
        QCOMPARE(hj->implicitHeight(), 150.);
    }

    void testModelRemoveLastNonVisible()
    {
        model->removeLast();

        // This is the same than checkInitialPositions but
        // with a different implicitHeight since there's an item less
        // in the model
        QTRY_COMPARE(hj->m_firstVisibleIndex, 0);
        QTRY_COMPARE(hj->m_visibleItems.count(), 14);
        verifyItem(hj->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(hj->m_visibleItems[ 1],  1, 110,   0, true);
        verifyItem(hj->m_visibleItems[ 2],  2, 170,   0, true);
        verifyItem(hj->m_visibleItems[ 3],  3, 305,   0, true);
        verifyItem(hj->m_visibleItems[ 4],  4, 325,   0, true);
        verifyItem(hj->m_visibleItems[ 5],  5, 375,   0, true);
        verifyItem(hj->m_visibleItems[ 6],  6,   0, 160, true);
        verifyItem(hj->m_visibleItems[ 7],  7, 210, 160, true);
        verifyItem(hj->m_visibleItems[ 8],  8,   0, 320, true);
        verifyItem(hj->m_visibleItems[ 9],  9, 170, 320, true);
        verifyItem(hj->m_visibleItems[10], 10, 200, 320, true);
        verifyItem(hj->m_visibleItems[11], 11, 230, 320, true);
        verifyItem(hj->m_visibleItems[12], 12, 305, 320, true);
        verifyItem(hj->m_visibleItems[13], 13,   0, 480, false);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition.count(), 4);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[ 5], 375.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[ 7], 210.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[12], 305.);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[13],   0.);
        QTRY_COMPARE(hj->implicitHeight(), 855.);
    }

    void testModelAppendRemoveLast()
    {
        WidthModel *model2 = new WidthModel();
        QStringList widthList;
        widthList << "100" << "50" << "125" << "25" << "50" << "50";
        model2->setStringList(widthList);
        hj->setModel(model2);
        delete model;
        model = model2;

        QTRY_COMPARE(hj->m_firstVisibleIndex, 0);
        QTRY_COMPARE(hj->m_visibleItems.count(), 6);
        verifyItem(hj->m_visibleItems[0],  0,   0,   0, true);
        verifyItem(hj->m_visibleItems[1],  1, 110,   0, true);
        verifyItem(hj->m_visibleItems[2],  2, 170,   0, true);
        verifyItem(hj->m_visibleItems[3],  3, 305,   0, true);
        verifyItem(hj->m_visibleItems[4],  4, 340,   0, true);
        verifyItem(hj->m_visibleItems[5],  5, 400,   0, true);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition.count(), 0);
        QCOMPARE(hj->implicitHeight(), 150.);

        model2->addString("75");

        QTRY_COMPARE(hj->m_firstVisibleIndex, 0);
        QTRY_COMPARE(hj->m_visibleItems.count(), 7);
        verifyItem(hj->m_visibleItems[0],  0,   0,   0, true);
        verifyItem(hj->m_visibleItems[1],  1, 110,   0, true);
        verifyItem(hj->m_visibleItems[2],  2, 170,   0, true);
        verifyItem(hj->m_visibleItems[3],  3, 305,   0, true);
        verifyItem(hj->m_visibleItems[4],  4, 340,   0, true);
        verifyItem(hj->m_visibleItems[5],  5, 400,   0, true);
        verifyItem(hj->m_visibleItems[6],  6,   0,  160, true);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition.count(), 1);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[5], 400.);
        QCOMPARE(hj->implicitHeight(), 310.);

        model2->addString("50");
        model2->addString("50");

        QTRY_COMPARE(hj->m_firstVisibleIndex, 0);
        QTRY_COMPARE(hj->m_visibleItems.count(), 9);
        verifyItem(hj->m_visibleItems[0],  0,   0,   0, true);
        verifyItem(hj->m_visibleItems[1],  1, 110,   0, true);
        verifyItem(hj->m_visibleItems[2],  2, 170,   0, true);
        verifyItem(hj->m_visibleItems[3],  3, 305,   0, true);
        verifyItem(hj->m_visibleItems[4],  4, 340,   0, true);
        verifyItem(hj->m_visibleItems[5],  5, 400,   0, true);
        verifyItem(hj->m_visibleItems[6],  6,   0,  160, true);
        verifyItem(hj->m_visibleItems[7],  7,  85,  160, true);
        verifyItem(hj->m_visibleItems[8],  8, 145,  160, true);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition.count(), 1);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[5], 400.);
        QCOMPARE(hj->implicitHeight(), 310.);

        model2->removeLast();

        QTRY_COMPARE(hj->m_firstVisibleIndex, 0);
        QTRY_COMPARE(hj->m_visibleItems.count(), 8);
        verifyItem(hj->m_visibleItems[0],  0,   0,   0, true);
        verifyItem(hj->m_visibleItems[1],  1, 110,   0, true);
        verifyItem(hj->m_visibleItems[2],  2, 170,   0, true);
        verifyItem(hj->m_visibleItems[3],  3, 305,   0, true);
        verifyItem(hj->m_visibleItems[4],  4, 340,   0, true);
        verifyItem(hj->m_visibleItems[5],  5, 400,   0, true);
        verifyItem(hj->m_visibleItems[6],  6,   0,  160, true);
        verifyItem(hj->m_visibleItems[7],  7,  85,  160, true);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition.count(), 1);
        QTRY_COMPARE(hj->m_lastInRowIndexPosition[5], 400.);
        QCOMPARE(hj->implicitHeight(), 310.);
    }

    void testNegativeHeight()
    {
        QQuickItemPrivate::get(hj)->anchors()->resetFill();
        hj->setHeight(-8);

        QStringList widthList;
        widthList << "100" << "50" << "125" << "25" << "50" << "50";
        model->setStringList(widthList);

        QTRY_COMPARE(hj->m_visibleItems.count(), 0);
        QTRY_COMPARE(hj->implicitHeight(), 0.);
    }

    void testNegativeDelegateCreationRange()
    {
        hj->setDisplayMarginBeginning(0);
        hj->setDisplayMarginEnd(-(hj->height() + 100));

        QStringList widthList;
        widthList << "100" << "50" << "50" << "30";
        model->setStringList(widthList);

        QTRY_COMPARE(hj->m_visibleItems.count(), 0);
        QTRY_COMPARE(hj->implicitHeight(), 0.);
    }

private:
    QQuickView *view;
    HorizontalJournal *hj;
    WidthModel *model;
};

QTEST_MAIN(HorizontalJournalTest)

#include "horizontaljournaltest.moc"

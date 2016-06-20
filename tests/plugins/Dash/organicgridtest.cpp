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

#include "organicgrid.h"

class DummyModel : public QAbstractListModel {
public:
    DummyModel() : m_count(0) {}

    int rowCount(const QModelIndex & /*parent*/) const override
    {
        return m_count;
    }

    QVariant data(const QModelIndex & /*index*/, int /*role*/) const override
    {
        return QVariant();
    }

    void setCount(int count)
    {
        beginResetModel();
        m_count = count;
        endResetModel();
    }

    void addItem()
    {
        beginInsertRows(QModelIndex(), m_count, m_count);
        m_count++;
        endInsertRows();
    }

    void removeLast()
    {
        beginRemoveRows(QModelIndex(), m_count - 1, m_count - 1);
        m_count--;
        endRemoveRows();
    }

private:
    int m_count;
};

class OrganicGridTest : public QObject
{
    Q_OBJECT

private:
    void verifyItem(const QQuickItem *item, int modelIndex, qreal x, qreal y, bool visible)
    {
        QTRY_COMPARE(item->x(), x);
        QTRY_COMPARE(item->y(), y);
        QTRY_COMPARE(QQuickItemPrivate::get(item)->culled, !visible);
        const int inModuleIndex = modelIndex % 6;
        if (inModuleIndex == 0 || inModuleIndex == 1 || inModuleIndex == 3 || inModuleIndex == 5) {
            QTRY_COMPARE(item->height(), grid->smallDelegateSize().height());
            QTRY_COMPARE(item->width(), grid->smallDelegateSize().width());
        } else {
            QTRY_COMPARE(item->height(), grid->bigDelegateSize().height());
            QTRY_COMPARE(item->width(), grid->bigDelegateSize().width());
        }
    }

    void checkInitialPositions()
    {
        QTRY_COMPARE(grid->m_visibleItems.count(), 18);
        QTRY_COMPARE(grid->m_firstVisibleIndex, 0);
        QTRY_COMPARE(grid->m_numberOfModulesPerRow, 1);
        verifyItem(grid->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(grid->m_visibleItems[ 1],  1, 100,   0, true);
        verifyItem(grid->m_visibleItems[ 2],  2,   0, 100, true);
        verifyItem(grid->m_visibleItems[ 3],  3, 190, 190, true);
        verifyItem(grid->m_visibleItems[ 4],  4, 200,   0, true);
        verifyItem(grid->m_visibleItems[ 5],  5, 290, 190, true);
        verifyItem(grid->m_visibleItems[ 6],  6,   0, 290, true);
        verifyItem(grid->m_visibleItems[ 7],  7, 100, 290, true);
        verifyItem(grid->m_visibleItems[ 8],  8,   0, 390, true);
        verifyItem(grid->m_visibleItems[ 9],  9, 190, 480, false);
        verifyItem(grid->m_visibleItems[10], 10, 200, 290, true);
        verifyItem(grid->m_visibleItems[11], 11, 290, 480, false);
        verifyItem(grid->m_visibleItems[12], 12,   0, 580, false);
        verifyItem(grid->m_visibleItems[13], 13, 100, 580, false);
        verifyItem(grid->m_visibleItems[14], 14,   0, 680, false);
        verifyItem(grid->m_visibleItems[15], 15, 190, 770, false);
        verifyItem(grid->m_visibleItems[16], 16, 200, 580, false);
        verifyItem(grid->m_visibleItems[17], 17, 290, 770, false);
        checkImplicitHeight(1150);
    }

    void checkImplicitHeight(qreal implicitHeight)
    {
        QTRY_COMPARE(grid->m_implicitHeightDirty, false);
        QCOMPARE(grid->implicitHeight(), implicitHeight);
    }

private Q_SLOTS:
    void init()
    {
        view = new QQuickView();
        view->setResizeMode(QQuickView::SizeRootObjectToView);

        model = new DummyModel();
        model->setCount(21);

        view->setSource(QUrl::fromLocalFile(DASHVIEWSTEST_FOLDER "/organicgridtest.qml"));

        view->show();
        QTest::qWaitForWindowExposed(view);
        view->resize(470, 400);

        grid = static_cast<OrganicGrid*>(view->rootObject()->findChild<QObject*>("grid"));
        grid->setModel(model);
        QTRY_COMPARE(grid->width(), 470.);

        checkInitialPositions();
    }

    void cleanup()
    {
        delete view;
        delete model;
    }

    void testInitialPosition()
    {
    }

    void testWidthResize()
    {
        view->resize(770, 400);
        QTRY_COMPARE(grid->width(), 770.);

        QTRY_COMPARE(grid->m_visibleItems.count(), 21);
        QTRY_COMPARE(grid->m_firstVisibleIndex, 0);
        QTRY_COMPARE(grid->m_numberOfModulesPerRow, 2);
        verifyItem(grid->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(grid->m_visibleItems[ 1],  1, 100,   0, true);
        verifyItem(grid->m_visibleItems[ 2],  2,   0, 100, true);
        verifyItem(grid->m_visibleItems[ 3],  3, 190, 190, true);
        verifyItem(grid->m_visibleItems[ 4],  4, 200,   0, true);
        verifyItem(grid->m_visibleItems[ 5],  5, 290, 190, true);

        verifyItem(grid->m_visibleItems[ 6],  6, 390,   0, true);
        verifyItem(grid->m_visibleItems[ 7],  7, 490,   0, true);
        verifyItem(grid->m_visibleItems[ 8],  8, 390, 100, true);
        verifyItem(grid->m_visibleItems[ 9],  9, 580, 190, true);
        verifyItem(grid->m_visibleItems[10], 10, 590,   0, true);
        verifyItem(grid->m_visibleItems[11], 11, 680, 190, true);

        verifyItem(grid->m_visibleItems[12], 12,   0, 290, true);
        verifyItem(grid->m_visibleItems[13], 13, 100, 290, true);
        verifyItem(grid->m_visibleItems[14], 14,   0, 390, true);
        verifyItem(grid->m_visibleItems[15], 15, 190, 480, false);
        verifyItem(grid->m_visibleItems[16], 16, 200, 290, true);
        verifyItem(grid->m_visibleItems[17], 17, 290, 480, false);

        verifyItem(grid->m_visibleItems[18], 18, 390, 290, true);
        verifyItem(grid->m_visibleItems[19], 19, 490, 290, true);
        verifyItem(grid->m_visibleItems[20], 20, 390, 390, true);

        checkImplicitHeight(570);

        view->resize(769, 400);

        // This is exactly the same block as the first again
        checkInitialPositions();
    }

    void testColumnSpacing()
    {
        grid->setColumnSpacing(11);

        QTRY_COMPARE(grid->m_needsRelayout, false);
        QTRY_COMPARE(grid->m_visibleItems.count(), 18);
        QTRY_COMPARE(grid->m_firstVisibleIndex, 0);
        QTRY_COMPARE(grid->m_numberOfModulesPerRow, 1);
        verifyItem(grid->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(grid->m_visibleItems[ 1],  1, 101,   0, true);
        verifyItem(grid->m_visibleItems[ 2],  2,   0, 100, true);
        verifyItem(grid->m_visibleItems[ 3],  3, 191, 190, true);
        verifyItem(grid->m_visibleItems[ 4],  4, 202,   0, true);
        verifyItem(grid->m_visibleItems[ 5],  5, 292, 190, true);
        verifyItem(grid->m_visibleItems[ 6],  6,   0, 290, true);
        verifyItem(grid->m_visibleItems[ 7],  7, 101, 290, true);
        verifyItem(grid->m_visibleItems[ 8],  8,   0, 390, true);
        verifyItem(grid->m_visibleItems[ 9],  9, 191, 480, false);
        verifyItem(grid->m_visibleItems[10], 10, 202, 290, true);
        verifyItem(grid->m_visibleItems[11], 11, 292, 480, false);
        verifyItem(grid->m_visibleItems[12], 12,   0, 580, false);
        verifyItem(grid->m_visibleItems[13], 13, 101, 580, false);
        verifyItem(grid->m_visibleItems[14], 14,   0, 680, false);
        verifyItem(grid->m_visibleItems[15], 15, 191, 770, false);
        verifyItem(grid->m_visibleItems[16], 16, 202, 580, false);
        verifyItem(grid->m_visibleItems[17], 17, 292, 770, false);
        checkImplicitHeight(1150);

        grid->setColumnSpacing(10);
        QTRY_COMPARE(grid->m_needsRelayout, false);

        // This is exactly the same block as the first again
        checkInitialPositions();
    }

    void testRowSpacing()
    {
        grid->setRowSpacing(11);

        QTRY_COMPARE(grid->m_needsRelayout, false);
        QTRY_COMPARE(grid->m_visibleItems.count(), 18);
        QTRY_COMPARE(grid->m_firstVisibleIndex, 0);
        QTRY_COMPARE(grid->m_numberOfModulesPerRow, 1);
        verifyItem(grid->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(grid->m_visibleItems[ 1],  1, 100,   0, true);
        verifyItem(grid->m_visibleItems[ 2],  2,   0, 101, true);
        verifyItem(grid->m_visibleItems[ 3],  3, 190, 191, true);
        verifyItem(grid->m_visibleItems[ 4],  4, 200,   0, true);
        verifyItem(grid->m_visibleItems[ 5],  5, 290, 191, true);
        verifyItem(grid->m_visibleItems[ 6],  6,   0, 292, true);
        verifyItem(grid->m_visibleItems[ 7],  7, 100, 292, true);
        verifyItem(grid->m_visibleItems[ 8],  8,   0, 393, true);
        verifyItem(grid->m_visibleItems[ 9],  9, 190, 483, false);
        verifyItem(grid->m_visibleItems[10], 10, 200, 292, true);
        verifyItem(grid->m_visibleItems[11], 11, 290, 483, false);
        verifyItem(grid->m_visibleItems[12], 12,   0, 584, false);
        verifyItem(grid->m_visibleItems[13], 13, 100, 584, false);
        verifyItem(grid->m_visibleItems[14], 14,   0, 685, false);
        verifyItem(grid->m_visibleItems[15], 15, 190, 775, false);
        verifyItem(grid->m_visibleItems[16], 16, 200, 584, false);
        verifyItem(grid->m_visibleItems[17], 17, 290, 775, false);
        checkImplicitHeight(1157);

        grid->setRowSpacing(10);
        QTRY_COMPARE(grid->m_needsRelayout, false);

        // This is exactly the same block as the first again
        checkInitialPositions();
    }

    void testDelegateSizeChange()
    {
        grid->setSmallDelegateSize(QSizeF(30, 30));
        grid->setBigDelegateSize(QSizeF(50, 50));
        QTRY_COMPARE(grid->m_firstVisibleIndex, 0);
        QTRY_COMPARE(grid->m_visibleItems.count(), 21);
        verifyItem(grid->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(grid->m_visibleItems[ 1],  1,  40,   0, true);
        verifyItem(grid->m_visibleItems[ 2],  2,   0,  40, true);
        verifyItem(grid->m_visibleItems[ 3],  3,  60,  60, true);
        verifyItem(grid->m_visibleItems[ 4],  4,  80,   0, true);
        verifyItem(grid->m_visibleItems[ 5],  5, 100,  60, true);

        verifyItem(grid->m_visibleItems[ 6],  6, 140,   0, true);
        verifyItem(grid->m_visibleItems[ 7],  7, 180,   0, true);
        verifyItem(grid->m_visibleItems[ 8],  8, 140,  40, true);
        verifyItem(grid->m_visibleItems[ 9],  9, 200,  60, true);
        verifyItem(grid->m_visibleItems[10], 10, 220,   0, true);
        verifyItem(grid->m_visibleItems[11], 11, 240,  60, true);

        verifyItem(grid->m_visibleItems[12], 12, 280,   0, true);
        verifyItem(grid->m_visibleItems[13], 13, 320,   0, true);
        verifyItem(grid->m_visibleItems[14], 14, 280,  40, true);
        verifyItem(grid->m_visibleItems[15], 15, 340,  60, true);
        verifyItem(grid->m_visibleItems[16], 16, 360,   0, true);
        verifyItem(grid->m_visibleItems[17], 17, 380,  60, true);

        verifyItem(grid->m_visibleItems[18], 18,   0, 100, true);
        verifyItem(grid->m_visibleItems[19], 19,  40, 100, true);
        verifyItem(grid->m_visibleItems[20], 20,   0, 140, true);
        checkImplicitHeight(190);

        grid->setSmallDelegateSize(QSizeF(90, 90));
        grid->setBigDelegateSize(QSizeF(180, 180));

        // This is exactly the same block as the first again
        checkInitialPositions();
    }

    void testChangeModel()
    {
        DummyModel *model2 = new DummyModel();
        model2->setCount(6);
        grid->setModel(model2);
        delete model;
        model = model2;

        QTRY_COMPARE(grid->m_firstVisibleIndex, 0);
        QTRY_COMPARE(grid->m_visibleItems.count(), 6);
        verifyItem(grid->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(grid->m_visibleItems[ 1],  1, 100,   0, true);
        verifyItem(grid->m_visibleItems[ 2],  2,   0, 100, true);
        verifyItem(grid->m_visibleItems[ 3],  3, 190, 190, true);
        verifyItem(grid->m_visibleItems[ 4],  4, 200,   0, true);
        verifyItem(grid->m_visibleItems[ 5],  5, 290, 190, true);
        checkImplicitHeight(280);
    }

    void testModelReset()
    {
        model->setCount(6);

        QTRY_COMPARE(grid->m_firstVisibleIndex, 0);
        QTRY_COMPARE(grid->m_visibleItems.count(), 6);
        verifyItem(grid->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(grid->m_visibleItems[ 1],  1, 100,   0, true);
        verifyItem(grid->m_visibleItems[ 2],  2,   0, 100, true);
        verifyItem(grid->m_visibleItems[ 3],  3, 190, 190, true);
        verifyItem(grid->m_visibleItems[ 4],  4, 200,   0, true);
        verifyItem(grid->m_visibleItems[ 5],  5, 290, 190, true);
        checkImplicitHeight(280);
    }

    void testModelRemoveLastNonVisible()
    {
        model->removeLast();

        // This is the same than checkInitialPositions but
        // with a different implicitHeight since there's an item less
        // in the model
        QTRY_COMPARE(grid->m_visibleItems.count(), 18);
        QTRY_COMPARE(grid->m_firstVisibleIndex, 0);
        QTRY_COMPARE(grid->m_numberOfModulesPerRow, 1);
        verifyItem(grid->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(grid->m_visibleItems[ 1],  1, 100,   0, true);
        verifyItem(grid->m_visibleItems[ 2],  2,   0, 100, true);
        verifyItem(grid->m_visibleItems[ 3],  3, 190, 190, true);
        verifyItem(grid->m_visibleItems[ 4],  4, 200,   0, true);
        verifyItem(grid->m_visibleItems[ 5],  5, 290, 190, true);
        verifyItem(grid->m_visibleItems[ 6],  6,   0, 290, true);
        verifyItem(grid->m_visibleItems[ 7],  7, 100, 290, true);
        verifyItem(grid->m_visibleItems[ 8],  8,   0, 390, true);
        verifyItem(grid->m_visibleItems[ 9],  9, 190, 480, false);
        verifyItem(grid->m_visibleItems[10], 10, 200, 290, true);
        verifyItem(grid->m_visibleItems[11], 11, 290, 480, false);
        verifyItem(grid->m_visibleItems[12], 12,   0, 580, false);
        verifyItem(grid->m_visibleItems[13], 13, 100, 580, false);
        verifyItem(grid->m_visibleItems[14], 14,   0, 680, false);
        verifyItem(grid->m_visibleItems[15], 15, 190, 770, false);
        verifyItem(grid->m_visibleItems[16], 16, 200, 580, false);
        verifyItem(grid->m_visibleItems[17], 17, 290, 770, false);
        checkImplicitHeight(960);

        model->removeLast();

        // Removing this one didn't cause any change since it only
        // was the second item of a non visible 6-module
        QTRY_COMPARE(grid->m_visibleItems.count(), 18);
        QTRY_COMPARE(grid->m_firstVisibleIndex, 0);
        QTRY_COMPARE(grid->m_numberOfModulesPerRow, 1);
        verifyItem(grid->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(grid->m_visibleItems[ 1],  1, 100,   0, true);
        verifyItem(grid->m_visibleItems[ 2],  2,   0, 100, true);
        verifyItem(grid->m_visibleItems[ 3],  3, 190, 190, true);
        verifyItem(grid->m_visibleItems[ 4],  4, 200,   0, true);
        verifyItem(grid->m_visibleItems[ 5],  5, 290, 190, true);
        verifyItem(grid->m_visibleItems[ 6],  6,   0, 290, true);
        verifyItem(grid->m_visibleItems[ 7],  7, 100, 290, true);
        verifyItem(grid->m_visibleItems[ 8],  8,   0, 390, true);
        verifyItem(grid->m_visibleItems[ 9],  9, 190, 480, false);
        verifyItem(grid->m_visibleItems[10], 10, 200, 290, true);
        verifyItem(grid->m_visibleItems[11], 11, 290, 480, false);
        verifyItem(grid->m_visibleItems[12], 12,   0, 580, false);
        verifyItem(grid->m_visibleItems[13], 13, 100, 580, false);
        verifyItem(grid->m_visibleItems[14], 14,   0, 680, false);
        verifyItem(grid->m_visibleItems[15], 15, 190, 770, false);
        verifyItem(grid->m_visibleItems[16], 16, 200, 580, false);
        verifyItem(grid->m_visibleItems[17], 17, 290, 770, false);
        checkImplicitHeight(960);

        model->removeLast();

        // Removing this one removes the first of a 6-module so
        // it does change height again
        QTRY_COMPARE(grid->m_visibleItems.count(), 18);
        QTRY_COMPARE(grid->m_firstVisibleIndex, 0);
        QTRY_COMPARE(grid->m_numberOfModulesPerRow, 1);
        verifyItem(grid->m_visibleItems[ 0],  0,   0,   0, true);
        verifyItem(grid->m_visibleItems[ 1],  1, 100,   0, true);
        verifyItem(grid->m_visibleItems[ 2],  2,   0, 100, true);
        verifyItem(grid->m_visibleItems[ 3],  3, 190, 190, true);
        verifyItem(grid->m_visibleItems[ 4],  4, 200,   0, true);
        verifyItem(grid->m_visibleItems[ 5],  5, 290, 190, true);
        verifyItem(grid->m_visibleItems[ 6],  6,   0, 290, true);
        verifyItem(grid->m_visibleItems[ 7],  7, 100, 290, true);
        verifyItem(grid->m_visibleItems[ 8],  8,   0, 390, true);
        verifyItem(grid->m_visibleItems[ 9],  9, 190, 480, false);
        verifyItem(grid->m_visibleItems[10], 10, 200, 290, true);
        verifyItem(grid->m_visibleItems[11], 11, 290, 480, false);
        verifyItem(grid->m_visibleItems[12], 12,   0, 580, false);
        verifyItem(grid->m_visibleItems[13], 13, 100, 580, false);
        verifyItem(grid->m_visibleItems[14], 14,   0, 680, false);
        verifyItem(grid->m_visibleItems[15], 15, 190, 770, false);
        verifyItem(grid->m_visibleItems[16], 16, 200, 580, false);
        verifyItem(grid->m_visibleItems[17], 17, 290, 770, false);
        checkImplicitHeight(860);

    }

    void testModelAppendRemoveLast()
    {
        DummyModel *model2 = new DummyModel();
        model2->setCount(6);
        grid->setModel(model2);
        delete model;
        model = model2;

        QTRY_COMPARE(grid->m_firstVisibleIndex, 0);
        QTRY_COMPARE(grid->m_visibleItems.count(), 6);
        verifyItem(grid->m_visibleItems[0],  0,   0,   0, true);
        verifyItem(grid->m_visibleItems[1],  1, 100,   0, true);
        verifyItem(grid->m_visibleItems[2],  2,   0, 100, true);
        verifyItem(grid->m_visibleItems[3],  3, 190, 190, true);
        verifyItem(grid->m_visibleItems[4],  4, 200,   0, true);
        verifyItem(grid->m_visibleItems[5],  5, 290, 190, true);
        checkImplicitHeight(280);

        model2->addItem();

        QTRY_COMPARE(grid->m_firstVisibleIndex, 0);
        QTRY_COMPARE(grid->m_visibleItems.count(), 7);
        verifyItem(grid->m_visibleItems[0],  0,   0,   0, true);
        verifyItem(grid->m_visibleItems[1],  1, 100,   0, true);
        verifyItem(grid->m_visibleItems[2],  2,   0, 100, true);
        verifyItem(grid->m_visibleItems[3],  3, 190, 190, true);
        verifyItem(grid->m_visibleItems[4],  4, 200,   0, true);
        verifyItem(grid->m_visibleItems[5],  5, 290, 190, true);
        verifyItem(grid->m_visibleItems[6],  6,   0, 290, true);
        checkImplicitHeight(380);

        model2->addItem();
        model2->addItem();

        QTRY_COMPARE(grid->m_firstVisibleIndex, 0);
        QTRY_COMPARE(grid->m_visibleItems.count(), 9);
        verifyItem(grid->m_visibleItems[0],  0,   0,   0, true);
        verifyItem(grid->m_visibleItems[1],  1, 100,   0, true);
        verifyItem(grid->m_visibleItems[2],  2,   0, 100, true);
        verifyItem(grid->m_visibleItems[3],  3, 190, 190, true);
        verifyItem(grid->m_visibleItems[4],  4, 200,   0, true);
        verifyItem(grid->m_visibleItems[5],  5, 290, 190, true);
        verifyItem(grid->m_visibleItems[6],  6,   0, 290, true);
        verifyItem(grid->m_visibleItems[7],  7, 100, 290, true);
        verifyItem(grid->m_visibleItems[8],  8,   0, 390, true);
        checkImplicitHeight(570);

        model2->removeLast();

        QTRY_COMPARE(grid->m_firstVisibleIndex, 0);
        QTRY_COMPARE(grid->m_visibleItems.count(), 8);
        verifyItem(grid->m_visibleItems[0],  0,   0,   0, true);
        verifyItem(grid->m_visibleItems[1],  1, 100,   0, true);
        verifyItem(grid->m_visibleItems[2],  2,   0, 100, true);
        verifyItem(grid->m_visibleItems[3],  3, 190, 190, true);
        verifyItem(grid->m_visibleItems[4],  4, 200,   0, true);
        verifyItem(grid->m_visibleItems[5],  5, 290, 190, true);
        verifyItem(grid->m_visibleItems[6],  6,   0, 290, true);
        verifyItem(grid->m_visibleItems[7],  7, 100, 290, true);
        checkImplicitHeight(380);
    }

    void testDelegateCreationRanges()
    {
        grid->setSmallDelegateSize(QSizeF(30, 30));
        grid->setBigDelegateSize(QSizeF(50, 50));
        model->setCount(400);
        checkImplicitHeight(2290);

        view->resize(470, 700);
        QTRY_COMPARE(grid->height(), 700.);
        checkImplicitHeight(2290);
        QTRY_COMPARE(grid->m_firstVisibleIndex, 0);
        QTRY_COMPARE(grid->m_visibleItems.count(), 198);

        grid->setDisplayMarginBeginning(-300);
        grid->setDisplayMarginEnd(-(grid->height() - 400));
        checkImplicitHeight(2290);

        QTRY_COMPARE(grid->m_firstVisibleIndex, 36);
        QTRY_COMPARE(grid->m_visibleItems.count(), 54);
        checkImplicitHeight(2290);

        view->resize(470, 470);

        grid->setSmallDelegateSize(QSizeF(90, 90));
        grid->setBigDelegateSize(QSizeF(180, 180));

        model->setCount(21);

        QTRY_COMPARE(grid->m_visibleItems.count(), 0);

        grid->setDisplayMarginBeginning(0);
        grid->setDisplayMarginEnd(0);

        // This is exactly the same block as the first again
        checkInitialPositions();
    }

private:
    QQuickView *view;
    OrganicGrid *grid;
    DummyModel *model;
};

QTEST_MAIN(OrganicGridTest)

#include "organicgridtest.moc"

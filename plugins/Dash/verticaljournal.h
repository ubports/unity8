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

#ifndef VERTICALJOURNAL_H
#define VERTICALJOURNAL_H

#include "abstractdashview.h"

 /** A vertical journal is a view that creates delegates
   * based on a model and layouts them in columns following
   * a top-left most position rule.
   *
   * The number of columns is calculated using the width of
   * the view itself, the columnWidth (i.e. the width of each individual delegate)
   * and the columnSpacing between columns.
   *
   * All delegates are forced to columnWidth if they don't have it.
   *
   * The first nColumns items are layouted at row 0 from column 0
   * to column nColumns-1 in order. After that every new item
   * is positioned in the column which provides the free topmost
   * position as possible. If more than one column tie in providing
   * the topmost free position the leftmost column will be used.
   *
   * Example:
   *
   * +-----+ +-----+ +-----+
   * |     | |  2  | |     |
   * |     | |     | |     |
   * |  1  | +-----+ |  3  |
   * |     | +-----+ |     |
   * |     | |     | +-----+
   * +-----+ |  4  | +-----+
   * +-----+ |     | |  5  |
   * |  6  | +-----+ |     |
   * |     |         +-----+
   * +-----+
   *
   */

class VerticalJournal : public AbstractDashView
{
    Q_OBJECT

    Q_PROPERTY(qreal columnWidth READ columnWidth WRITE setColumnWidth NOTIFY columnWidthChanged)

friend class VerticalJournalTest;

public:
    VerticalJournal();

    qreal columnWidth() const;
    void setColumnWidth(qreal columnWidth);

protected:
    void itemGeometryChanged(QQuickItem *item, const QRectF &newGeometry, const QRectF &oldGeometry) override;

Q_SIGNALS:
    void columnWidthChanged();

private:
    class ViewItem
    {
        public:
            ViewItem(QQuickItem *item, int modelIndex) : m_item(item), m_modelIndex(modelIndex) {}
            qreal x() const { return m_item->x(); }
            qreal y() const { return m_item->y(); }
            qreal height() const { return m_item->height(); }
            bool operator<(const ViewItem v) const { return m_modelIndex < v.m_modelIndex; }

            QQuickItem *m_item;
            int m_modelIndex;
    };

    void findBottomModelIndexToAdd(int *modelIndex, qreal *yPos) override;
    void findTopModelIndexToAdd(int *modelIndex, qreal *yPos) override;
    bool removeNonVisibleItems(qreal bufferFromY, qreal bufferToY) override;
    void addItemToView(int modelIndex, QQuickItem *item) override;
    void cleanupExistingItems() override;
    void calculateImplicitHeight() override;
    void doRelayout() override;
    void updateItemCulling(qreal visibleFromY, qreal visibleToY) override;
    void processModelRemoves(const QVector<QQmlChangeSet::Change> &removes) override;

    QVector<QList<ViewItem>> m_columnVisibleItems;
    QHash<int, int> m_indexColumnMap;
    int m_columnWidth;
};

#endif

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

#ifndef HORIZONTALJOURNAL_H
#define HORIZONTALJOURNAL_H

#include "abstractdashview.h"

 /** A horizontal journal is a view that creates delegates
   * based on a model and layouts them one after the other
   * in the same row until there is no more free space for the next item
   * and so that item is layouted in the next row
   *
   * All delegates are forced to rowHeight if they don't have it.
   */
 class HorizontalJournal : public AbstractDashView
{
    Q_OBJECT

    Q_PROPERTY(qreal rowHeight READ rowHeight WRITE setRowHeight NOTIFY rowHeightChanged)

friend class HorizontalJournalTest;

public:
    HorizontalJournal();

    qreal rowHeight() const;
    void setRowHeight(qreal rowHeight);

Q_SIGNALS:
    void rowHeightChanged();

private:
    void findBottomModelIndexToAdd(int *modelIndex, qreal *yPos) override;
    void findTopModelIndexToAdd(int *modelIndex, qreal *yPos) override;
    bool removeNonVisibleItems(qreal bufferFromY, qreal bufferToY) override;
    void addItemToView(int modelIndex, QQuickItem *item) override;
    void cleanupExistingItems() override;
    void calculateImplicitHeight() override;
    void doRelayout() override;
    void updateItemCulling(qreal visibleFromY, qreal visibleToY) override;
    void processModelRemoves(const QVector<QQmlChangeSet::Change> &removes) override;

    int m_firstVisibleIndex;
    QList<QQuickItem*> m_visibleItems;
    QMap<int, double> m_lastInRowIndexPosition;
    int m_rowHeight;
};

#endif

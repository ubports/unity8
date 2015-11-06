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

#ifndef ORGANICGRID_H
#define ORGANICGRID_H

#include "abstractdashview.h"

 /** An Organic Grid is is a view that creates delegates
   * based on a model and layouts them in groups of six items (called module).
   *
   * In each module there are 4 items that are forced to the small delegate size
   * and two that are forced to the big delegate size.
   *
   * Example:
   *
   * +---+ +---+ +-----+
   * | 1 | | 2 | |     |
   * +---+ +---+ |  5  |
   * +-----+     |     |
   * |     |     +-----+
   * |  3  | +---+ +---+
   * |     | | 4 | | 6 |
   * +-----+ +---+ +---+
   *
   * Modules are positioned one after the other in a grid like fashion, i.e.
   *
   * +---+ +---+
   * | 1 | | 2 |
   * +---+ +---+
   * +---+ +---+
   * | 3 | | 4 |
   * +---+ +---+
   */

class OrganicGrid : public AbstractDashView
{
    Q_OBJECT

    Q_PROPERTY(QSizeF smallDelegateSize READ smallDelegateSize WRITE setSmallDelegateSize NOTIFY smallDelegateSizeChanged)
    Q_PROPERTY(QSizeF bigDelegateSize READ bigDelegateSize WRITE setBigDelegateSize NOTIFY bigDelegateSizeChanged)

friend class OrganicGridTest;

public:
    OrganicGrid();

    QSizeF smallDelegateSize() const;
    void setSmallDelegateSize(const QSizeF &size);

    QSizeF bigDelegateSize() const;
    void setBigDelegateSize(const QSizeF &size);

Q_SIGNALS:
    void smallDelegateSizeChanged();
    void bigDelegateSizeChanged();
private:
    QPointF positionForIndex(int modelIndex) const;
    QSizeF sizeForIndex(int modelIndex) const;

    void findBottomModelIndexToAdd(int *modelIndex, qreal *yPos) override;
    void findTopModelIndexToAdd(int *modelIndex, qreal *yPos) override;
    void addItemToView(int modelIndex, QQuickItem *item) override;
    bool removeNonVisibleItems(qreal bufferFromY, qreal bufferToY) override;
    void cleanupExistingItems() override;
    void doRelayout() override;
    void updateItemCulling(qreal visibleFromY, qreal visibleToY) override;
    void calculateImplicitHeight() override;
    void processModelRemoves(const QVector<QQmlChangeSet::Change> &removes) override;

    QSizeF m_smallDelegateSize;
    QSizeF m_bigDelegateSize;
    int m_firstVisibleIndex;
    int m_numberOfModulesPerRow;
    QList<QQuickItem*> m_visibleItems;
};

#endif

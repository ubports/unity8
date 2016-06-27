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

#include "organicgrid.h"

#include <private/qquickitem_p.h>

OrganicGrid::OrganicGrid()
 : m_firstVisibleIndex(-1)
 , m_numberOfModulesPerRow(-1)
{
}

QSizeF OrganicGrid::smallDelegateSize() const
{
    return m_smallDelegateSize;
}

void OrganicGrid::setSmallDelegateSize(const QSizeF size)
{
    if (m_smallDelegateSize != size) {
        m_smallDelegateSize = size;
        Q_EMIT smallDelegateSizeChanged();

        if (isComponentComplete()) {
            relayout();
        }
    }
}

QSizeF OrganicGrid::bigDelegateSize() const
{
    return m_bigDelegateSize;
}

void OrganicGrid::setBigDelegateSize(const QSizeF size)
{
    if (m_bigDelegateSize != size) {
        m_bigDelegateSize = size;
        Q_EMIT bigDelegateSizeChanged();

        if (isComponentComplete()) {
            relayout();
        }
    }
}

QPointF OrganicGrid::positionForIndex(int modelIndex) const
{
    const qreal moduleHeight = m_smallDelegateSize.height() + rowSpacing() + m_bigDelegateSize.height();
    const qreal moduleWidth = m_smallDelegateSize.width() * 2 + columnSpacing() * 2 + m_bigDelegateSize.width();
    const int itemsPerRow = m_numberOfModulesPerRow * 6;
    const int rowIndex = floor(modelIndex / itemsPerRow);
    const int columnIndex = floor((modelIndex - rowIndex * itemsPerRow) / 6);

    qreal yPos = (moduleHeight + rowSpacing()) * rowIndex;
    const int moduleIndex = modelIndex % 6;
    if (moduleIndex == 2) {
        yPos += m_smallDelegateSize.height() + rowSpacing();
    } else if (moduleIndex == 3 || moduleIndex == 5) {
        yPos += m_bigDelegateSize.height() + rowSpacing();
    }

    qreal xPos = (moduleWidth + columnSpacing()) * columnIndex;
    if (moduleIndex == 1) {
        xPos += m_smallDelegateSize.width() + columnSpacing();
    } else if (moduleIndex == 3) {
        xPos += m_bigDelegateSize.width() + columnSpacing();
    } else if (moduleIndex == 4) {
        xPos += (m_smallDelegateSize.width() + columnSpacing()) * 2;
    } else if (moduleIndex == 5) {
        xPos += m_bigDelegateSize.width() + m_smallDelegateSize.width() + columnSpacing() * 2;
    }

    return QPointF(xPos, yPos);
}

QSizeF OrganicGrid::sizeForIndex(int modelIndex) const
{
    const int moduleIndex = modelIndex % 6;
    if (moduleIndex == 0 || moduleIndex == 1 || moduleIndex == 3 || moduleIndex == 5) {
        return m_smallDelegateSize;
    } else {
        return m_bigDelegateSize;
    }
}

void OrganicGrid::findBottomModelIndexToAdd(int *modelIndex, qreal *yPos)
{
    if (m_visibleItems.isEmpty()) {
        *modelIndex = 0;
        *yPos = 0;
    } else {
        *modelIndex = m_firstVisibleIndex + m_visibleItems.count();
        // We create stuff in a 6-module basis, so always return back
        // the y position of the first item
        const int firstModuleIndex = ((*modelIndex) / 6) * 6;
        *yPos = positionForIndex(firstModuleIndex).y();
    }
}

void OrganicGrid::findTopModelIndexToAdd(int *modelIndex, qreal *yPos)
{
    if (m_visibleItems.isEmpty()) {
        *modelIndex = 0;
        *yPos = 0;
    } else {
        *modelIndex = m_firstVisibleIndex - 1;
        // We create stuff in a 6-module basis, so always return back
        // the y position of the last item bottom
        const int lastModuleIndex = ((*modelIndex) / 6) * 6 + 5;
        *yPos = positionForIndex(lastModuleIndex).y();
        *yPos += sizeForIndex(lastModuleIndex).height();
    }
}

void OrganicGrid::addItemToView(int modelIndex, QQuickItem *item)
{
    // modelIndex has to be either m_firstVisibleIndex - 1 or m_firstVisibleIndex + m_visibleItems.count() or the first
    if (modelIndex == m_firstVisibleIndex + m_visibleItems.count()) {
        m_visibleItems << item;
    } else if (modelIndex == m_firstVisibleIndex - 1) {
        m_firstVisibleIndex = modelIndex;
        m_visibleItems.prepend(item);
    } else if (modelIndex == 0) {
        m_firstVisibleIndex = 0;
        m_visibleItems << item;
    } else {
        qWarning() << "OrganicGrid::addItemToView - Got unexpected modelIndex"
                    << modelIndex << m_firstVisibleIndex << m_visibleItems.count();
        return;
    }

    const QPointF pos = positionForIndex(modelIndex);
    item->setPosition(pos);

    item->setSize(sizeForIndex(modelIndex));
}

bool OrganicGrid::removeNonVisibleItems(qreal bufferFromY, qreal bufferToY)
{
    bool changed = false;

    // As adding, we also remove in a 6-module basis
    int lastModuleIndex = (m_firstVisibleIndex / 6) * 6 + 5;
    bool removeIndex = positionForIndex(lastModuleIndex).y() + sizeForIndex(lastModuleIndex).height() < bufferFromY;
    while (removeIndex && !m_visibleItems.isEmpty()) {
        releaseItem(m_visibleItems.takeFirst());
        changed = true;
        m_firstVisibleIndex++;

        lastModuleIndex = (m_firstVisibleIndex / 6) * 6 + 5;
        removeIndex = positionForIndex(lastModuleIndex).y() + sizeForIndex(lastModuleIndex).height() < bufferFromY;
    }

    int firstModuleIndex = ((m_firstVisibleIndex + m_visibleItems.count() - 1) / 6) * 6;
    removeIndex = positionForIndex(firstModuleIndex).y() > bufferToY;
    while (removeIndex && !m_visibleItems.isEmpty()) {
        releaseItem(m_visibleItems.takeLast());
        changed = true;

        firstModuleIndex = ((m_firstVisibleIndex + m_visibleItems.count() - 1) / 6) * 6;
        removeIndex = positionForIndex(firstModuleIndex).y() > bufferToY;
    }

    if (m_visibleItems.isEmpty()) {
        m_firstVisibleIndex = -1;
    }

    return changed;
}

void OrganicGrid::cleanupExistingItems()
{
    Q_FOREACH(QQuickItem *item, m_visibleItems)
        releaseItem(item);
    m_visibleItems.clear();
    m_firstVisibleIndex = -1;
    setImplicitHeightDirty();
}

void OrganicGrid::doRelayout()
{
    const qreal moduleWidth = m_smallDelegateSize.width() * 2 + columnSpacing() * 2 + m_bigDelegateSize.width();
    m_numberOfModulesPerRow = floor((width() + columnSpacing()) / (moduleWidth + columnSpacing()));
    m_numberOfModulesPerRow = qMax(1, m_numberOfModulesPerRow);

    int i = m_firstVisibleIndex;
    const QList<QQuickItem*> allItems = m_visibleItems;
    m_visibleItems.clear();
    Q_FOREACH(QQuickItem *item, allItems) {
        addItemToView(i, item);
        ++i;
    }
}

void OrganicGrid::updateItemCulling(qreal visibleFromY, qreal visibleToY)
{
    Q_FOREACH(QQuickItem *item, m_visibleItems) {
        QQuickItemPrivate::get(item)->setCulled(item->y() + item->height() <= visibleFromY || item->y() >= visibleToY);
    }
}

void OrganicGrid::calculateImplicitHeight()
{
    const qreal moduleHeight = m_smallDelegateSize.height() + rowSpacing() + m_bigDelegateSize.height();
    const int itemCount = !model() ? 0 : model()->rowCount();
    const int itemsPerRow = m_numberOfModulesPerRow * 6;
    const int fullRows = floor(itemCount / itemsPerRow);
    const qreal fullRowsHeight = fullRows == 0 ? 0 : fullRows * moduleHeight + rowSpacing() * (fullRows - 1);

    const int remainingItems = itemCount - fullRows * itemsPerRow;
    if (remainingItems == 0) {
        setImplicitHeight(fullRowsHeight);
    } else if (remainingItems <= 2) {
        setImplicitHeight(fullRowsHeight + m_smallDelegateSize.height() + rowSpacing());
    } else {
        setImplicitHeight(fullRowsHeight + rowSpacing() + moduleHeight);
    }
}

void OrganicGrid::processModelRemoves(const QVector<QQmlChangeSet::Change> &removes)
{
    Q_FOREACH(const QQmlChangeSet::Change remove, removes) {
        for (int i = remove.count - 1; i >= 0; --i) {
            const int indexToRemove = remove.index + i;
            // We only support removing from the end
            const int lastIndex = m_firstVisibleIndex + m_visibleItems.count() - 1;
            if (indexToRemove == lastIndex) {
                releaseItem(m_visibleItems.takeLast());
            } else {
                if (indexToRemove < lastIndex) {
                    qDebug() << "OrganicGrid only supports removal from the end of the model, resetting instead";
                    cleanupExistingItems();
                    break;
                }
            }
        }
    }
    if (m_visibleItems.isEmpty()) {
        m_firstVisibleIndex = -1;
    }
    setImplicitHeightDirty();
}

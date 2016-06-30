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

/*
 * The implementation is centered around m_visibleItems
 * that a list for each of the items in the view.
 * m_firstVisibleIndex is the index of the first item in m_visibleItems
 * m_lastInRowIndexPosition is a map that contains the x position
 * of items that are the last ones of a row so we can reconstruct the rows
 * when building back
 */

#include "horizontaljournal.h"

#include <qqmlengine.h>
#include <qqmlinfo.h>
#include <private/qqmldelegatemodel_p.h>
#include <private/qquickitem_p.h>

HorizontalJournal::HorizontalJournal()
 : m_firstVisibleIndex(-1)
 , m_rowHeight(0)
{
}

qreal HorizontalJournal::rowHeight() const
{
    return m_rowHeight;
}

void HorizontalJournal::setRowHeight(qreal rowHeight)
{
    if (rowHeight != m_rowHeight) {
        m_rowHeight = rowHeight;
        Q_EMIT rowHeightChanged();

        if (isComponentComplete()) {
            Q_FOREACH(QQuickItem *item, m_visibleItems) {
                item->setHeight(rowHeight);
            }
            relayout();
        }
    }
}

void HorizontalJournal::findBottomModelIndexToAdd(int *modelIndex, qreal *yPos)
{
    if (m_visibleItems.isEmpty()) {
        *modelIndex = 0;
        *yPos = 0;
    } else {
        *modelIndex = m_firstVisibleIndex + m_visibleItems.count();
        if (m_lastInRowIndexPosition.contains(*modelIndex - 1)) {
            *yPos = m_visibleItems.last()->y() + m_rowHeight + rowSpacing();
        } else {
            *yPos = m_visibleItems.last()->y();
        }
    }
}

void HorizontalJournal::findTopModelIndexToAdd(int *modelIndex, qreal *yPos)
{
    if (m_visibleItems.isEmpty()) {
        *modelIndex = -1;
        *yPos = INT_MIN;
    } else {
        *modelIndex = m_firstVisibleIndex - 1;
        if (m_lastInRowIndexPosition.contains(*modelIndex)) {
            *yPos = m_visibleItems.first()->y() - rowSpacing() - m_rowHeight;
        } else {
            *yPos = m_visibleItems.first()->y();
        }
    }
}

bool HorizontalJournal::removeNonVisibleItems(qreal bufferFromY, qreal bufferToY)
{
    bool changed = false;

    while (!m_visibleItems.isEmpty() && m_visibleItems.first()->y() + m_rowHeight < bufferFromY) {
        releaseItem(m_visibleItems.takeFirst());
        changed = true;
        m_firstVisibleIndex++;
    }

    while (!m_visibleItems.isEmpty() && m_visibleItems.last()->y() > bufferToY) {
        releaseItem(m_visibleItems.takeLast());
        changed = true;
        m_lastInRowIndexPosition.remove(m_firstVisibleIndex + m_visibleItems.count());
    }

    if (m_visibleItems.isEmpty()) {
        m_firstVisibleIndex = -1;
    }

    return changed;
}

void HorizontalJournal::addItemToView(int modelIndex, QQuickItem *item)
{
    if (item->height() != m_rowHeight) {
        qWarning() << "Item" << modelIndex << "height is not the one that the rowHeight mandates, resetting it";
        item->setHeight(m_rowHeight);
    }

    if (m_visibleItems.isEmpty()) {
        Q_ASSERT(modelIndex == 0);
        item->setY(0);
        item->setX(0);
        m_visibleItems << item;
        m_firstVisibleIndex = 0;
    } else {
        // modelIndex has to be either m_firstVisibleIndex - 1 or m_firstVisibleIndex + m_visibleItems.count()
        if (modelIndex == m_firstVisibleIndex + m_visibleItems.count()) {
            QQuickItem *lastItem = m_visibleItems.last();
            if (lastItem->x() + lastItem->width() + columnSpacing() + item->width() <= width()) {
                // Fits in the row
                item->setY(lastItem->y());
                item->setX(lastItem->x() + lastItem->width() + columnSpacing());
            } else {
                // Starts a new row
                item->setY(lastItem->y() + m_rowHeight + rowSpacing());
                item->setX(0);
                m_lastInRowIndexPosition[modelIndex - 1] = lastItem->x();
            }
            m_visibleItems << item;
        } else if (modelIndex == m_firstVisibleIndex - 1) {
            QQuickItem *firstItem = m_visibleItems.first();
            if (m_lastInRowIndexPosition.contains(modelIndex)) {
                // It is the last item of its row, so start a new one since we're going back
                item->setY(firstItem->y() - rowSpacing() - m_rowHeight);
                item->setX(m_lastInRowIndexPosition[modelIndex]);
            } else {
                item->setY(firstItem->y());
                item->setX(firstItem->x() - columnSpacing() - item->width());
            }
            m_firstVisibleIndex = modelIndex;
            m_visibleItems.prepend(item);
        } else {
            qWarning() << "HorizontalJournal::addItemToView - Got unexpected modelIndex"
                       << modelIndex << m_firstVisibleIndex << m_visibleItems.count();
        }
    }
}

void HorizontalJournal::cleanupExistingItems()
{
    // Cleanup the existing items
    Q_FOREACH(QQuickItem *item, m_visibleItems)
        releaseItem(item);
    m_visibleItems.clear();
    m_lastInRowIndexPosition.clear();
    m_firstVisibleIndex = -1;
    setImplicitHeightDirty();
}

void HorizontalJournal::calculateImplicitHeight()
{
    if (m_firstVisibleIndex >= 0) {
        const int nIndexes = m_firstVisibleIndex + m_visibleItems.count();
        const double bottomMostY = m_visibleItems.last()->y() + m_rowHeight;
        const double averageHeight = bottomMostY / nIndexes;
        setImplicitHeight(bottomMostY + averageHeight * (model()->rowCount() - nIndexes));
    } else {
        setImplicitHeight(0);
    }
}

void HorizontalJournal::processModelRemoves(const QVector<QQmlChangeSet::Change> &removes)
{
    Q_FOREACH(const QQmlChangeSet::Change remove, removes) {
        for (int i = remove.count - 1; i >= 0; --i) {
            const int indexToRemove = remove.index + i;
            // We only support removing from the end so
            // any of the last items of a column has to be indexToRemove
            const int lastIndex = m_firstVisibleIndex + m_visibleItems.count() - 1;
            if (indexToRemove == lastIndex) {
                releaseItem(m_visibleItems.takeLast());
                m_lastInRowIndexPosition.remove(indexToRemove);
            } else {
                if (indexToRemove < lastIndex) {
                    qDebug() << "HorizontalJournal only supports removal from the end of the model, resetting instead";
                    cleanupExistingItems();
                    break;
                } else {
                    setImplicitHeightDirty();
                }
            }
        }
    }
    if (m_visibleItems.isEmpty()) {
        m_firstVisibleIndex = -1;
    }
}


void HorizontalJournal::doRelayout()
{
    // If m_firstVisibleIndex is not 0 we need to drop all the delegates
    // since we can't consistently relayout without the first item being there

    if (m_firstVisibleIndex == 0) {
        int i = 0;
        const QList<QQuickItem*> allItems = m_visibleItems;
        m_visibleItems.clear();
        m_lastInRowIndexPosition.clear();
        Q_FOREACH(QQuickItem *item, allItems) {
            addItemToView(i, item);
            ++i;
        }
    } else {
        Q_FOREACH(QQuickItem *item, m_visibleItems) {
            releaseItem(item);
        }
        m_visibleItems.clear();
        m_lastInRowIndexPosition.clear();
        m_firstVisibleIndex = -1;
    }
}

void HorizontalJournal::updateItemCulling(qreal visibleFromY, qreal visibleToY)
{
    Q_FOREACH(QQuickItem *item, m_visibleItems) {
        QQuickItemPrivate::get(item)->setCulled(item->y() + m_rowHeight <= visibleFromY || item->y() >= visibleToY);
    }
}

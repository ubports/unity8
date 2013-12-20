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
 * The implementation is centered around m_columnVisibleItems
 * that holds a vector of lists. There's a list for each of the
 * columns the view has. In the list the items of the column are
 * ordered as they appear topdown in the view. m_indexColumnMap is
 * used when re-building the list up since given a position
 * in the middle of the list and the need to create the previous does
 * not give us enough information to know in which column we have
 * to position the item so that when we reach the item the view is
 * correctly layouted at 0 for all the columns
 */

#include "horizontaljournal.h"

#include <qqmlengine.h>
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-pedantic"
#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
#include <private/qquickvisualdatamodel_p.h>
#else
#include <private/qqmldelegatemodel_p.h>
#include <qqmlinfo.h>
#endif
#include <private/qquickitem_p.h>
#pragma GCC diagnostic pop

static const qreal bufferRatio = 0.5;

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

void HorizontalJournal::findBottomModelIndexToAdd(int *modelIndex, double *yPos)
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

void HorizontalJournal::findTopModelIndexToAdd(int *modelIndex, double *yPos)
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

bool HorizontalJournal::removeNonVisibleItems(qreal bufferFrom, qreal bufferTo)
{
    bool changed = false;

    while (!m_visibleItems.isEmpty() && m_visibleItems.first()->y() + m_rowHeight < bufferFrom) {
        releaseItem(m_visibleItems.takeFirst());
        changed = true;
        m_firstVisibleIndex++;
    }

    while (!m_visibleItems.isEmpty() && m_visibleItems.last()->y() > bufferTo) {
        releaseItem(m_visibleItems.takeLast());
        changed = true;
        m_lastInRowIndexPosition.remove(m_firstVisibleIndex + m_visibleItems.count());
    }

    if (m_visibleItems.isEmpty()) {
        m_firstVisibleIndex = -1;
    }

    return changed;
}

void HorizontalJournal::positionItem(int modelIndex, QQuickItem *item)
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
            qWarning() << "HorizontalJournal::positionItem - Got unexpected modelIndex" << modelIndex << m_firstVisibleIndex << m_visibleItems.count();
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
    m_firstVisibleIndex = 0;
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

#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
void HorizontalJournal::processModelRemoves(const QVector<QQuickChangeSet::Remove> &removes)
#else
void HorizontalJournal::processModelRemoves(const QVector<QQmlChangeSet::Remove> &removes)
#endif
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
    Q_FOREACH(const QQuickChangeSet::Remove &remove, removes) {
#else
    Q_FOREACH(const QQmlChangeSet::Remove &remove, removes) {
#endif
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
                    qFatal("HorizontalJournal only supports removal from the end of the model");
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
            positionItem(i, item);
            ++i;
        }
    } else {
        Q_FOREACH(QQuickItem *item, m_visibleItems) {
            releaseItem(item);
        }
        m_visibleItems.clear();
        m_lastInRowIndexPosition.clear();
        m_firstVisibleIndex = 0;
    }
}

void HorizontalJournal::updateItemCulling(qreal visibleFrom, qreal visibleTo)
{
    Q_FOREACH(QQuickItem *item, m_visibleItems) {
        QQuickItemPrivate::get(item)->setCulled(item->y() + m_rowHeight <= visibleFrom || item->y() >= visibleTo);
    }
}

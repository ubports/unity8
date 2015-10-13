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
#include "verticaljournal.h"

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-pedantic"
#include <private/qquickitem_p.h>
#pragma GCC diagnostic pop

VerticalJournal::VerticalJournal()
 : m_columnWidth(0)
{
}

qreal VerticalJournal::columnWidth() const
{
    return m_columnWidth;
}

void VerticalJournal::setColumnWidth(qreal columnWidth)
{
    if (columnWidth != m_columnWidth) {
        m_columnWidth = columnWidth;
        Q_EMIT columnWidthChanged();

        if (isComponentComplete()) {
            Q_FOREACH(const auto &column, m_columnVisibleItems) {
                Q_FOREACH(const ViewItem &item, column) {
                    item.m_item->setWidth(columnWidth);
                }
            }
            relayout();
        }
    }
}

void VerticalJournal::findBottomModelIndexToAdd(int *modelIndex, qreal *yPos)
{
    *modelIndex = 0;
    *yPos = std::numeric_limits<qreal>::max();

    Q_FOREACH(const auto &column, m_columnVisibleItems) {
        if (!column.isEmpty()) {
            const ViewItem &item = column.last();
            *yPos = qMin(*yPos, item.y() + item.height() + rowSpacing());
            *modelIndex = qMax(*modelIndex, item.m_modelIndex + 1);
        } else {
            *yPos = 0;
        }
    }
}

void VerticalJournal::findTopModelIndexToAdd(int *modelIndex, qreal *yPos)
{
    *modelIndex = 0;
    *yPos = std::numeric_limits<qreal>::lowest();
    int columnToAddTo = -1;

    // Find the topmost free column
    for (int i = 0; i < m_columnVisibleItems.count(); ++i) {
        const auto &column = m_columnVisibleItems[i];
        if (!column.isEmpty()) {
            const ViewItem &item = column.first();
            const auto itemTopPos = item.y() - rowSpacing();
            if (itemTopPos > *yPos) {
                *yPos = itemTopPos;
                *modelIndex = item.m_modelIndex - 1;
                columnToAddTo = i;
            }
        }
    }

    if (*modelIndex > 0) {
        Q_ASSERT(m_indexColumnMap.contains(*modelIndex));
        while (m_indexColumnMap[*modelIndex] != columnToAddTo) {
            // We found out that we have to add to columnToAddTo
            // and thought that we had to add *modelIndex, but history tells
            // it is not correct, so find up from *modelIndex until we found the index
            // that has to end up in columnToAddTo
            *modelIndex = *modelIndex - 1;
            Q_ASSERT(m_indexColumnMap.contains(*modelIndex));
        }
    }
}

bool VerticalJournal::removeNonVisibleItems(qreal bufferFromY, qreal bufferToY)
{
    bool changed = false;

    for (int i = 0; i < m_columnVisibleItems.count(); ++i) {
        QList<ViewItem> &column = m_columnVisibleItems[i];
        while (!column.isEmpty() && column.first().y() + column.first().height() < bufferFromY) {
            releaseItem(column.takeFirst().m_item);
            changed = true;
        }

        while (!column.isEmpty() && column.last().y() > bufferToY) {
            releaseItem(column.takeLast().m_item);
            changed = true;
        }
    }

    return changed;
}

void VerticalJournal::addItemToView(int modelIndex, QQuickItem *item)
{
    if (item->width() != m_columnWidth) {
        qWarning() << "Item" << modelIndex << "width is not the one that the columnWidth mandates, resetting it";
        item->setWidth(m_columnWidth);
    }

    // Check if we add it to the bottom of existing column items
    const QList<ViewItem> &firstColumn = m_columnVisibleItems[0];
    qreal columnToAddY = !firstColumn.isEmpty() ? firstColumn.last().y() + firstColumn.last().height() : -rowSpacing();
    int columnToAddTo = 0;
    for (int i = 1; i < m_columnVisibleItems.count(); ++i) {
        const QList<ViewItem> &column = m_columnVisibleItems[i];
        const qreal iY = !column.isEmpty() ? column.last().y() + column.last().height() : -rowSpacing();
        if (iY < columnToAddY) {
            columnToAddTo = i;
            columnToAddY = iY;
        }
    }

    const QList<ViewItem> &columnToAdd = m_columnVisibleItems[columnToAddTo];
    if (columnToAdd.isEmpty() || columnToAdd.last().m_modelIndex < modelIndex) {
        item->setX(columnToAddTo * (m_columnWidth + columnSpacing()));
        item->setY(columnToAddY + rowSpacing());

        m_columnVisibleItems[columnToAddTo] << ViewItem(item, modelIndex);
        m_indexColumnMap[modelIndex] = columnToAddTo;
    } else {
        Q_ASSERT(m_indexColumnMap.contains(modelIndex));
        columnToAddTo = m_indexColumnMap[modelIndex];
        columnToAddY = m_columnVisibleItems[columnToAddTo].first().y();

        item->setX(columnToAddTo * (m_columnWidth + columnSpacing()));
        item->setY(columnToAddY - rowSpacing() - item->height());

        m_columnVisibleItems[columnToAddTo].prepend(ViewItem(item, modelIndex));
    }
}

void VerticalJournal::cleanupExistingItems()
{
    // Cleanup the existing items
    for (int i = 0; i < m_columnVisibleItems.count(); ++i) {
        QList<ViewItem> &column = m_columnVisibleItems[i];
        Q_FOREACH(const ViewItem &item, column)
            releaseItem(item.m_item);
        column.clear();
    }
    m_indexColumnMap.clear();
    setImplicitHeightDirty();
}

void VerticalJournal::calculateImplicitHeight()
{
    int lastModelIndex = -1;
    qreal bottomMostY = 0;
    Q_FOREACH(const auto &column, m_columnVisibleItems) {
        if (!column.isEmpty()) {
            const ViewItem &item = column.last();
            lastModelIndex = qMax(lastModelIndex, item.m_modelIndex);
            bottomMostY = qMax(bottomMostY, item.y() + item.height());
        }
    }
    if (lastModelIndex >= 0) {
        const double averageHeight = bottomMostY / (lastModelIndex + 1);
        setImplicitHeight(bottomMostY + averageHeight * (model()->rowCount() - lastModelIndex - 1));
    } else {
        setImplicitHeight(0);
    }
}

void VerticalJournal::doRelayout()
{
    QList<ViewItem> allItems;
    Q_FOREACH(const auto &column, m_columnVisibleItems)
        allItems << column;

    qSort(allItems);

    const int nColumns = qMax(1., floor((double)(width() + columnSpacing()) / (m_columnWidth + columnSpacing())));
    m_columnVisibleItems.resize(nColumns);
    m_indexColumnMap.clear();
    for (int i = 0; i < nColumns; ++i)
        m_columnVisibleItems[i].clear();

    // If the first of allItems doesn't contain index 0 we need to drop them
    // all since we can't consistently relayout without the first item being there

    if (!allItems.isEmpty()) {
        if (allItems.first().m_modelIndex == 0) {
            Q_FOREACH(const ViewItem &item, allItems)
                addItemToView(item.m_modelIndex, item.m_item);
        } else {
            Q_FOREACH(const ViewItem &item, allItems)
                releaseItem(item.m_item);
        }
    }
}

void VerticalJournal::updateItemCulling(qreal visibleFromY, qreal visibleToY)
{
    Q_FOREACH(const auto &column, m_columnVisibleItems) {
        Q_FOREACH(const ViewItem &item, column) {
            const bool cull = item.y() + item.height() <= visibleFromY || item.y() >= visibleToY;
            QQuickItemPrivate::get(item.m_item)->setCulled(cull);
        }
    }
}

#if (QT_VERSION < QT_VERSION_CHECK(5, 4, 0))
void VerticalJournal::processModelRemoves(const QVector<QQmlChangeSet::Remove> &removes)
#else
void VerticalJournal::processModelRemoves(const QVector<QQmlChangeSet::Change> &removes)
#endif
{
    Q_FOREACH(const QQmlChangeSet::Change &remove, removes) {
        for (int i = remove.count - 1; i >= 0; --i) {
            const int indexToRemove = remove.index + i;
            // Since we only support removing from the end, indexToRemove
            // must refer to the last item of one of the columns or
            // be bigger than them (because it's not in the viewport and
            // thus we have not created a delegate for it)
            bool found = false;
            int lastCreatedIndex = INT_MIN;
            for (int i = 0; !found && i < m_columnVisibleItems.count(); ++i) {
                QList<ViewItem> &column = m_columnVisibleItems[i];
                if (!column.isEmpty()) {
                    const int lastColumnIndex = column.last().m_modelIndex;
                    if (lastColumnIndex == indexToRemove) {
                        releaseItem(column.takeLast().m_item);
                        found = true;
                    }
                    lastCreatedIndex = qMax(lastCreatedIndex, lastColumnIndex);
                }
            }
            if (!found) {
                if (indexToRemove < lastCreatedIndex) {
                    qFatal("VerticalJournal only supports removal from the end of the model");
                } else {
                    setImplicitHeightDirty();
                }
            }
        }
    }
}

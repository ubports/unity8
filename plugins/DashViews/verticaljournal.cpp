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
 * Some documentation on how this thing works:
 *
 * A vertical journal is a view that creates delegates
 * based on a model and layouts them in columns following
 * a top-left most position rule.
 *
 * The number of rules is calculated using the width of
 * the item, the columnWidth and the horizontalSpacing between
 * columns.
 *
 * The first nColumns items are layouted at row 0 from column 0
 * to column nColumns-1 in order. After that every new item
 * is positioned in the column which provides the topmost
 * position as possible. If more than one column tie in providing
 * the topmost position the leftmost column will be used.
 *
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

VerticalJournal::VerticalJournal()
 : m_delegateModel(nullptr)
 , m_asyncRequestedIndex(-1)
 , m_columnWidth(0)
 , m_horizontalSpacing(0)
 , m_verticalSpacing(0)
 , m_delegateCreationBegin(0)
 , m_delegateCreationEnd(0)
 , m_delegateCreationBeginValid(false)
 , m_delegateCreationEndValid(false)
 , m_needsRelayout(false)
 , m_delegateValidated(false)
 , m_implicitHeightDirty(false)
{
    connect(this, SIGNAL(widthChanged()), this, SLOT(relayout()));
    connect(this, SIGNAL(heightChanged()), this, SLOT(onHeightChanged()));
}

QAbstractItemModel *VerticalJournal::model() const
{
    return m_delegateModel ? m_delegateModel->model().value<QAbstractItemModel *>() : nullptr;
}

void VerticalJournal::setModel(QAbstractItemModel *model)
{
    if (model != this->model()) {
        if (!m_delegateModel) {
            createDelegateModel();
        }
#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
        m_delegateModel->setModel(QVariant::fromValue<QAbstractItemModel *>(model));
#else
        m_delegateModel->setModel(QVariant::fromValue<QAbstractItemModel *>(model));
#endif
        // Cleanup the existing items
        for (int i = 0; i < m_columnVisibleItems.count(); ++i)
        {
            QList<ViewItem> &column = m_columnVisibleItems[i];
            Q_FOREACH(const ViewItem &item, column)
                releaseItem(item);
            column.clear();
        }
        m_indexColumnMap.clear();

        Q_EMIT modelChanged();
        polish();
    }
}

QQmlComponent *VerticalJournal::delegate() const
{
    return m_delegateModel ? m_delegateModel->delegate() : nullptr;
}

void VerticalJournal::setDelegate(QQmlComponent *delegate)
{
    if (delegate != this->delegate()) {
        if (!m_delegateModel) {
            createDelegateModel();
        }

        // Cleanup the existing items
        for (int i = 0; i < m_columnVisibleItems.count(); ++i)
        {
            QList<ViewItem> &column = m_columnVisibleItems[i];
            Q_FOREACH(const ViewItem &item, column)
                releaseItem(item);
            column.clear();
        }
        m_indexColumnMap.clear();

        m_delegateModel->setDelegate(delegate);

        Q_EMIT delegateChanged();
        m_delegateValidated = false;
        polish();
    }
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

qreal VerticalJournal::horizontalSpacing() const
{
    return m_horizontalSpacing;
}

void VerticalJournal::setHorizontalSpacing(qreal horizontalSpacing)
{
    if (horizontalSpacing != m_horizontalSpacing) {
        m_horizontalSpacing = horizontalSpacing;
        Q_EMIT horizontalSpacingChanged();

        if (isComponentComplete()) {
            relayout();
        }
    }
}

qreal VerticalJournal::verticalSpacing() const
{
    return m_verticalSpacing;
}

void VerticalJournal::setVerticalSpacing(qreal verticalSpacing)
{
    if (verticalSpacing != m_verticalSpacing) {
        m_verticalSpacing = verticalSpacing;
        Q_EMIT verticalSpacingChanged();

        if (isComponentComplete()) {
            relayout();
        }
    }
}

qreal VerticalJournal::delegateCreationBegin() const
{
    return m_delegateCreationBegin;
}

void VerticalJournal::setDelegateCreationBegin(qreal begin)
{
    m_delegateCreationBeginValid = true;
    if (m_delegateCreationBegin == begin)
        return;
    m_delegateCreationBegin = begin;
    if (isComponentComplete()) {
        polish();
    }
    emit delegateCreationBeginChanged();
}

void VerticalJournal::resetDelegateCreationBegin()
{
    m_delegateCreationBeginValid = false;
    if (m_delegateCreationBegin == 0)
        return;
    m_delegateCreationBegin = 0;
    if (isComponentComplete()) {
        polish();
    }
    emit delegateCreationBeginChanged();
}

qreal VerticalJournal::delegateCreationEnd() const
{
    return m_delegateCreationEnd;
}

void VerticalJournal::setDelegateCreationEnd(qreal end)
{
    m_delegateCreationEndValid = true;
    if (m_delegateCreationEnd == end)
        return;
    m_delegateCreationEnd = end;
    if (isComponentComplete()) {
        polish();
    }
    emit delegateCreationEndChanged();
}

void VerticalJournal::resetDelegateCreationEnd()
{
    m_delegateCreationEndValid = false;
    if (m_delegateCreationEnd == 0)
        return;
    m_delegateCreationEnd = 0;
    if (isComponentComplete()) {
        polish();
    }
    emit delegateCreationEndChanged();
}

void VerticalJournal::createDelegateModel()
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
    m_delegateModel = new QQuickVisualDataModel(qmlContext(this), this);
    connect(m_delegateModel, SIGNAL(createdItem(int,QQuickItem*)), this, SLOT(itemCreated(int,QQuickItem*)));
#else
    m_delegateModel = new QQmlDelegateModel(qmlContext(this), this);
    connect(m_delegateModel, SIGNAL(createdItem(int,QObject*)), this, SLOT(itemCreated(int,QObject*)));
#endif
    if (isComponentComplete())
        m_delegateModel->componentComplete();
}

void VerticalJournal::refill()
{
    if (!isComponentComplete()) {
        return;
    }

    const bool delegateRangesValid = m_delegateCreationBeginValid && m_delegateCreationEndValid;
    const qreal from = delegateRangesValid ? m_delegateCreationBegin : 0;
    const qreal to = delegateRangesValid ? m_delegateCreationEnd : from + height();
    const qreal buffer = (to - from) * bufferRatio;
    const qreal bufferFrom = from - buffer;
    const qreal bufferTo = to + buffer;

    bool added = addVisibleItems(from, to, false);
    bool removed = removeNonVisibleItems(bufferFrom, bufferTo);
    added |= addVisibleItems(bufferFrom, bufferTo, true);

    if (added || removed) {
        m_implicitHeightDirty = true;
    }
}

void VerticalJournal::findBottomModelIndexToAdd(int *modelIndex, double *yPos)
{
    *modelIndex = 0;
    *yPos = INT_MAX;

    Q_FOREACH(const auto &column, m_columnVisibleItems) {
        if (!column.isEmpty()) {
            const ViewItem &item = column.last();
            *yPos = qMin(*yPos, static_cast<double>(item.y() + item.height() + m_verticalSpacing));
            *modelIndex = qMax(*modelIndex, item.m_modelIndex + 1);
        } else {
            *yPos = 0;
        }
    }
}

void VerticalJournal::findTopModelIndexToAdd(int *modelIndex, double *yPos)
{
    *modelIndex = INT_MAX;
    *yPos = INT_MIN;
    int columnToAddTo = -1;

    // Find the topmost free column
    for (int i = 0; i < m_columnVisibleItems.count(); ++i) {
        const auto &column = m_columnVisibleItems[i];
        if (!column.isEmpty()) {
            const ViewItem &item = column.first();
            const auto itemTopPos = item.y() - m_verticalSpacing;
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

bool VerticalJournal::addVisibleItems(qreal fillFrom, qreal fillTo, bool asynchronous)
{
    if (!delegate())
        return false;

    if (m_delegateModel->count() == 0)
        return false;

    int modelIndex;
    double yPos;
    findBottomModelIndexToAdd(&modelIndex, &yPos);
    bool changed = false;
    while (modelIndex < m_delegateModel->count() && yPos <= fillTo) {
        if (!createItem(modelIndex, asynchronous))
            break;

        changed = true;
        findBottomModelIndexToAdd(&modelIndex, &yPos);
    }

    findTopModelIndexToAdd(&modelIndex, &yPos);
    while (modelIndex >= 0 && yPos > fillFrom) {
        if (!createItem(modelIndex, asynchronous))
            break;

        changed = true;
        findTopModelIndexToAdd(&modelIndex, &yPos);
    }

    return changed;
}

bool VerticalJournal::removeNonVisibleItems(qreal bufferFrom, qreal bufferTo)
{
    bool changed = false;

    for (int i = 0; i < m_columnVisibleItems.count(); ++i) {
        QList<ViewItem> &column = m_columnVisibleItems[i];
        while (!column.isEmpty() && column.first().y() + column.first().height() < bufferFrom) {
            releaseItem(column.takeFirst());
            changed = true;
        }

        while (!column.isEmpty() && column.last().y() > bufferTo) {
            releaseItem(column.takeLast());
            changed = true;
        }
    }

    return changed;
}

QQuickItem *VerticalJournal::createItem(int modelIndex, bool asynchronous)
{
    if (asynchronous && m_asyncRequestedIndex != -1)
        return nullptr;

    m_asyncRequestedIndex = -1;
#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
    QQuickItem *item = m_delegateModel->item(modelIndex, asynchronous);
#else
    QObject* object = m_delegateModel->object(modelIndex, asynchronous);
    QQuickItem *item = qmlobject_cast<QQuickItem*>(object);
#endif
    if (!item) {
#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
        m_asyncRequestedIndex = modelIndex;
#else
        if (object) {
            m_delegateModel->release(object);
            if (!m_delegateValidated) {
                m_delegateValidated = true;
                QObject* delegateObj = delegate();
                qmlInfo(delegateObj ? delegateObj : this) << "Delegate must be of Item type";
            }
        } else {
            m_asyncRequestedIndex = modelIndex;
        }
#endif
        return nullptr;
    } else {
        if (item->width() != m_columnWidth) {
            qWarning() << "Item" << modelIndex << "width is not the one that the columnWidth mandates, resetting it";
            item->setWidth(m_columnWidth);
        }
        positionItem(modelIndex, item);
        return item;
    }
}

void VerticalJournal::positionItem(int modelIndex, QQuickItem *item)
{
    // Check if we add it to the bottom of existing column items
    qreal columnToAddY = !m_columnVisibleItems[0].isEmpty() ? m_columnVisibleItems[0].last().y() + m_columnVisibleItems[0].last().height() : 0;
    int columnToAddTo = 0;
    for (int i = 1; i < m_columnVisibleItems.count(); ++i) {
        const qreal iY = !m_columnVisibleItems[i].isEmpty() ? m_columnVisibleItems[i].last().y() + m_columnVisibleItems[i].last().height() : 0;
        if (iY < columnToAddY) {
            columnToAddTo = i;
            columnToAddY = iY;
        }
    }
    if (m_columnVisibleItems[columnToAddTo].isEmpty() || m_columnVisibleItems[columnToAddTo].last().m_modelIndex < modelIndex) {
        item->setX(columnToAddTo * m_columnWidth + m_horizontalSpacing * (columnToAddTo + 1));
        item->setY(columnToAddY + m_verticalSpacing);

        m_columnVisibleItems[columnToAddTo] << ViewItem(item, modelIndex);
        m_indexColumnMap[modelIndex] = columnToAddTo;
    } else {
        Q_ASSERT(m_indexColumnMap.contains(modelIndex));
        columnToAddTo = m_indexColumnMap[modelIndex];
        columnToAddY = m_columnVisibleItems[columnToAddTo].first().y();

        item->setX(columnToAddTo * m_columnWidth + m_horizontalSpacing * (columnToAddTo + 1));
        item->setY(columnToAddY - m_verticalSpacing - item->height());

        m_columnVisibleItems[columnToAddTo].prepend(ViewItem(item, modelIndex));
    }
}

void VerticalJournal::releaseItem(const ViewItem &item)
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
    QQuickVisualModel::ReleaseFlags flags = m_delegateModel->release(item.m_item);
    if (flags & QQuickVisualModel::Destroyed) {
#else
    QQmlDelegateModel::ReleaseFlags flags = m_delegateModel->release(item.m_item);
    if (flags & QQmlDelegateModel::Destroyed) {
#endif
        item.m_item->setParentItem(nullptr);
    }
}

#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
void VerticalJournal::itemCreated(int modelIndex, QQuickItem *item)
{
#else
void VerticalJournal::itemCreated(int modelIndex, QObject *object)
{
    QQuickItem *item = qmlobject_cast<QQuickItem*>(object);
    if (!item) {
        qWarning() << "ListViewWithPageHeader::itemCreated got a non item for index" << modelIndex;
        return;
    }
#endif
    item->setParentItem(this);
    if (modelIndex == m_asyncRequestedIndex) {
        createItem(modelIndex, false);
        m_implicitHeightDirty = true;
        polish();
    }
}

void VerticalJournal::relayout()
{
    m_needsRelayout = true;
    polish();
}

void VerticalJournal::onHeightChanged()
{
    polish();
}

void VerticalJournal::updatePolish()
{
    if (!model())
        return;

    if (m_needsRelayout) {
        QList<ViewItem> allItems;
        Q_FOREACH(const auto &column, m_columnVisibleItems)
            allItems << column;

        qSort(allItems);

        const int nColumns = qMax(1., floor((double)(width() - m_horizontalSpacing) / (m_columnWidth + m_horizontalSpacing)));
        m_columnVisibleItems.resize(nColumns);
        m_indexColumnMap.clear();
        for (int i = 0; i < nColumns; ++i)
            m_columnVisibleItems[i].clear();

        // If the first of allItems doesn't contain index 0 we need to drop them
        // all since we can't consistently relayout without the first item being there

        if (!allItems.isEmpty()) {
            if (allItems.first().m_modelIndex == 0) {
                Q_FOREACH(const ViewItem &item, allItems)
                    positionItem(item.m_modelIndex, item.m_item);
            } else {
                Q_FOREACH(const ViewItem &item, allItems)
                    releaseItem(item);
            }
        }

        m_needsRelayout = false;
    }

    refill();

    const bool delegateRangesValid = m_delegateCreationBeginValid && m_delegateCreationEndValid;
    const qreal from = delegateRangesValid ? m_delegateCreationBegin : 0;
    const qreal to = delegateRangesValid ? m_delegateCreationEnd : from + height();
    Q_FOREACH(const auto &column, m_columnVisibleItems) {
        Q_FOREACH(const ViewItem &item, column) {
            QQuickItemPrivate::get(item.m_item)->setCulled(item.y() + item.height() <= from || item.y() >= to);
        }
    }

    if (m_implicitHeightDirty) {
        m_implicitHeightDirty = false;

        int lastModelIndex = -1;
        qreal bottomMostY = 0;
        Q_FOREACH(const auto &column, m_columnVisibleItems) {
            if (!column.isEmpty()) {
                const ViewItem &item = column.last();
                lastModelIndex = qMax(lastModelIndex, item.m_modelIndex);
                bottomMostY = qMax(bottomMostY, item.y() + item.height() + m_verticalSpacing);
            }
        }
        if (lastModelIndex >= 0) {
            const double averageHeight = bottomMostY / (lastModelIndex + 1);
            setImplicitHeight(bottomMostY + averageHeight * (model()->rowCount() - lastModelIndex - 1));
        } else {
            setImplicitHeight(0);
        }
    }
}

void VerticalJournal::componentComplete()
{
    if (m_delegateModel)
        m_delegateModel->componentComplete();

    QQuickItem::componentComplete();

    const int nColumns = ceil((double)(width() - m_horizontalSpacing) / (m_columnWidth + m_horizontalSpacing));
    m_columnVisibleItems.resize(nColumns);

    polish();
}

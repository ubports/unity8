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
 : m_delegateModel(nullptr)
 , m_asyncRequestedIndex(-1)
 , m_firstVisibleIndex(-1)
 , m_rowHeight(0)
 , m_columnSpacing(0)
 , m_rowSpacing(0)
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

QAbstractItemModel *HorizontalJournal::model() const
{
    return m_delegateModel ? m_delegateModel->model().value<QAbstractItemModel *>() : nullptr;
}

void HorizontalJournal::setModel(QAbstractItemModel *model)
{
    if (model != this->model()) {
        if (!m_delegateModel) {
            createDelegateModel();
        } else {
#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
            disconnect(m_delegateModel, SIGNAL(modelUpdated(QQuickChangeSet,bool)), this, SLOT(onModelUpdated(QQuickChangeSet,bool)));
        }
        m_delegateModel->setModel(QVariant::fromValue<QAbstractItemModel *>(model));
        connect(m_delegateModel, SIGNAL(modelUpdated(QQuickChangeSet,bool)), this, SLOT(onModelUpdated(QQuickChangeSet,bool)));
#else
            disconnect(m_delegateModel, SIGNAL(modelUpdated(QQmlChangeSet,bool)), this, SLOT(onModelUpdated(QQmlChangeSet,bool)));
        }
        m_delegateModel->setModel(QVariant::fromValue<QAbstractItemModel *>(model));
        connect(m_delegateModel, SIGNAL(modelUpdated(QQmlChangeSet,bool)), this, SLOT(onModelUpdated(QQmlChangeSet,bool)));
#endif

        cleanupExistingItems();

        Q_EMIT modelChanged();
        polish();
    }
}

QQmlComponent *HorizontalJournal::delegate() const
{
    return m_delegateModel ? m_delegateModel->delegate() : nullptr;
}

void HorizontalJournal::setDelegate(QQmlComponent *delegate)
{
    if (delegate != this->delegate()) {
        if (!m_delegateModel) {
            createDelegateModel();
        }

        cleanupExistingItems();

        m_delegateModel->setDelegate(delegate);

        Q_EMIT delegateChanged();
        m_delegateValidated = false;
        polish();
    }
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

qreal HorizontalJournal::columnSpacing() const
{
    return m_columnSpacing;
}

void HorizontalJournal::setColumnSpacing(qreal columnSpacing)
{
    if (columnSpacing != m_columnSpacing) {
        m_columnSpacing = columnSpacing;
        Q_EMIT columnSpacingChanged();

        if (isComponentComplete()) {
            relayout();
        }
    }
}

qreal HorizontalJournal::rowSpacing() const
{
    return m_rowSpacing;
}

void HorizontalJournal::setRowSpacing(qreal rowSpacing)
{
    if (rowSpacing != m_rowSpacing) {
        m_rowSpacing = rowSpacing;
        Q_EMIT rowSpacingChanged();

        if (isComponentComplete()) {
            relayout();
        }
    }
}

qreal HorizontalJournal::delegateCreationBegin() const
{
    return m_delegateCreationBegin;
}

void HorizontalJournal::setDelegateCreationBegin(qreal begin)
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

void HorizontalJournal::resetDelegateCreationBegin()
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

qreal HorizontalJournal::delegateCreationEnd() const
{
    return m_delegateCreationEnd;
}

void HorizontalJournal::setDelegateCreationEnd(qreal end)
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

void HorizontalJournal::resetDelegateCreationEnd()
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

void HorizontalJournal::createDelegateModel()
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

void HorizontalJournal::refill()
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

void HorizontalJournal::findBottomModelIndexToAdd(int *modelIndex, double *yPos)
{
    if (m_visibleItems.isEmpty()) {
        *modelIndex = 0;
        *yPos = 0;
    } else {
        *modelIndex = m_firstVisibleIndex + m_visibleItems.count();
        if (m_lastInRowIndexPosition.contains(*modelIndex - 1)) {
            *yPos = m_visibleItems.last()->y() + m_rowHeight + m_rowSpacing;
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
            *yPos = m_visibleItems.first()->y() - m_rowSpacing - m_rowHeight;
        } else {
            *yPos = m_visibleItems.first()->y();
        }
    }
}

bool HorizontalJournal::addVisibleItems(qreal fillFrom, qreal fillTo, bool asynchronous)
{
    if (!delegate())
        return false;

    if (m_delegateModel->count() == 0)
        return false;

    int modelIndex;
    qreal yPos;
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

QQuickItem *HorizontalJournal::createItem(int modelIndex, bool asynchronous)
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
        if (item->height() != m_rowHeight) {
            qWarning() << "Item" << modelIndex << "height is not the one that the rowHeight mandates, resetting it";
            item->setHeight(m_rowHeight);
        }
        positionItem(modelIndex, item);
        return item;
    }
}

void HorizontalJournal::positionItem(int modelIndex, QQuickItem *item)
{
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
            if (lastItem->x() + lastItem->width() + m_columnSpacing + item->width() <= width()) {
                // Fits in the row
                item->setY(lastItem->y());
                item->setX(lastItem->x() + lastItem->width() + m_columnSpacing);
            } else {
                // Starts a new row
                item->setY(lastItem->y() + m_rowHeight + m_rowSpacing);
                item->setX(0);
                m_lastInRowIndexPosition[modelIndex - 1] = lastItem->x();
            }
            m_visibleItems << item;
        } else if (modelIndex == m_firstVisibleIndex - 1) {
            QQuickItem *firstItem = m_visibleItems.first();
            if (m_lastInRowIndexPosition.contains(modelIndex)) {
                // It is the last item of its row, so start a new one since we're going back
                item->setY(firstItem->y() - m_rowSpacing - m_rowHeight);
                item->setX(m_lastInRowIndexPosition[modelIndex]);
            } else {
                item->setY(firstItem->y());
                item->setX(firstItem->x() - m_columnSpacing - item->width());
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

void HorizontalJournal::releaseItem(QQuickItem *item)
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
    QQuickVisualModel::ReleaseFlags flags = m_delegateModel->release(item);
    if (flags & QQuickVisualModel::Destroyed) {
#else
    QQmlDelegateModel::ReleaseFlags flags = m_delegateModel->release(item);
    if (flags & QQmlDelegateModel::Destroyed) {
#endif
        item->setParentItem(nullptr);
    }
}

void HorizontalJournal::calculateImplicitHeight()
{
    m_implicitHeightDirty = false;

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
void HorizontalJournal::itemCreated(int modelIndex, QQuickItem *item)
{
#else
void HorizontalJournal::itemCreated(int modelIndex, QObject *object)
{
    QQuickItem *item = qmlobject_cast<QQuickItem*>(object);
    if (!item) {
        qWarning() << "HorizontalJournal::itemCreated got a non item for index" << modelIndex;
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

#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
void HorizontalJournal::onModelUpdated(const QQuickChangeSet &changeSet, bool reset)
#else
void HorizontalJournal::onModelUpdated(const QQmlChangeSet &changeSet, bool reset)
#endif
{
    if (reset) {
        cleanupExistingItems();
    } else {
#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
        Q_FOREACH(const QQuickChangeSet::Remove &remove, changeSet.removes()) {
#else
        Q_FOREACH(const QQmlChangeSet::Remove &remove, changeSet.removes()) {
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
                        m_implicitHeightDirty = true;
                    }
                }
            }
        }
        if (m_visibleItems.isEmpty()) {
            m_firstVisibleIndex = -1;
        }
    }
    polish();
}

void HorizontalJournal::relayout()
{
    m_needsRelayout = true;
    polish();
}

void HorizontalJournal::onHeightChanged()
{
    polish();
}

void HorizontalJournal::updatePolish()
{
    if (!model())
        return;

    if (m_needsRelayout) {
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

        m_needsRelayout = false;
    }

    refill();

    const bool delegateRangesValid = m_delegateCreationBeginValid && m_delegateCreationEndValid;
    const qreal from = delegateRangesValid ? m_delegateCreationBegin : 0;
    const qreal to = delegateRangesValid ? m_delegateCreationEnd : from + height();
    Q_FOREACH(QQuickItem *item, m_visibleItems) {
        QQuickItemPrivate::get(item)->setCulled(item->y() + m_rowHeight <= from || item->y() >= to);
    }

    if (m_implicitHeightDirty) {
        calculateImplicitHeight();
    }
}

void HorizontalJournal::componentComplete()
{
    if (m_delegateModel)
        m_delegateModel->componentComplete();

    QQuickItem::componentComplete();

    m_needsRelayout = true;

    polish();
}

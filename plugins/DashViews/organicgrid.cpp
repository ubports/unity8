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

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-pedantic"
#include <private/qquickitem_p.h>
#pragma GCC diagnostic pop

static const qreal bufferRatio = 0.5;

OrganicGrid::OrganicGrid()
 : m_delegateModel(nullptr)
 , m_asyncRequestedIndex(-1)
 , m_columnSpacing(0)
 , m_rowSpacing(0)
 , m_delegateCreationBegin(0)
 , m_delegateCreationEnd(0)
 , m_delegateCreationBeginValid(false)
 , m_delegateCreationEndValid(false)
 , m_needsRelayout(false)
 , m_delegateValidated(false)
 , m_implicitHeightDirty(false)
 , m_firstVisibleIndex(-1)
 , m_numberOfModulesPerRow(-1)
{
    connect(this, SIGNAL(widthChanged()), this, SLOT(relayout()));
    connect(this, SIGNAL(heightChanged()), this, SLOT(onHeightChanged()));
}

QAbstractItemModel *OrganicGrid::model() const
{
    return m_delegateModel ? m_delegateModel->model().value<QAbstractItemModel *>() : nullptr;
}

void OrganicGrid::setModel(QAbstractItemModel *model)
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

QQmlComponent *OrganicGrid::delegate() const
{
    return m_delegateModel ? m_delegateModel->delegate() : nullptr;
}

void OrganicGrid::setDelegate(QQmlComponent *delegate)
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

qreal OrganicGrid::columnSpacing() const
{
    return m_columnSpacing;
}

void OrganicGrid::setColumnSpacing(qreal columnSpacing)
{
    if (columnSpacing != m_columnSpacing) {
        m_columnSpacing = columnSpacing;
        Q_EMIT columnSpacingChanged();

        if (isComponentComplete()) {
            relayout();
        }
    }
}

qreal OrganicGrid::rowSpacing() const
{
    return m_rowSpacing;
}

void OrganicGrid::setRowSpacing(qreal rowSpacing)
{
    if (rowSpacing != m_rowSpacing) {
        m_rowSpacing = rowSpacing;
        Q_EMIT rowSpacingChanged();

        if (isComponentComplete()) {
            relayout();
        }
    }
}

QSizeF OrganicGrid::smallDelegateSize() const
{
    return m_smallDelegateSize;
}

void OrganicGrid::setSmallDelegateSize(const QSizeF &size)
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

void OrganicGrid::setBigDelegateSize(const QSizeF &size)
{
    if (m_bigDelegateSize != size) {
        m_bigDelegateSize = size;
        Q_EMIT bigDelegateSizeChanged();

        if (isComponentComplete()) {
            relayout();
        }
    }
}

qreal OrganicGrid::delegateCreationBegin() const
{
    return m_delegateCreationBegin;
}

void OrganicGrid::setDelegateCreationBegin(qreal begin)
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

void OrganicGrid::resetDelegateCreationBegin()
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

qreal OrganicGrid::delegateCreationEnd() const
{
    return m_delegateCreationEnd;
}

void OrganicGrid::setDelegateCreationEnd(qreal end)
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

void OrganicGrid::resetDelegateCreationEnd()
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

void OrganicGrid::createDelegateModel()
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

void OrganicGrid::refill()
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
        polish();
    }
}

bool OrganicGrid::addVisibleItems(qreal fillFromY, qreal fillToY, bool asynchronous)
{
    if (!delegate())
        return false;

    if (m_delegateModel->count() == 0)
        return false;

    int modelIndex;
    qreal yPos;
    findBottomModelIndexToAdd(&modelIndex, &yPos);
    bool changed = false;
    while (modelIndex < m_delegateModel->count() && yPos <= fillToY) {
        if (!createItem(modelIndex, asynchronous))
            break;

        changed = true;
        findBottomModelIndexToAdd(&modelIndex, &yPos);
    }

    findTopModelIndexToAdd(&modelIndex, &yPos);
    while (modelIndex >= 0 && yPos > fillFromY) {
        if (!createItem(modelIndex, asynchronous))
            break;

        changed = true;
        findTopModelIndexToAdd(&modelIndex, &yPos);
    }

    return changed;
}

QQuickItem *OrganicGrid::createItem(int modelIndex, bool asynchronous)
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
        positionItem(modelIndex, item);
        return item;
    }
}

void OrganicGrid::releaseItem(QQuickItem *item)
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

void OrganicGrid::setImplicitHeightDirty()
{
    m_implicitHeightDirty = true;
}

#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
void OrganicGrid::itemCreated(int modelIndex, QQuickItem *item)
{
#else
void OrganicGrid::itemCreated(int modelIndex, QObject *object)
{
    QQuickItem *item = qmlobject_cast<QQuickItem*>(object);
    if (!item) {
        qWarning() << "OrganicGrid::itemCreated got a non item for index" << modelIndex;
        return;
    }
#endif
    item->setParentItem(this);

    // We only need to call createItem if we are here because of an asynchronous generation
    // otherwise we are in this slot because createItem is creating the item sync
    // and thus we don't need to call createItem again, nor need to set m_implicitHeightDirty
    // and call polish because the sync createItem was called from addVisibleItems that
    // is called from refill that will already do those if an item was added
    if (modelIndex == m_asyncRequestedIndex) {
        createItem(modelIndex, false);
        m_implicitHeightDirty = true;
        polish();
    }
}

#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
void OrganicGrid::onModelUpdated(const QQuickChangeSet &changeSet, bool reset)
#else
void OrganicGrid::onModelUpdated(const QQmlChangeSet &changeSet, bool reset)
#endif
{
    if (reset) {
        cleanupExistingItems();
    } else {
        processModelRemoves(changeSet.removes());
    }
    polish();
}


void OrganicGrid::relayout()
{
    m_needsRelayout = true;
    polish();
}

void OrganicGrid::onHeightChanged()
{
    polish();
}

void OrganicGrid::updatePolish()
{
    if (!model())
        return;

    if (m_needsRelayout) {
        doRelayout();
        m_needsRelayout = false;
        m_implicitHeightDirty = true;
    }

    refill();

    const bool delegateRangesValid = m_delegateCreationBeginValid && m_delegateCreationEndValid;
    const qreal from = delegateRangesValid ? m_delegateCreationBegin : 0;
    const qreal to = delegateRangesValid ? m_delegateCreationEnd : from + height();
    updateItemCulling(from, to);

    if (m_implicitHeightDirty) {
        calculateImplicitHeight();
        m_implicitHeightDirty = false;
    }
}

void OrganicGrid::componentComplete()
{
    if (m_delegateModel)
        m_delegateModel->componentComplete();

    QQuickItem::componentComplete();

    m_needsRelayout = true;

    polish();
}

QPointF OrganicGrid::positionForIndex(int modelIndex) const
{
    const qreal moduleHeight = m_smallDelegateSize.height() + rowSpacing() + m_bigDelegateSize.height();
    const qreal moduleWidth = m_smallDelegateSize.width() * 2 + columnSpacing() * 2 + m_bigDelegateSize.width();
    const int rowIndex = floor(modelIndex / (m_numberOfModulesPerRow * 6));
    const int columnIndex = floor((modelIndex - rowIndex * m_numberOfModulesPerRow * 6) / 6);

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

void OrganicGrid::positionItem(int modelIndex, QQuickItem *item)
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
        qWarning() << "OrganicGrid::positionItem - Got unexpected modelIndex"
                    << modelIndex << m_firstVisibleIndex << m_visibleItems.count();
        return;
    }

    const QPointF pos = positionForIndex(modelIndex);
    item->setPosition(pos);

    // TODO Do we want warnings here in case the sizes are not the one we want like we have in the journals?
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
    m_implicitHeightDirty = true;
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
        positionItem(i, item);
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
    const int itemCount = !m_delegateModel ? 0 : m_delegateModel->count();
    const int fullRows = floor(itemCount / (m_numberOfModulesPerRow * 6));
    const qreal fullRowsHeight = fullRows == 0 ? 0 : fullRows * moduleHeight + rowSpacing() * (fullRows - 1);

    const int remainingItems = itemCount - fullRows * m_numberOfModulesPerRow * 6;
    if (remainingItems == 0) {
        setImplicitHeight(fullRowsHeight);
    } else if (remainingItems <= 2) {
        setImplicitHeight(fullRowsHeight + m_smallDelegateSize.height() + rowSpacing());
    } else {
        setImplicitHeight(fullRowsHeight + rowSpacing() + moduleHeight);
    }
}

#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
void OrganicGrid::processModelRemoves(const QVector<QQuickChangeSet::Remove> &removes)
#else
void OrganicGrid::processModelRemoves(const QVector<QQmlChangeSet::Remove> &removes)
#endif
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
    Q_FOREACH(const QQuickChangeSet::Remove &remove, removes) {
#else
    Q_FOREACH(const QQmlChangeSet::Remove &remove, removes) {
#endif
        for (int i = remove.count - 1; i >= 0; --i) {
            const int indexToRemove = remove.index + i;
            // We only support removing from the end
            const int lastIndex = m_firstVisibleIndex + m_visibleItems.count() - 1;
            if (indexToRemove == lastIndex) {
                releaseItem(m_visibleItems.takeLast());
            } else {
                if (indexToRemove < lastIndex) {
                    qFatal("OrganicGrid only supports removal from the end of the model");
                }
            }
        }
    }
    if (m_visibleItems.isEmpty()) {
        m_firstVisibleIndex = -1;
    }
    setImplicitHeightDirty();
}


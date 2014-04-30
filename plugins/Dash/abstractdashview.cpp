/*
 * Copyright (C) 2013, 2014 Canonical, Ltd.
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

#include "abstractdashview.h"

static const qreal bufferRatio = 0.5;

AbstractDashView::AbstractDashView()
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
{
    connect(this, SIGNAL(widthChanged()), this, SLOT(relayout()));
    connect(this, SIGNAL(heightChanged()), this, SLOT(onHeightChanged()));
}

QAbstractItemModel *AbstractDashView::model() const
{
    return m_delegateModel ? m_delegateModel->model().value<QAbstractItemModel *>() : nullptr;
}

void AbstractDashView::setModel(QAbstractItemModel *model)
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

QQmlComponent *AbstractDashView::delegate() const
{
    return m_delegateModel ? m_delegateModel->delegate() : nullptr;
}

void AbstractDashView::setDelegate(QQmlComponent *delegate)
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

qreal AbstractDashView::columnSpacing() const
{
    return m_columnSpacing;
}

void AbstractDashView::setColumnSpacing(qreal columnSpacing)
{
    if (columnSpacing != m_columnSpacing) {
        m_columnSpacing = columnSpacing;
        Q_EMIT columnSpacingChanged();

        if (isComponentComplete()) {
            relayout();
        }
    }
}

qreal AbstractDashView::rowSpacing() const
{
    return m_rowSpacing;
}

void AbstractDashView::setRowSpacing(qreal rowSpacing)
{
    if (rowSpacing != m_rowSpacing) {
        m_rowSpacing = rowSpacing;
        Q_EMIT rowSpacingChanged();

        if (isComponentComplete()) {
            relayout();
        }
    }
}

qreal AbstractDashView::delegateCreationBegin() const
{
    return m_delegateCreationBegin;
}

void AbstractDashView::setDelegateCreationBegin(qreal begin)
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

void AbstractDashView::resetDelegateCreationBegin()
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

qreal AbstractDashView::delegateCreationEnd() const
{
    return m_delegateCreationEnd;
}

void AbstractDashView::setDelegateCreationEnd(qreal end)
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

void AbstractDashView::resetDelegateCreationEnd()
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

void AbstractDashView::createDelegateModel()
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

void AbstractDashView::refill()
{
    if (!isComponentComplete() || height() < 0) {
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

bool AbstractDashView::addVisibleItems(qreal fillFromY, qreal fillToY, bool asynchronous)
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

QQuickItem *AbstractDashView::createItem(int modelIndex, bool asynchronous)
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
        addItemToView(modelIndex, item);
        return item;
    }
}

void AbstractDashView::releaseItem(QQuickItem *item)
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

void AbstractDashView::setImplicitHeightDirty()
{
    m_implicitHeightDirty = true;
}

#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
void AbstractDashView::itemCreated(int modelIndex, QQuickItem *item)
{
#else
void AbstractDashView::itemCreated(int modelIndex, QObject *object)
{
    QQuickItem *item = qmlobject_cast<QQuickItem*>(object);
    if (!item) {
        qWarning() << "AbstractDashView::itemCreated got a non item for index" << modelIndex;
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
void AbstractDashView::onModelUpdated(const QQuickChangeSet &changeSet, bool reset)
#else
void AbstractDashView::onModelUpdated(const QQmlChangeSet &changeSet, bool reset)
#endif
{
    if (reset) {
        cleanupExistingItems();
    } else {
        processModelRemoves(changeSet.removes());
    }
    polish();
}


void AbstractDashView::relayout()
{
    m_needsRelayout = true;
    polish();
}

void AbstractDashView::onHeightChanged()
{
    polish();
}

void AbstractDashView::updatePolish()
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

void AbstractDashView::componentComplete()
{
    if (m_delegateModel)
        m_delegateModel->componentComplete();

    QQuickItem::componentComplete();

    m_needsRelayout = true;

    polish();
}

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

#ifndef ABSTRACTDASHVIEW_H
#define ABSTRACTDASHVIEW_H

#include <QQuickItem>

class QAbstractItemModel;
class QQmlComponent;

#include <private/qqmldelegatemodel_p.h>
#include <qqmlinfo.h>

class AbstractDashView : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QAbstractItemModel *model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QQmlComponent *delegate READ delegate WRITE setDelegate NOTIFY delegateChanged)
    Q_PROPERTY(qreal columnSpacing READ columnSpacing WRITE setColumnSpacing NOTIFY columnSpacingChanged)
    Q_PROPERTY(qreal rowSpacing READ rowSpacing WRITE setRowSpacing NOTIFY rowSpacingChanged)
    Q_PROPERTY(int cacheBuffer READ cacheBuffer WRITE setCacheBuffer NOTIFY cacheBufferChanged)
    Q_PROPERTY(qreal displayMarginBeginning READ displayMarginBeginning
                                            WRITE setDisplayMarginBeginning
                                            NOTIFY displayMarginBeginningChanged)
    Q_PROPERTY(qreal displayMarginEnd READ displayMarginEnd
                                      WRITE setDisplayMarginEnd
                                      NOTIFY displayMarginEndChanged)

friend class VerticalJournalTest;
friend class HorizontalJournalTest;
friend class OrganicGridTest;

public:
    AbstractDashView();

    QAbstractItemModel *model() const;
    void setModel(QAbstractItemModel *model);

    QQmlComponent *delegate() const;
    void setDelegate(QQmlComponent *delegate);

    qreal columnSpacing() const;
    void setColumnSpacing(qreal columnSpacing);

    qreal rowSpacing() const;
    void setRowSpacing(qreal rowSpacing);

    int cacheBuffer() const;
    void setCacheBuffer(int);

    qreal displayMarginBeginning() const;
    void setDisplayMarginBeginning(qreal);

    qreal displayMarginEnd() const;
    void setDisplayMarginEnd(qreal);

Q_SIGNALS:
    void modelChanged();
    void delegateChanged();
    void columnSpacingChanged();
    void rowSpacingChanged();
    void cacheBufferChanged();
    void displayMarginBeginningChanged();
    void displayMarginEndChanged();

protected Q_SLOTS:
    void relayout();

protected:
    void updatePolish() override;
    void componentComplete() override;

    void releaseItem(QQuickItem *item);
    void setImplicitHeightDirty();

private Q_SLOTS:
    void itemCreated(int modelIndex, QObject *object);
    void onModelUpdated(const QQmlChangeSet &changeSet, bool reset);
    void onHeightChanged();

private:
    void createDelegateModel();
    void refill();
    bool addVisibleItems(qreal fillFromY, qreal fillToY, bool asynchronous);
    QQuickItem *createItem(int modelIndex, bool asynchronous);

    virtual void findBottomModelIndexToAdd(int *modelIndex, qreal *yPos) = 0;
    virtual void findTopModelIndexToAdd(int *modelIndex, qreal *yPos) = 0;
    virtual void addItemToView(int modelIndex, QQuickItem *item) = 0;
    virtual bool removeNonVisibleItems(qreal bufferFromY, qreal bufferToY) = 0;
    virtual void cleanupExistingItems() = 0;
    virtual void doRelayout() = 0;
    virtual void updateItemCulling(qreal visibleFromY, qreal visibleToY) = 0;
    virtual void calculateImplicitHeight() = 0;
    virtual void processModelRemoves(const QVector<QQmlChangeSet::Change> &removes) = 0;

    QQmlDelegateModel *m_delegateModel;

    // Index we are waiting because we requested it asynchronously
    int m_asyncRequestedIndex;

    int m_columnSpacing;
    int m_rowSpacing;
    int m_buffer;
    qreal m_displayMarginBeginning;
    qreal m_displayMarginEnd;
    bool m_needsRelayout;
    bool m_delegateValidated;
    bool m_implicitHeightDirty;
};

#endif

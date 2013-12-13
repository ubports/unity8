
#ifndef VERTICALJOURNAL_H
#define VERTICALJOURNAL_H

#include <QQuickItem>

class QAbstractItemModel;
class QQmlComponent;
#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
class QQuickVisualDataModel;
#else
class QQmlDelegateModel;
#endif

class VerticalJournal : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QAbstractItemModel *model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QQmlComponent *delegate READ delegate WRITE setDelegate NOTIFY delegateChanged)
    Q_PROPERTY(qreal columnWidth READ columnWidth WRITE setColumnWidth NOTIFY columnWidthChanged)
    Q_PROPERTY(qreal horizontalSpacing READ horizontalSpacing WRITE setHorizontalSpacing NOTIFY horizontalSpacingChanged)
    Q_PROPERTY(qreal verticalSpacing READ verticalSpacing WRITE setVerticalSpacing NOTIFY verticalSpacingChanged)
    Q_PROPERTY(qreal delegateCreationBegin READ delegateCreationBegin WRITE setDelegateCreationBegin NOTIFY delegateCreationBeginChanged RESET resetDelegateCreationBegin)
    Q_PROPERTY(qreal delegateCreationEnd READ delegateCreationEnd WRITE setDelegateCreationEnd NOTIFY delegateCreationEndChanged RESET resetDelegateCreationEnd)

friend class VerticalJournalTest;

public:
    VerticalJournal();

    QAbstractItemModel *model() const;
    void setModel(QAbstractItemModel *model);

    QQmlComponent *delegate() const;
    void setDelegate(QQmlComponent *delegate);

    qreal columnWidth() const;
    void setColumnWidth(qreal columnWidth);

    qreal horizontalSpacing() const;
    void setHorizontalSpacing(qreal horizontalSpacing);

    qreal verticalSpacing() const;
    void setVerticalSpacing(qreal verticalSpacing);

    qreal delegateCreationBegin() const;
    void setDelegateCreationBegin(qreal);
    void resetDelegateCreationBegin();

    qreal delegateCreationEnd() const;
    void setDelegateCreationEnd(qreal);
    void resetDelegateCreationEnd();

Q_SIGNALS:
    void modelChanged();
    void delegateChanged();
    void columnWidthChanged();
    void horizontalSpacingChanged();
    void verticalSpacingChanged();
    void delegateCreationBeginChanged();
    void delegateCreationEndChanged();

protected:
    void updatePolish();
    void componentComplete();

private Q_SLOTS:
#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
    void itemCreated(int modelIndex, QQuickItem *item);
#else
    void itemCreated(int modelIndex, QObject *object);
#endif
    void relayout();
    void onHeightChanged();

private:
    class ViewItem
    {
        public:
            ViewItem(QQuickItem *item, int modelIndex) : m_item(item), m_modelIndex(modelIndex) {}
            qreal x() const { return m_item->x(); }
            qreal y() const { return m_item->y(); }
            qreal height() const { return m_item->height(); }
            bool operator<(const ViewItem &v) const { return m_modelIndex < v.m_modelIndex; }

            QQuickItem *m_item;
            int m_modelIndex;
    };

    void createDelegateModel();
    void refill();
    void findBottomModelIndexToAdd(int *modelIndex, double *yPos);
    void findTopModelIndexToAdd(int *modelIndex, double *yPos);
    bool addVisibleItems(qreal fillFrom, qreal fillTo, bool asynchronous);
    bool removeNonVisibleItems(qreal bufferFrom, qreal bufferTo);
    QQuickItem *createItem(int modelIndex, bool asynchronous);
    void positionItem(int modelIndex, QQuickItem *item);
    void doRelayout();

    void releaseItem(const ViewItem &item);

#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
    QQuickVisualDataModel *m_delegateModel;
#else
    QQmlDelegateModel *m_delegateModel;
#endif

    // Index we are waiting because we requested it asynchronously
    int m_asyncRequestedIndex;

    QVector<QList<ViewItem>> m_columnVisibleItems;
    QHash<int, int> m_indexColumnMap;
    int m_columnWidth;
    int m_horizontalSpacing;
    int m_verticalSpacing;
    qreal m_delegateCreationBegin;
    qreal m_delegateCreationEnd;
    bool m_delegateCreationBeginValid;
    bool m_delegateCreationEndValid;
    bool m_needsRelayout;
    bool m_delegateValidated;
    bool m_implicitHeightDirty;
};

#endif

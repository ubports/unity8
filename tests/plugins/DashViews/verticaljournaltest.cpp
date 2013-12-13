
#include <QQuickView>
#include <QtTestGui>
#include <QDebug>
#include <QGuiApplication>
#include <QQuickView>
#include <QtQml/qqml.h>
#include <QStringListModel>
#include <QQmlContext>
#include <private/qquickitem_p.h>

#include "verticaljournal.h"

class QHeightModel : public QStringListModel {
public:
    QHash<int, QByteArray> roleNames() const
    {
        QHash<int, QByteArray> roles;
        roles.insert(Qt::DisplayRole, "modelHeight");
        return roles;
    }
};

class VerticalJournalTest : public QObject
{
    Q_OBJECT

private:
    void verifyItem(const VerticalJournal::ViewItem &item, int modelIndex, qreal x, qreal y, bool visible)
    {
        QTRY_COMPARE(item.m_modelIndex, modelIndex);
        QTRY_COMPARE(item.x(), x);
        QTRY_COMPARE(item.y(), y);
        QTRY_COMPARE(item.height(), heightList[modelIndex].toDouble());
        QTRY_COMPARE(QQuickItemPrivate::get(item.m_item)->culled, !visible);
    }

    void checkInitialPositions()
    {
        QTRY_COMPARE(vj->m_columnVisibleItems.count(), 3);
        QTRY_COMPARE(vj->m_columnVisibleItems[0].count(), 5);
        QTRY_COMPARE(vj->m_columnVisibleItems[1].count(), 7);
        QTRY_COMPARE(vj->m_columnVisibleItems[2].count(), 6);
        verifyItem(vj->m_columnVisibleItems[0][0],  0,  10,  10, true);
        verifyItem(vj->m_columnVisibleItems[1][0],  1, 170,  10, true);
        verifyItem(vj->m_columnVisibleItems[2][0],  2, 330,  10, true);
        verifyItem(vj->m_columnVisibleItems[1][1],  3, 170,  70, true);
        verifyItem(vj->m_columnVisibleItems[1][2],  4, 170,  90, true);
        verifyItem(vj->m_columnVisibleItems[0][1],  5,  10, 120, true);
        verifyItem(vj->m_columnVisibleItems[1][3],  6, 170, 140, true);
        verifyItem(vj->m_columnVisibleItems[2][1],  7, 330, 145, true);
        verifyItem(vj->m_columnVisibleItems[0][2],  8,  10, 200, true);
        verifyItem(vj->m_columnVisibleItems[2][2],  9, 330, 265, true);
        verifyItem(vj->m_columnVisibleItems[2][3], 10, 330, 295, true);
        verifyItem(vj->m_columnVisibleItems[2][4], 11, 330, 325, true);
        verifyItem(vj->m_columnVisibleItems[1][4], 12, 170, 350, true);
        verifyItem(vj->m_columnVisibleItems[0][3], 13, 10,  370, true);
        verifyItem(vj->m_columnVisibleItems[2][5], 14, 330, 400, false);
        verifyItem(vj->m_columnVisibleItems[1][5], 15, 170, 440, false);
        verifyItem(vj->m_columnVisibleItems[0][4], 16,  10, 580, false);
        verifyItem(vj->m_columnVisibleItems[1][6], 17, 170, 580, false);
        QCOMPARE(vj->implicitHeight(), 990. + 2. * 990. / 18.);
    }

private Q_SLOTS:
    void initTestCase()
    {
        qmlRegisterType<QAbstractItemModel>();
        qmlRegisterType<VerticalJournal>("Journals", 0, 1, "VerticalJournal");
    }

    void init()
    {
        view = new QQuickView();
        view->setResizeMode(QQuickView::SizeRootObjectToView);

        model = new QHeightModel();
        heightList.clear();
        heightList << "100" << "50" << "125" << "10" << "40" << "70" << "200" << "110" << "160" << "20" << "20" << "65" << "80" << "200" << "300" << "130" << "400" << "300" << "500" << "10";
        model->setStringList(heightList);

        view->rootContext()->setContextProperty("theModel", model);

        view->setSource(QUrl::fromLocalFile(DASHVIEWSTEST_FOLDER "/verticaljournaltest.qml"));

        view->show();
        view->resize(490, 400);
        QTest::qWaitForWindowExposed(view);

        vj = view->rootObject()->findChild<VerticalJournal*>();
        vj->setModel(model);

        checkInitialPositions();
    }

    void cleanup()
    {
        delete view;
        delete model;
    }

    void testWidthResize()
    {
        view->resize(649, 400);

        // This is exactly the same block as above as nothing changed, just white space on the right
        checkInitialPositions();

        view->resize(650, 400);

        QTRY_COMPARE(vj->m_columnVisibleItems.count(), 4);
        QTRY_COMPARE(vj->m_columnVisibleItems[0].count(), 4);
        QTRY_COMPARE(vj->m_columnVisibleItems[1].count(), 7);
        QTRY_COMPARE(vj->m_columnVisibleItems[2].count(), 4);
        QTRY_COMPARE(vj->m_columnVisibleItems[3].count(), 5);
        verifyItem(vj->m_columnVisibleItems[0][0],  0,  10,  10, true);
        verifyItem(vj->m_columnVisibleItems[1][0],  1, 170,  10, true);
        verifyItem(vj->m_columnVisibleItems[2][0],  2, 330,  10, true);
        verifyItem(vj->m_columnVisibleItems[3][0],  3, 490,  10, true);
        verifyItem(vj->m_columnVisibleItems[3][1],  4, 490,  30, true);
        verifyItem(vj->m_columnVisibleItems[1][1],  5, 170,  70, true);
        verifyItem(vj->m_columnVisibleItems[3][2],  6, 490,  80, true);
        verifyItem(vj->m_columnVisibleItems[0][1],  7,  10, 120, true);
        verifyItem(vj->m_columnVisibleItems[2][1],  8, 330, 145, true);
        verifyItem(vj->m_columnVisibleItems[1][2],  9, 170, 150, true);
        verifyItem(vj->m_columnVisibleItems[1][3], 10, 170, 180, true);
        verifyItem(vj->m_columnVisibleItems[1][4], 11, 170, 210, true);
        verifyItem(vj->m_columnVisibleItems[0][2], 12,  10, 240, true);
        verifyItem(vj->m_columnVisibleItems[1][5], 13, 170, 285, true);
        verifyItem(vj->m_columnVisibleItems[3][3], 14, 490, 290, true);
        verifyItem(vj->m_columnVisibleItems[2][2], 15, 330, 315, true);
        verifyItem(vj->m_columnVisibleItems[0][3], 16,  10, 330, true);
        verifyItem(vj->m_columnVisibleItems[2][3], 17, 330, 455, false);
        verifyItem(vj->m_columnVisibleItems[1][6], 18, 170, 495, false);
        verifyItem(vj->m_columnVisibleItems[3][4], 19, 490, 600, false);
        QTRY_COMPARE(vj->implicitHeight(), 1005.);

        view->resize(490, 400);

        // This is exactly the same block as the first again
        checkInitialPositions();
    }

    void testHorizontalSpacing()
    {
        vj->setHorizontalSpacing(11);

        QTRY_COMPARE(vj->m_needsRelayout, false);
        QTRY_COMPARE(vj->m_columnVisibleItems.count(), 2);
        QTRY_COMPARE(vj->m_columnVisibleItems[0].count(), 7);
        QTRY_COMPARE(vj->m_columnVisibleItems[1].count(), 7);
        verifyItem(vj->m_columnVisibleItems[0][0],  0,  11,  10, true);
        verifyItem(vj->m_columnVisibleItems[1][0],  1, 172,  10, true);
        verifyItem(vj->m_columnVisibleItems[1][1],  2, 172,  70, true);
        verifyItem(vj->m_columnVisibleItems[0][1],  3,  11, 120, true);
        verifyItem(vj->m_columnVisibleItems[0][2],  4,  11, 140, true);
        verifyItem(vj->m_columnVisibleItems[0][3],  5,  11, 190, true);
        verifyItem(vj->m_columnVisibleItems[1][2],  6, 172, 205, true);
        verifyItem(vj->m_columnVisibleItems[0][4],  7,  11, 270, true);
        verifyItem(vj->m_columnVisibleItems[0][5],  8,  11, 390, true);
        verifyItem(vj->m_columnVisibleItems[1][3],  9, 172, 415, false);
        verifyItem(vj->m_columnVisibleItems[1][4], 10, 172, 445, false);
        verifyItem(vj->m_columnVisibleItems[1][5], 11, 172, 475, false);
        verifyItem(vj->m_columnVisibleItems[1][6], 12, 172, 550, false);
        verifyItem(vj->m_columnVisibleItems[0][6], 13,  11, 560, false);
        QCOMPARE(vj->implicitHeight(), 770. + 6. * 770. / 14.);

        vj->setHorizontalSpacing(10);
        QTRY_COMPARE(vj->m_needsRelayout, false);

        // This is exactly the same block as the first again
        checkInitialPositions();
    }

    void testVerticalSpacing()
    {
        vj->setVerticalSpacing(11);

        QTRY_COMPARE(vj->m_needsRelayout, false);
        QTRY_COMPARE(vj->m_columnVisibleItems.count(), 3);
        QTRY_COMPARE(vj->m_columnVisibleItems[0].count(), 5);
        QTRY_COMPARE(vj->m_columnVisibleItems[1].count(), 7);
        QTRY_COMPARE(vj->m_columnVisibleItems[2].count(), 6);
        verifyItem(vj->m_columnVisibleItems[0][0],  0,  10,  11, true);
        verifyItem(vj->m_columnVisibleItems[1][0],  1, 170,  11, true);
        verifyItem(vj->m_columnVisibleItems[2][0],  2, 330,  11, true);
        verifyItem(vj->m_columnVisibleItems[1][1],  3, 170,  72, true);
        verifyItem(vj->m_columnVisibleItems[1][2],  4, 170,  93, true);
        verifyItem(vj->m_columnVisibleItems[0][1],  5,  10, 122, true);
        verifyItem(vj->m_columnVisibleItems[1][3],  6, 170, 144, true);
        verifyItem(vj->m_columnVisibleItems[2][1],  7, 330, 147, true);
        verifyItem(vj->m_columnVisibleItems[0][2],  8,  10, 203, true);
        verifyItem(vj->m_columnVisibleItems[2][2],  9, 330, 268, true);
        verifyItem(vj->m_columnVisibleItems[2][3], 10, 330, 299, true);
        verifyItem(vj->m_columnVisibleItems[2][4], 11, 330, 330, true);
        verifyItem(vj->m_columnVisibleItems[1][4], 12, 170, 355, true);
        verifyItem(vj->m_columnVisibleItems[0][3], 13,  10, 374, true);
        verifyItem(vj->m_columnVisibleItems[2][5], 14, 330, 406, false);
        verifyItem(vj->m_columnVisibleItems[1][5], 15, 170, 446, false);
        verifyItem(vj->m_columnVisibleItems[0][4], 16,  10, 585, false);
        verifyItem(vj->m_columnVisibleItems[1][6], 17, 170, 587, false);
        QCOMPARE(vj->implicitHeight(), 990. + 2. * 990. / 18.);

        vj->setVerticalSpacing(10);
        QTRY_COMPARE(vj->m_needsRelayout, false);

        // This is exactly the same block as the first again
        checkInitialPositions();
    }

    void testDelegateCreationRanges()
    {
        vj->setDelegateCreationBegin(200);
        vj->setDelegateCreationEnd(view->height());

        QTRY_COMPARE(vj->m_columnVisibleItems.count(), 3);
        QTRY_COMPARE(vj->m_columnVisibleItems[0].count(), 4);
        QTRY_COMPARE(vj->m_columnVisibleItems[1].count(), 4);
        QTRY_COMPARE(vj->m_columnVisibleItems[2].count(), 6);
        verifyItem(vj->m_columnVisibleItems[0][0],  0,  10,  10, false);
        verifyItem(vj->m_columnVisibleItems[2][0],  2, 330,  10, false);
        verifyItem(vj->m_columnVisibleItems[1][0],  4, 170,  90, false);
        verifyItem(vj->m_columnVisibleItems[0][1],  5,  10, 120, false);
        verifyItem(vj->m_columnVisibleItems[1][1],  6, 170, 140, true);
        verifyItem(vj->m_columnVisibleItems[2][1],  7, 330, 145, true);
        verifyItem(vj->m_columnVisibleItems[0][2],  8,  10, 200, true);
        verifyItem(vj->m_columnVisibleItems[2][2],  9, 330, 265, true);
        verifyItem(vj->m_columnVisibleItems[2][3], 10, 330, 295, true);
        verifyItem(vj->m_columnVisibleItems[2][4], 11, 330, 325, true);
        verifyItem(vj->m_columnVisibleItems[1][2], 12, 170, 350, true);
        verifyItem(vj->m_columnVisibleItems[0][3], 13, 10,  370, true);
        verifyItem(vj->m_columnVisibleItems[2][5], 14, 330, 400, false);
        verifyItem(vj->m_columnVisibleItems[1][3], 15, 170, 440, false);
        QCOMPARE(vj->implicitHeight(), 710. + 4. * 710. / 16.);

        vj->resetDelegateCreationBegin();
        vj->resetDelegateCreationEnd();

        // This is exactly the same block as the first again
        checkInitialPositions();
    }


    void testColumnWidthChange()
    {
        vj->setColumnWidth(200);
        QTRY_COMPARE(vj->m_columnVisibleItems.count(), 2);
        QTRY_COMPARE(vj->m_columnVisibleItems[0].count(), 7);
        QTRY_COMPARE(vj->m_columnVisibleItems[1].count(), 7);
        verifyItem(vj->m_columnVisibleItems[0][0],  0,  10,  10, true);
        verifyItem(vj->m_columnVisibleItems[1][0],  1, 220,  10, true);
        verifyItem(vj->m_columnVisibleItems[1][1],  2, 220,  70, true);
        verifyItem(vj->m_columnVisibleItems[0][1],  3,  10, 120, true);
        verifyItem(vj->m_columnVisibleItems[0][2],  4,  10, 140, true);
        verifyItem(vj->m_columnVisibleItems[0][3],  5,  10, 190, true);
        verifyItem(vj->m_columnVisibleItems[1][2],  6, 220, 205, true);
        verifyItem(vj->m_columnVisibleItems[0][4],  7,  10, 270, true);
        verifyItem(vj->m_columnVisibleItems[0][5],  8,  10, 390, true);
        verifyItem(vj->m_columnVisibleItems[1][3],  9, 220, 415, false);
        verifyItem(vj->m_columnVisibleItems[1][4], 10, 220, 445, false);
        verifyItem(vj->m_columnVisibleItems[1][5], 11, 220, 475, false);
        verifyItem(vj->m_columnVisibleItems[1][6], 12, 220, 550, false);
        verifyItem(vj->m_columnVisibleItems[0][6], 13,  10, 560, false);
        QCOMPARE(vj->implicitHeight(), 770. + 6. * 770. / 14.);

        vj->setColumnWidth(150);

        // This is exactly the same block as the first again
        checkInitialPositions();
    }

    void testChangeModel()
    {
        QHeightModel model2;
        QStringList list2;
        list2 << "100" << "50" << "25" << "25" << "50" << "50";
        model2.setStringList(list2);
        vj->setModel(&model2);
        heightList = list2;

        QTRY_COMPARE(vj->m_columnVisibleItems.count(), 3);
        QTRY_COMPARE(vj->m_columnVisibleItems[0].count(), 1);
        QTRY_COMPARE(vj->m_columnVisibleItems[1].count(), 2);
        QTRY_COMPARE(vj->m_columnVisibleItems[2].count(), 3);
        verifyItem(vj->m_columnVisibleItems[0][0],  0,  10, 10, true);
        verifyItem(vj->m_columnVisibleItems[1][0],  1, 170, 10, true);
        verifyItem(vj->m_columnVisibleItems[2][0],  2, 330, 10, true);
        verifyItem(vj->m_columnVisibleItems[2][1],  3, 330, 45, true);
        verifyItem(vj->m_columnVisibleItems[1][1],  4, 170, 70, true);
        verifyItem(vj->m_columnVisibleItems[2][2],  5, 330, 80, true);
    }

private:
    QQuickView *view;
    VerticalJournal *vj;
    QStringList heightList;
    QHeightModel *model;
};

QTEST_MAIN(VerticalJournalTest)

#include "verticaljournaltest.moc"

/*
 * Copyright (C) 2017 Canonical, Ltd.
 * Copyright (C) 2019 UBports Foundation
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

// There is a companion set of QMLTests for TLWM in tst_QMLTopLevelWindowModel.qml.

#include <QtTest/QtTest>
#include <QSignalSpy>

// WindowManager plugin
#include <TopLevelWindowModel.h>
#include <Window.h>

#include "UnityApplicationMocks.h"

class tst_TopLevelWindowModel : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void init(); // called right before each and every test function is executed
    void cleanup(); // called right after each and every test function is executed

    void singleSurfaceStartsHidden();
    void secondSurfaceIsHidden();
    void rootFocus();
    void rootFocusInhibit();

private:
    ApplicationManager *applicationManager{nullptr};
    SurfaceManager *surfaceManager{nullptr};
    TopLevelWindowModel *topLevelWindowModel{nullptr};
};

void tst_TopLevelWindowModel::init()
{
    applicationManager = new ApplicationManager;
    surfaceManager = new SurfaceManager;

    topLevelWindowModel = new TopLevelWindowModel;
    topLevelWindowModel->setApplicationManager(applicationManager);
    topLevelWindowModel->setSurfaceManager(surfaceManager);
}

void tst_TopLevelWindowModel::cleanup()
{
    delete topLevelWindowModel;
    topLevelWindowModel = nullptr;

    delete surfaceManager;
    surfaceManager = nullptr;

    delete applicationManager;
    applicationManager = nullptr;
}

void tst_TopLevelWindowModel::singleSurfaceStartsHidden()
{
    QCOMPARE(topLevelWindowModel->rowCount(), 0);

    auto application = static_cast<Application*>(applicationManager->startApplication(QString("hello-world"), QStringList()));

    QCOMPARE(topLevelWindowModel->rowCount(), 1);
    QCOMPARE((void*)topLevelWindowModel->windowAt(0)->surface(), (void*)nullptr);

    auto surface = new MirSurface;
    surface->m_state = Mir::HiddenState;
    application->m_surfaceList.addSurface(surface);
    Q_EMIT surfaceManager->surfaceCreated(surface);

    QCOMPARE(topLevelWindowModel->rowCount(), 1);
    // not showing the surface as it's still hidden
    QCOMPARE((void*)topLevelWindowModel->windowAt(0)->surface(), (void*)nullptr);

    surface->requestState(Mir::RestoredState);

    QCOMPARE(topLevelWindowModel->rowCount(), 1);
    // Now that the surface is no longer hidden, TopLevelWindowModel should expose it.
    QCOMPARE((void*)topLevelWindowModel->windowAt(0)->surface(), (void*)surface);
}

void tst_TopLevelWindowModel::secondSurfaceIsHidden()
{
    QCOMPARE(topLevelWindowModel->rowCount(), 0);

    auto application = static_cast<Application*>(applicationManager->startApplication(QString("hello-world"), QStringList()));

    QCOMPARE(topLevelWindowModel->rowCount(), 1);
    QCOMPARE((void*)topLevelWindowModel->windowAt(0)->surface(), (void*)nullptr);

    auto firstSurface = new MirSurface;
    application->m_surfaceList.addSurface(firstSurface);
    Q_EMIT surfaceManager->surfaceCreated(firstSurface);

    QCOMPARE(topLevelWindowModel->rowCount(), 1);
    QCOMPARE((void*)topLevelWindowModel->windowAt(0)->surface(), (void*)firstSurface);

    auto secondSurface = new MirSurface;
    secondSurface->m_state = Mir::HiddenState;
    application->m_surfaceList.addSurface(secondSurface);
    Q_EMIT surfaceManager->surfaceCreated(secondSurface);

    // still only the first surface is exposed by TopLevelWindowModel
    QCOMPARE(topLevelWindowModel->rowCount(), 1);
    QCOMPARE((void*)topLevelWindowModel->windowAt(0)->surface(), (void*)firstSurface);

    secondSurface->requestState(Mir::RestoredState);

    // now the second surface finally shows up
    QCOMPARE(topLevelWindowModel->rowCount(), 2);
    QCOMPARE((void*)topLevelWindowModel->windowAt(0)->surface(), (void*)secondSurface);
    QCOMPARE((void*)topLevelWindowModel->windowAt(1)->surface(), (void*)firstSurface);

    secondSurface->requestState(Mir::HiddenState);

    // and it's gone again
    QCOMPARE(topLevelWindowModel->rowCount(), 1);
    QCOMPARE((void*)topLevelWindowModel->windowAt(0)->surface(), (void*)firstSurface);
}

// Ensure that rootFocus unfocuses and refocuses windows
void tst_TopLevelWindowModel::rootFocus()
{
    applicationManager->startApplication(QString("hello-world"), QStringList());

    // We need to keep the window's surface null, unlike the other tests,
    // because then the TLWM assumes that the window is unknown to MirAL and
    // handles focus changes itself. If MirAL and QtMir are behaving properly,
    // they mirror this behavior for windows with surfaces.
    QCOMPARE(topLevelWindowModel->rowCount(), 1);
    QCOMPARE((void*)topLevelWindowModel->windowAt(0)->surface(), (void*)nullptr);
    auto dummyWindow = topLevelWindowModel->windowAt(0);

    auto rootFocusChangedSpy = new QSignalSpy(topLevelWindowModel, &TopLevelWindowModel::rootFocusChanged);

    // Unsetting rootFocus will remove focus from the dummy window
    topLevelWindowModel->setRootFocus(false);
    QVERIFY(!topLevelWindowModel->rootFocus());
    QVERIFY(!dummyWindow->focused());
    QCOMPARE(rootFocusChangedSpy->count(), 1);

    // Setting rootFocus will add focus back to the dummy window
    topLevelWindowModel->setRootFocus(true);
    QVERIFY(topLevelWindowModel->rootFocus());
    QCOMPARE((void*)topLevelWindowModel->focusedWindow(), (void*)dummyWindow);
    QCOMPARE(rootFocusChangedSpy->count(), 2);
}

// Ensure that rootFocus does not refocus a window if we focus another
void tst_TopLevelWindowModel::rootFocusInhibit()
{
    applicationManager->startApplication(QString("1"), QStringList());

    auto dummyWindow1 = topLevelWindowModel->windowAt(0);

    // Unsetting rootFocus will remove focus from the dummy window
    topLevelWindowModel->setRootFocus(false);
    QVERIFY(!topLevelWindowModel->rootFocus());
    QVERIFY(!dummyWindow1->focused());

    // Starting an Application will cause a pendingActivation, setting
    // rootFocus but preventing the original window from becoming refocused
    auto dummyWindow1FocusSpy = new QSignalSpy(dummyWindow1, &Window::focusedChanged);

    // Saying that dummyWindow1 is different than dummyWindow2 will have to do
    // since Applications don't know their Windows and we don't mock the other
    // way around.
    applicationManager->startApplication(QString("2"), QStringList());
    auto dummyWindow2 = topLevelWindowModel->windowAt(0);
    QVERIFY((void*)dummyWindow1 != (void*)dummyWindow2);

    QVERIFY(topLevelWindowModel->rootFocus());
    QVERIFY(!dummyWindow1->focused());
    QVERIFY(dummyWindow2->focused());
    QVERIFY(dummyWindow1FocusSpy->empty());
}

QTEST_MAIN(tst_TopLevelWindowModel)

#include "tst_TopLevelWindowModel.moc"

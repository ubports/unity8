/*
 * Copyright (C) 2017 Canonical, Ltd.
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

#include <QtTest/QtTest>

// WindowManager plugin
#include <TopLevelWindowModel.h>
#include <Window.h>
#include <WindowManagerObjects.h>
#include <Workspace.h>
#include <WorkspaceManager.h>

#include "UnityApplicationMocks.h"
#include "wmpolicyinterface.h"


class tst_TopLevelWindowModel : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void init(); // called right before each and every test function is executed
    void cleanup(); // called right after each and every test function is executed

    void singleSurfaceStartsHidden();
    void secondSurfaceIsHidden();

private:
    Workspace* workspace{nullptr};
    ApplicationManager *applicationManager{nullptr};
    SurfaceManager *surfaceManager{nullptr};
    TopLevelWindowModel *topLevelWindowModel{nullptr};
};

void tst_TopLevelWindowModel::init()
{
    wmPolicyInterface = new WindowManagementPolicy();

    applicationManager = new ApplicationManager;
    surfaceManager = new SurfaceManager;
    WindowManagerObjects::instance()->setApplicationManager(applicationManager);
    WindowManagerObjects::instance()->setSurfaceManager(surfaceManager);

    workspace = WorkspaceManager::instance()->createWorkspace();
    topLevelWindowModel = workspace->windowModel();
}

void tst_TopLevelWindowModel::cleanup()
{
    delete workspace;
    workspace = nullptr;

    delete surfaceManager;
    surfaceManager = nullptr;

    delete applicationManager;
    applicationManager = nullptr;

    delete wmPolicyInterface;
    wmPolicyInterface = nullptr;
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
    Q_EMIT surfaceManager->surfacesAddedToWorkspace(workspace->workspace(), {surface});

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
    Q_EMIT surfaceManager->surfacesAddedToWorkspace(workspace->workspace(), {firstSurface});

    QCOMPARE(topLevelWindowModel->rowCount(), 1);
    QCOMPARE((void*)topLevelWindowModel->windowAt(0)->surface(), (void*)firstSurface);

    auto secondSurface = new MirSurface;
    secondSurface->m_state = Mir::HiddenState;
    application->m_surfaceList.addSurface(secondSurface);
    Q_EMIT surfaceManager->surfacesAddedToWorkspace(workspace->workspace(), {secondSurface});

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

QTEST_MAIN(tst_TopLevelWindowModel)

#include "tst_TopLevelWindowModel.moc"

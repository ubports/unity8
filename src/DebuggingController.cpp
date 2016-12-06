/*
 * Copyright (C) 2016 - Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License, as
 * published by the  Free Software Foundation; either version 2.1 or 3.0
 * of the License.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the applicable version of the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of both the GNU Lesser General Public
 * License along with this program. If not, see <http://www.gnu.org/licenses/>
 */

#include "DebuggingController.h"

#include <QGuiApplication>
#include <QWindow>
#include <private/qquickwindow_p.h>
#include <private/qabstractanimationjob_p.h>
#include <private/qquickitem_p.h>
#include <private/qsgrenderer_p.h>

DebuggingController::DebuggingController(QObject *parent):
    UnityDBusObject(QStringLiteral("/com/canonical/Unity8/Debugging"), QStringLiteral("com.canonical.Unity8"), true, parent)
{
}

void DebuggingController::SetSceneGraphVisualizer(const QString &visualizer)
{
    Q_FOREACH (QWindow *window, QGuiApplication::allWindows()) {
        QQuickWindow* qquickWindow = qobject_cast<QQuickWindow*>(window);
        if (qquickWindow) {

#if QT_VERSION >= QT_VERSION_CHECK(5, 5, 0)
            // Qt does some performance optimizations that break custom render modes.
            // Thus the optimizations are only applied if there is no custom render mode set.
            // So we need to make the scenegraph recheck whether a custom render mode is set.
            // We do this by simply recreating the renderer.
            QMutexLocker lock(&m_renderModeMutex);
            m_pendingRenderMode = visualizer;
            connect(qquickWindow, &QQuickWindow::beforeSynchronizing, this, &DebuggingController::applyRenderMode, Qt::DirectConnection);
#else
            QQuickWindowPrivate *winPriv = QQuickWindowPrivate::get(qquickWindow);
            winPriv->customRenderMode = visualizer.toLatin1();
#endif
            qquickWindow->update();
        }
    }
}

void DebuggingController::applyRenderMode() {
    qDebug() << "applyRenderMode called" << sender();
    QQuickWindow *qquickWindow = dynamic_cast<QQuickWindow*>(sender());
    qDebug() << "window is" << qquickWindow << sender() << sender()->metaObject()->className();

    QMutexLocker lock(&m_renderModeMutex);
    disconnect(qquickWindow, &QQuickWindow::beforeSynchronizing, this, &DebuggingController::applyRenderMode);

    qDebug() << "mutex locked";
#if QT_VERSION >= QT_VERSION_CHECK(5, 5, 0)
    QQuickWindowPrivate *winPriv = QQuickWindowPrivate::get(qquickWindow);
    QQuickItemPrivate *contentPriv = QQuickItemPrivate::get(qquickWindow->contentItem());
    qDebug() << "winPriv is" << winPriv << "contentPriv is" << contentPriv;
    QSGNode *rootNode = contentPriv->itemNode();
    while (rootNode->parent())
        rootNode = rootNode->parent();

    qDebug() << "rootnode is" << rootNode;
    winPriv->customRenderMode = m_pendingRenderMode.toLatin1();
    delete winPriv->renderer;
    qDebug() << "renderer deleted";
    winPriv->renderer = winPriv->context->createRenderer();
    qDebug() << "new renderer created";
    winPriv->renderer->setRootNode(static_cast<QSGRootNode *>(rootNode));
    qDebug() << "setting back old rootNode. done";
#endif
}

void DebuggingController::SetSlowAnimations(bool slowAnimations)
{
    QUnifiedTimer::instance()->setSlowModeEnabled(slowAnimations);
}

void DebuggingController::SetLoggingFilterRules(const QString &filterRules)
{
    QLoggingCategory::setFilterRules(filterRules);
}

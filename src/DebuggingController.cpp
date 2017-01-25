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


class ApplySceneGraphVisualizationJob : public QRunnable
{
public:
    ApplySceneGraphVisualizationJob(QQuickWindow *window, QByteArray renderMode)
        : m_window(window), m_renderMode(renderMode){}
    void run() override
    {
        qDebug() << "Setting custom render mode to:" << m_renderMode;

        QQuickWindowPrivate *winPriv = QQuickWindowPrivate::get(m_window);

        winPriv->customRenderMode = m_renderMode;
        delete winPriv->renderer;
        winPriv->renderer = nullptr;

        QTimer::singleShot(10, m_window, &QQuickWindow::update); // force another frame
    }

    QQuickWindow *m_window;
    QByteArray m_renderMode;
};

DebuggingController::DebuggingController(QObject *parent):
    UnityDBusObject(QStringLiteral("/com/canonical/Unity8/Debugging"), QStringLiteral("com.canonical.Unity8"), true, parent)
{
}

void DebuggingController::SetSceneGraphVisualizer(const QString &visualizer)
{
    QByteArray pendingRenderMode;
    QStringList supportedRenderModes = {"clip", "overdraw", "changes", "batches"};
    if (supportedRenderModes.contains(visualizer)) {
        pendingRenderMode = visualizer.toLatin1();
    }

    Q_FOREACH (QWindow *window, QGuiApplication::allWindows()) {
        QQuickWindow* qquickWindow = qobject_cast<QQuickWindow*>(window);
        if (qquickWindow) {

#if QT_VERSION >= QT_VERSION_CHECK(5, 5, 0)
            // Qt does some performance optimizations that break custom render modes.
            // Thus the optimizations are only applied if there is no custom render mode set.
            // So we need to make the scenegraph recheck whether a custom render mode is set.
            // We do this by simply recreating the renderer.
            qquickWindow->scheduleRenderJob(new ApplySceneGraphVisualizationJob(qquickWindow, pendingRenderMode),
                                            QQuickWindow::AfterSwapStage);
#else
            QQuickWindowPrivate *winPriv = QQuickWindowPrivate::get(qquickWindow);
            winPriv->customRenderMode = visualizer.toLatin1();
#endif
            qquickWindow->update();
        }
    }
}

void DebuggingController::SetSlowAnimations(bool slowAnimations)
{
    QUnifiedTimer::instance()->setSlowModeEnabled(slowAnimations);
}

void DebuggingController::SetLoggingFilterRules(const QString &filterRules)
{
    QLoggingCategory::setFilterRules(filterRules);
}

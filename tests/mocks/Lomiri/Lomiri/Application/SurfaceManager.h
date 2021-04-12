/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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

#ifndef SURFACEMANAGER_H
#define SURFACEMANAGER_H

#include <QObject>

#include <lomiri/shell/application/SurfaceManagerInterface.h>
#include <miral/window.h>

#include "MirSurface.h"
#include "VirtualKeyboard.h"

class ApplicationInfo;

struct WindowWrapper {
    miral::Window window;
    std::shared_ptr<mir::scene::Surface> session{nullptr}; // Keeps the window surface alive.
    bool operator==(const WindowWrapper& other) const {  return window==other.window; }
};
uint qHash(const WindowWrapper &key, uint seed = 0);

class SurfaceManager : public lomiri::shell::application::SurfaceManagerInterface
{
    Q_OBJECT
    Q_PROPERTY(int newSurfaceMinimumWidth READ newSurfaceMinimumWidth WRITE setNewSurfaceMinimumWidth NOTIFY newSurfaceMinimumWidthChanged)
    Q_PROPERTY(int newSurfaceMaximumWidth READ newSurfaceMaximumWidth WRITE setNewSurfaceMaximumWidth NOTIFY newSurfaceMaximumWidthChanged)
    Q_PROPERTY(int newSurfaceMinimumHeight READ newSurfaceMinimumHeight WRITE setNewSurfaceMinimumHeight NOTIFY newSurfaceMinimumHeightChanged)
    Q_PROPERTY(int newSurfaceMaximumHeight READ newSurfaceMaximumHeight WRITE setNewSurfaceMaximumHeight NOTIFY newSurfaceMaximumHeightChanged)
    Q_PROPERTY(int newSurfaceWidthIncrement READ newSurfaceWidthIncrement WRITE setNewSurfaceWidthIncrement NOTIFY newSurfaceWidthIncrementChanged)
    Q_PROPERTY(int newSurfaceHeightIncrement READ newSurfaceHeightIncrement WRITE setNewSurfaceHeightIncrement NOTIFY newSurfaceHeightIncrementChanged)

public:
    explicit SurfaceManager(QObject *parent = 0);
    virtual ~SurfaceManager();

    static SurfaceManager *instance();

    // SurfaceManagerInterface
    void raise(lomiri::shell::application::MirSurfaceInterface *surface) override;
    void activate(lomiri::shell::application::MirSurfaceInterface *surface) override;

    void forEachSurfaceInWorkspace(const std::shared_ptr<miral::Workspace> &workspace,
                                   const std::function<void(lomiri::shell::application::MirSurfaceInterface*)> &callback) override;
    void moveSurfaceToWorkspace(lomiri::shell::application::MirSurfaceInterface* surface,
                                const std::shared_ptr<miral::Workspace> &workspace) override;
    void moveWorkspaceContentToWorkspace(const std::shared_ptr<miral::Workspace> &to,
                                         const std::shared_ptr<miral::Workspace> &from) override;

    Q_INVOKABLE MirSurface* createSurface(const QString& name,
                                  Mir::Type type,
                                  Mir::State state,
                                  MirSurface *parentSurface,
                                  const QUrl &screenshot,
                                  const QUrl &qmlFilePath = QUrl());


    void notifySurfaceCreated(lomiri::shell::application::MirSurfaceInterface *);

    int newSurfaceMinimumWidth() const { return m_newSurfaceMinimumWidth; }
    void setNewSurfaceMinimumWidth(int value);

    int newSurfaceMaximumWidth() const { return m_newSurfaceMaximumWidth; }
    void setNewSurfaceMaximumWidth(int value);

    int newSurfaceMinimumHeight() const { return m_newSurfaceMinimumHeight; }
    void setNewSurfaceMinimumHeight(int value);

    int newSurfaceMaximumHeight() const { return m_newSurfaceMaximumHeight; }
    void setNewSurfaceMaximumHeight(int value);

    int newSurfaceWidthIncrement() const { return m_newSurfaceWidthIncrement; }
    void setNewSurfaceWidthIncrement(int);

    int newSurfaceHeightIncrement() const { return m_newSurfaceHeightIncrement; }
    void setNewSurfaceHeightIncrement(int);

public Q_SLOTS:
    void createInputMethodSurface();
    void releaseInputMethodSurface();

Q_SIGNALS:
    void newSurfaceMinimumWidthChanged(int value);
    void newSurfaceMaximumWidthChanged(int value);
    void newSurfaceMinimumHeightChanged(int value);
    void newSurfaceMaximumHeightChanged(int value);
    void newSurfaceWidthIncrementChanged(int value);
    void newSurfaceHeightIncrementChanged(int value);

private Q_SLOTS:
    void onStateRequested(MirSurface *surface, Mir::State state);
    void onSurfaceDestroyed(MirSurface *surface);

private:
    void doRaise(lomiri::shell::application::MirSurfaceInterface *surface);
    void focusFirstAvailableSurface();
    void registerSurface(MirSurface *surface);
    lomiri::shell::application::MirSurfaceInterface* surfaceFor(const miral::Window &window) const;
    QVector<lomiri::shell::application::MirSurfaceInterface*> surfacesFor(const std::vector<miral::Window> &windows) const;
    miral::Window windowFor(lomiri::shell::application::MirSurfaceInterface* surface) const;

    static SurfaceManager *m_instance;

    int m_newSurfaceMinimumWidth{0};
    int m_newSurfaceMaximumWidth{0};
    int m_newSurfaceMinimumHeight{0};
    int m_newSurfaceMaximumHeight{0};
    int m_newSurfaceWidthIncrement{1};
    int m_newSurfaceHeightIncrement{1};

    MirSurface *m_focusedSurface{nullptr};
    bool m_underModification{false};

    QList<MirSurface*> m_surfaces;

    QHash<WindowWrapper, lomiri::shell::application::MirSurfaceInterface*> m_windowToSurface;
    QHash<lomiri::shell::application::MirSurfaceInterface*, WindowWrapper> m_surfaceToWindow;

    VirtualKeyboard *m_virtualKeyboard{nullptr};
};

#endif // SURFACEMANAGER_H

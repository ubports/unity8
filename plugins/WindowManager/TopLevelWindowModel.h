/*
 * Copyright (C) 2016-2017 Canonical, Ltd.
 * Copyright 2019 UBports Foundation
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef TOPLEVELWINDOWMODEL_H
#define TOPLEVELWINDOWMODEL_H

#include <QAbstractListModel>
#include <QAtomicInteger>
#include <QLoggingCategory>

#include <memory>

#include "WindowManagerGlobal.h"

Q_DECLARE_LOGGING_CATEGORY(TOPLEVELWINDOWMODEL)

class Window;
class Workspace;

namespace miral { class Workspace; }

namespace lomiri {
    namespace shell {
        namespace application {
            class ApplicationInfoInterface;
            class ApplicationManagerInterface;
            class MirSurfaceInterface;
            class SurfaceManagerInterface;
        }
    }
}

/**
 * @brief A model of top-level surfaces
 *
 * It's an abstraction of top-level application windows.
 *
 * When an entry first appears, it normaly doesn't have a surface yet, meaning that the application is
 * still starting up. A shell should then display a splash screen or saved screenshot of the application
 * until its surface comes up.
 *
 * As applications can have multiple surfaces and you can also have entries without surfaces at all,
 * the only way to unambiguously refer to an entry in this model is through its id.
 */
class WINDOWMANAGERQML_EXPORT TopLevelWindowModel : public QAbstractListModel
{
    Q_OBJECT

    /**
     * @brief Number of top-level surfaces in this model
     *
     * This is the same as rowCount, added in order to keep compatibility with QML ListModels.
     */
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

    /**
     * @brief The input method surface, if any
     *
     * The surface of a onscreen keyboard (akak "virtual keyboard") would be kept here and not in the model itself.
     */
    Q_PROPERTY(lomiri::shell::application::MirSurfaceInterface* inputMethodSurface READ inputMethodSurface NOTIFY inputMethodSurfaceChanged)

    /**
     * @brief The currently focused window, if any
     */
    Q_PROPERTY(Window* focusedWindow READ focusedWindow NOTIFY focusedWindowChanged)

    /**
      The id to be used on the next entry created
      Useful for tests
     */
    Q_PROPERTY(int nextId READ nextId)


   /**
     * @brief Sets whether a user Window or "nothing" should be focused
     *
     * This implementation of TLWM must have something focused. However, the
     * user may wish to have nothing in some cases - for example, when they
     * minimize all their windows on the desktop or unfocus the app they're
     * using by clicking the background or indicators.
     *
     * Unsetting rootFocus effectively focuses "nothing" by setting up a Window
     * that has no displayable Surfaces and bringing it into focus.
     *
     * Setting rootFocus attempts to focus the Window which was focused last -
     * unless another app is attempting to gain focus (as determined by
     * pendingActivation) and that's why we got rootFocus.
     *
     * If the previously-focused Window was closed before rootFocus was set,
     * the next available window will be focused.
     */
    Q_PROPERTY(bool rootFocus READ rootFocus WRITE setRootFocus NOTIFY rootFocusChanged)

public:
    /**
     * @brief The Roles supported by the model
     *
     * WindowRole - A Window.
     * ApplicationRole - An ApplicationInfoInterface
     */
    enum Roles {
        WindowRole = Qt::UserRole,
        ApplicationRole = Qt::UserRole + 1,
    };

    TopLevelWindowModel(Workspace* workspace);
    ~TopLevelWindowModel();

    // From QAbstractItemModel
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override {
        QHash<int, QByteArray> roleNames { {WindowRole, "window"},
                                           {ApplicationRole, "application"} };
        return roleNames;
    }

    // Own API;

    lomiri::shell::application::MirSurfaceInterface* inputMethodSurface() const;
    Window* focusedWindow() const;

    int nextId() const { return m_nextId.load(); }

public:
    /**
     * @brief Returns the surface at the given index
     *
     * It will be a nullptr if the application is still starting up and thus hasn't yet created
     * and drawn into a surface.
     *
     * Same as windowAt(index).surface()
     */
    Q_INVOKABLE lomiri::shell::application::MirSurfaceInterface *surfaceAt(int index) const;

    /**
     * @brief Returns the window at the given index
     *
     * Will always be valid
     */
    Q_INVOKABLE Window *windowAt(int index) const;

    /**
     * @brief Returns the application at the given index
     */
    Q_INVOKABLE lomiri::shell::application::ApplicationInfoInterface *applicationAt(int index) const;

    /**
     * @brief Returns the unique id of the element at the given index
     */
    Q_INVOKABLE int idAt(int index) const;

    /**
     * @brief Returns the index where the row with the given id is located
     *
     * Returns -1 if there's no row with the given id.
     */
    Q_INVOKABLE int indexForId(int id) const;

    /**
     * @brief Raises the row with the given id to the top of the window stack (index == count-1)
     */
    Q_INVOKABLE void raiseId(int id);

    /**
     * @brief Closes all windows, emits closedAllWindows when done
     */
    Q_INVOKABLE void closeAllWindows();

    /**
     * @brief Sets pending activation flag
     */
    Q_INVOKABLE void pendingActivation();

    void setApplicationManager(lomiri::shell::application::ApplicationManagerInterface*);
    void setSurfaceManager(lomiri::shell::application::SurfaceManagerInterface*);
    void setRootFocus(bool focus);
    bool rootFocus();

Q_SIGNALS:
    void countChanged();
    void inputMethodSurfaceChanged(lomiri::shell::application::MirSurfaceInterface* inputMethodSurface);
    void focusedWindowChanged(Window *focusedWindow);

    /**
     * @brief Emitted when the list changes
     *
     * Emitted when model gains an element, loses an element or when elements exchange positions.
     */
    void listChanged();

    void closedAllWindows();

    void rootFocusChanged();

private Q_SLOTS:
    void onSurfacesAddedToWorkspace(const std::shared_ptr<miral::Workspace>& workspace,
                                    const QVector<lomiri::shell::application::MirSurfaceInterface*> surfaces);
    void onSurfacesRaised(const QVector<lomiri::shell::application::MirSurfaceInterface*> &surfaces);

    void onModificationsStarted();
    void onModificationsEnded();

private:
    void doRaiseId(int id);
    int generateId();
    int nextFreeId(int candidateId, const int latestId);
    int nextId(int id) const;
    QString toString();
    int indexOf(lomiri::shell::application::MirSurfaceInterface *surface);

    void setInputMethodWindow(Window *window);
    void setFocusedWindow(Window *window);
    void removeInputMethodWindow();
    void deleteAt(int index);
    void removeAt(int index);
    void removeSurfaces(const QVector<lomiri::shell::application::MirSurfaceInterface *> surfaces);

    void addApplication(lomiri::shell::application::ApplicationInfoInterface *application);
    void removeApplication(lomiri::shell::application::ApplicationInfoInterface *application);

    void prependPlaceholder(lomiri::shell::application::ApplicationInfoInterface *application);
    void prependSurface(lomiri::shell::application::MirSurfaceInterface *surface,
                        lomiri::shell::application::ApplicationInfoInterface *application);
    void prependSurfaceHelper(lomiri::shell::application::MirSurfaceInterface *surface,
                              lomiri::shell::application::ApplicationInfoInterface *application);
    void prependWindow(Window *window, lomiri::shell::application::ApplicationInfoInterface *application);

    void connectWindow(Window *window);
    void connectSurface(lomiri::shell::application::MirSurfaceInterface *surface);

    void onSurfaceDied(lomiri::shell::application::MirSurfaceInterface *surface);
    void onSurfaceDestroyed(lomiri::shell::application::MirSurfaceInterface *surface);

    void move(int from, int to);

    void activateEmptyWindow(Window *window);

    void activateTopMostWindowWithoutId(int forbiddenId);
    void refreshWindows();
    void clear();

    Window *createWindow(lomiri::shell::application::MirSurfaceInterface *surface);
    Window *createWindowWithId(lomiri::shell::application::MirSurfaceInterface *surface, int id);
    Window *createNullWindow();

    struct ModelEntry {
        ModelEntry() {}
        ModelEntry(Window *window,
                   lomiri::shell::application::ApplicationInfoInterface *application)
            : window(window), application(application) {}
        Window *window{nullptr};
        lomiri::shell::application::ApplicationInfoInterface *application{nullptr};
        bool removeOnceSurfaceDestroyed{false};
    };

    QVector<ModelEntry> m_windowModel;
    Window* m_inputMethodWindow{nullptr};
    Window* m_focusedWindow{nullptr};
    Window* m_nullWindow;
    Workspace* m_workspace{nullptr};
    // track all the surfaces we've been told about.
    QSet<lomiri::shell::application::MirSurfaceInterface*> m_allSurfaces;
    Window* m_previousWindow{nullptr};
    bool m_pendingActivation;

    QAtomicInteger<int> m_nextId{1};

    lomiri::shell::application::ApplicationManagerInterface* m_applicationManager{nullptr};
    lomiri::shell::application::SurfaceManagerInterface *m_surfaceManager{nullptr};
    bool m_surfaceManagerBusy;

    enum ModelState {
        IdleState,
        InsertingState,
        RemovingState,
        MovingState,
        ResettingState
    };
    ModelState m_modelState{IdleState};

    // Valid between modificationsStarted and modificationsEnded
    bool m_focusedWindowCleared{false};

    bool m_closingAllApps{false};
};

#endif // TOPLEVELWINDOWMODEL_H

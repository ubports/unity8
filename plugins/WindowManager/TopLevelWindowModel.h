/*
 * Copyright (C) 2016-2017 Canonical, Ltd.
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
#include <QLoggingCategory>

#include "WindowManagerGlobal.h"

Q_DECLARE_LOGGING_CATEGORY(TOPLEVELWINDOWMODEL)

class Window;

namespace unity {
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
    Q_PROPERTY(unity::shell::application::MirSurfaceInterface* inputMethodSurface READ inputMethodSurface NOTIFY inputMethodSurfaceChanged)

    /**
     * @brief The currently focused window, if any
     */
    Q_PROPERTY(Window* focusedWindow READ focusedWindow NOTIFY focusedWindowChanged)

    Q_PROPERTY(unity::shell::application::SurfaceManagerInterface* surfaceManager
            READ surfaceManager
            WRITE setSurfaceManager
            NOTIFY surfaceManagerChanged)

    Q_PROPERTY(unity::shell::application::ApplicationManagerInterface* applicationManager
            READ applicationManager
            WRITE setApplicationManager
            NOTIFY applicationManagerChanged)

    /**
      The id to be used on the next entry created
      Useful for tests
     */
    Q_PROPERTY(int nextId READ nextId NOTIFY nextIdChanged)

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

    TopLevelWindowModel();

    // From QAbstractItemModel
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override {
        QHash<int, QByteArray> roleNames { {WindowRole, "window"},
                                           {ApplicationRole, "application"} };
        return roleNames;
    }

    // Own API

    unity::shell::application::MirSurfaceInterface* inputMethodSurface() const;
    Window* focusedWindow() const;

    unity::shell::application::ApplicationManagerInterface *applicationManager() const { return m_applicationManager; }
    void setApplicationManager(unity::shell::application::ApplicationManagerInterface*);

    unity::shell::application::SurfaceManagerInterface *surfaceManager() const { return m_surfaceManager; }
    void setSurfaceManager(unity::shell::application::SurfaceManagerInterface*);

    int nextId() const { return m_nextId; }

public:
    /**
     * @brief Returns the surface at the given index
     *
     * It will be a nullptr if the application is still starting up and thus hasn't yet created
     * and drawn into a surface.
     *
     * Same as windowAt(index).surface()
     */
    Q_INVOKABLE unity::shell::application::MirSurfaceInterface *surfaceAt(int index) const;

    /**
     * @brief Returns the window at the given index
     *
     * Will always be valid
     */
    Q_INVOKABLE Window *windowAt(int index) const;

    /**
     * @brief Returns the application at the given index
     */
    Q_INVOKABLE unity::shell::application::ApplicationInfoInterface *applicationAt(int index) const;

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

Q_SIGNALS:
    void countChanged();
    void inputMethodSurfaceChanged(unity::shell::application::MirSurfaceInterface* inputMethodSurface);
    void focusedWindowChanged(Window *focusedWindow);
    void applicationManagerChanged(unity::shell::application::ApplicationManagerInterface*);
    void surfaceManagerChanged(unity::shell::application::SurfaceManagerInterface*);

    /**
     * @brief Emitted when the list changes
     *
     * Emitted when model gains an element, loses an element or when elements exchange positions.
     */
    void listChanged();

    void nextIdChanged();

private Q_SLOTS:
    void onSurfaceCreated(unity::shell::application::MirSurfaceInterface *surface);
    void onSurfacesRaised(const QVector<unity::shell::application::MirSurfaceInterface*> &surfaces);

    void onModificationsStarted();
    void onModificationsEnded();

private:
    void doRaiseId(int id);
    int generateId();
    int nextFreeId(int candidateId, const int latestId);
    int nextId(int id) const;
    QString toString();
    int indexOf(unity::shell::application::MirSurfaceInterface *surface);

    void setInputMethodWindow(Window *window);
    void setFocusedWindow(Window *window);
    void removeInputMethodWindow();
    int findIndexOf(const unity::shell::application::MirSurfaceInterface *surface) const;
    void deleteAt(int index);
    void removeAt(int index);

    void addApplication(unity::shell::application::ApplicationInfoInterface *application);
    void removeApplication(unity::shell::application::ApplicationInfoInterface *application);

    void prependPlaceholder(unity::shell::application::ApplicationInfoInterface *application);
    void prependSurface(unity::shell::application::MirSurfaceInterface *surface,
                        unity::shell::application::ApplicationInfoInterface *application);
    void prependSurfaceHelper(unity::shell::application::MirSurfaceInterface *surface,
                              unity::shell::application::ApplicationInfoInterface *application);
    void prependWindow(Window *window, unity::shell::application::ApplicationInfoInterface *application);

    void connectWindow(Window *window);
    void connectSurface(unity::shell::application::MirSurfaceInterface *surface);

    void onSurfaceDied(unity::shell::application::MirSurfaceInterface *surface);
    void onSurfaceDestroyed(unity::shell::application::MirSurfaceInterface *surface);

    void move(int from, int to);

    void activateEmptyWindow(Window *window);

    void activateTopMostWindowWithoutId(int forbiddenId);

    Window *createWindow(unity::shell::application::MirSurfaceInterface *surface);

    struct ModelEntry {
        ModelEntry() {}
        ModelEntry(Window *window,
                   unity::shell::application::ApplicationInfoInterface *application)
            : window(window), application(application) {}
        Window *window{nullptr};
        unity::shell::application::ApplicationInfoInterface *application{nullptr};
        bool removeOnceSurfaceDestroyed{false};
    };

    QVector<ModelEntry> m_windowModel;
    Window* m_inputMethodWindow{nullptr};
    Window* m_focusedWindow{nullptr};

    int m_nextId{1};
    // Just something big enough that we don't risk running out of unused id numbers.
    // Not sure if QML int type supports something close to std::numeric_limits<int>::max() and
    // there's no reason to try out its limits.
    static const int m_maxId{1000000};

    unity::shell::application::ApplicationManagerInterface* m_applicationManager{nullptr};
    unity::shell::application::SurfaceManagerInterface *m_surfaceManager{nullptr};

    enum ModelState {
        IdleState,
        InsertingState,
        RemovingState,
        MovingState,
        ResettingState
    };
    ModelState m_modelState{IdleState};

    // Valid between modificationsStarted and modificationsEnded
    bool m_focusedWindowChanged{false};
    Window *m_newlyFocusedWindow{nullptr};
};

#endif // TOPLEVELWINDOWMODEL_H

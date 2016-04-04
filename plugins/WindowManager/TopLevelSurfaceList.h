/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#ifndef TOPLEVELSURFACELIST_H
#define TOPLEVELSURFACELIST_H

#include <QAbstractListModel>
#include <QList>
#include <QLoggingCategory>

Q_DECLARE_LOGGING_CATEGORY(UNITY_TOPSURFACELIST)

namespace unity {
    namespace shell {
        namespace application {
            class ApplicationInfoInterface;
            class MirSurfaceInterface;
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
class TopLevelSurfaceList : public QAbstractListModel
{

    Q_OBJECT

    /**
     * @brief A list model of applications.
     *
     * It's expected to have a role called "application" which returns a ApplicationInfoInterface
     */
    Q_PROPERTY(QAbstractListModel* applicationsModel READ applicationsModel
                                                     WRITE setApplicationsModel
                                                     NOTIFY applicationsModelChanged)

    /**
     * @brief Number of top-level surfaces in this model
     *
     * This is the same as rowCount, added in order to keep compatibility with QML ListModels.
     */
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

    /**
      The id to be used on the next entry created
      Useful for tests
     */
    Q_PROPERTY(int nextId READ nextId NOTIFY nextIdChanged)
public:

    /**
     * @brief The Roles supported by the model
     *
     * SurfaceRole - A MirSurfaceInterface. It will be null if the application is still starting up
     * ApplicationRole - An ApplicationInfoInterface
     * IdRole - A unique identifier for this entry. Useful to unambiguosly track elements as they move around in the list
     */
    enum Roles {
        SurfaceRole = Qt::UserRole,
        ApplicationRole = Qt::UserRole + 1,
        IdRole = Qt::UserRole + 2,
    };

    explicit TopLevelSurfaceList(QObject *parent = nullptr);
    virtual ~TopLevelSurfaceList();

    // QAbstractItemModel methods
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const {
        QHash<int, QByteArray> roleNames;
        roleNames.insert(SurfaceRole, "surface");
        roleNames.insert(ApplicationRole, "application");
        roleNames.insert(IdRole, "id");
        return roleNames;
    }

    int nextId() const { return m_nextId; }

    QAbstractListModel *applicationsModel() const;
    void setApplicationsModel(QAbstractListModel*);

public Q_SLOTS:
    /**
     * @brief Returns the surface at the given index
     *
     * It will be a nullptr if the application is still starting up and thus hasn't yet created
     * and drawn into a surface.
     */
    unity::shell::application::MirSurfaceInterface *surfaceAt(int index) const;

    /**
     * @brief Returns the application at the given index
     */
    unity::shell::application::ApplicationInfoInterface *applicationAt(int index) const;

    /**
     * @brief Returns the unique id of the element at the given index
     */
    int idAt(int index) const;

    /**
     * @brief Returns the index where the row with the given id is located
     */
    int indexForId(int id) const;

    /**
     * @brief Moves the row with the given id to the specified index
     */
    void move(int id, int toIndex);

Q_SIGNALS:
    void countChanged();

    /**
     * @brief Emitted when the list changes
     *
     * Emitted when model gains an element, loses an element or when elements exchange positions.
     */
    void listChanged();

    void nextIdChanged();

    void applicationsModelChanged();

private:
    void addApplication(unity::shell::application::ApplicationInfoInterface *application);
    void removeApplication(unity::shell::application::ApplicationInfoInterface *application);

    int indexOf(unity::shell::application::MirSurfaceInterface *surface);
    void raise(unity::shell::application::MirSurfaceInterface *surface);
    void moveSurface(int from, int to);
    void prependSurfaceHelper(unity::shell::application::MirSurfaceInterface *surface,
                              unity::shell::application::ApplicationInfoInterface *application);
    void connectSurface(unity::shell::application::MirSurfaceInterface *surface);
    int generateId();
    int nextFreeId(int candidateId);
    QString toString();
    void onSurfaceDestroyed(unity::shell::application::MirSurfaceInterface *surface);
    void onSurfaceDied(unity::shell::application::MirSurfaceInterface *surface);
    void removeAt(int index);
    void findApplicationRole();

    unity::shell::application::ApplicationInfoInterface *getApplicationFromModelAt(int index);

    /*
        Placeholder for a future surface from a starting or running application.
        Enables shell to give immediate feedback to the user by showing, eg,
        a splash screen.

        It's a model row containing a null surface and the given application.
     */
    void prependPlaceholder(unity::shell::application::ApplicationInfoInterface *application);

    /*
        Adds a model row with the given surface and application

        Alternatively, if a placeholder exists for the given application it's
        filled with the given surface instead.
     */
    void prependSurface(unity::shell::application::MirSurfaceInterface *surface,
            unity::shell::application::ApplicationInfoInterface *application);

    struct ModelEntry {
        ModelEntry(unity::shell::application::MirSurfaceInterface *surface, unity::shell::application::ApplicationInfoInterface *application, int id)
            : surface(surface), application(application), id(id) {}
        unity::shell::application::MirSurfaceInterface *surface;
        unity::shell::application::ApplicationInfoInterface *application;
        int id;
        bool removeOnceSurfaceDestroyed{false};
    };

    QList<ModelEntry> m_surfaceList;
    int m_nextId{1};
    static const int m_maxId{1000000};

    // applications that are being monitored
    QList<unity::shell::application::ApplicationInfoInterface *> m_applications;

    QAbstractListModel* m_applicationsModel{nullptr};
    int m_applicationRole{-1};
};

Q_DECLARE_METATYPE(TopLevelSurfaceList*)
Q_DECLARE_METATYPE(QAbstractListModel*)

#endif // TOPLEVELSURFACELIST_H

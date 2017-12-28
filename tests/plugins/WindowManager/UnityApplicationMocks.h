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

#ifndef UNITYAPPLICATIONMOCKS_H
#define UNITYAPPLICATIONMOCKS_H

#include <unity/shell/application/ApplicationInfoInterface.h>
#include <unity/shell/application/ApplicationManagerInterface.h>
#include <unity/shell/application/MirSurfaceInterface.h>
#include <unity/shell/application/SurfaceManagerInterface.h>

// from tests/mocks
#include <Unity/Application/MirSurfaceListModel.h>

using namespace unity::shell::application;

class MirSurface : public MirSurfaceInterface
{
    Q_OBJECT
public:
    Mir::Type type() const override { return m_type; }
    QString name() const override { return QString("foo"); }
    QString persistentId() const override { return QString("a-b-c-my-id"); }
    QString appId() const override { return QString(); }
    QPoint position() const override { return QPoint(); }
    QSize size() const override { return QSize(); }
    void resize(int, int) override {}
    void resize(const QSize &) override {}
    Mir::State state() const override { return m_state; }
    bool live() const override { return m_live; }
    bool visible() const override { return true; }
    Mir::OrientationAngle orientationAngle() const override { return Mir::Angle0; }
    void setOrientationAngle(Mir::OrientationAngle) override {}

    int minimumWidth() const override { return 0; }
    int minimumHeight() const override { return 0; }
    int maximumWidth() const override { return 0; }
    int maximumHeight() const override { return 0; }
    int widthIncrement() const override { return 0; }
    int heightIncrement() const override { return 0; }

    void setKeymap(const QString &) override {}
    QString keymap() const override { return QString(); }
    Mir::ShellChrome shellChrome() const override { return Mir::NormalChrome; }
    bool focused() const override { return true; }
    QRect inputBounds() const override { return QRect(); }
    bool confinesMousePointer() const override { return false; }
    bool allowClientResize() const override { return true; }
    void setAllowClientResize(bool) override {}
    QPoint requestedPosition() const override { return QPoint(); }
    void setRequestedPosition(const QPoint &) override {}
    MirSurfaceInterface* parentSurface() const override { return nullptr; }
    unity::shell::application::MirSurfaceListInterface* childSurfaceList() const override { return nullptr; }
    void close() override {}
    void activate() override {}

public Q_SLOTS:
    void requestState(Mir::State value) override
    {
        if (m_state != value) {
            m_state = value;
            Q_EMIT stateChanged(m_state);
        }
    }

public:
    Mir::Type m_type { Mir::NormalType };
    Mir::State m_state { Mir::RestoredState };
    bool m_live { true };
};

class SurfaceManager : public SurfaceManagerInterface
{
    Q_OBJECT

public:
    void raise(MirSurfaceInterface *) override {}
    void activate(MirSurfaceInterface *) override {}
};

class Application : public ApplicationInfoInterface
{
    Q_OBJECT
public:
    Application(QString appId)
     : ApplicationInfoInterface(appId, nullptr)
     , m_appId(std::move(appId))
     , m_state(Starting)
     , m_requestedState(RequestedRunning)
    {

    }

    void close() override {}
    QString appId() const override { return m_appId;}
    QString name() const override { return "foo"; }
    QString comment() const override { return "bar"; }
    QUrl icon() const override { return QUrl(); }
    State state() const override { return m_state; }
    RequestedState requestedState() const override { return m_requestedState; }
    void setRequestedState(RequestedState value) override
    {
        if (value != m_requestedState) {
            m_requestedState = value;
            Q_EMIT requestedStateChanged(value);
        }
    }
    bool focused() const override { return false; }
    QString splashTitle() const override { return QString(); }
    QUrl splashImage() const override { return QUrl(); }
    bool splashShowHeader() const override { return false; }
    QColor splashColor() const override { return QColor(); }
    QColor splashColorHeader() const override { return QColor(); }
    QColor splashColorFooter() const override { return QColor(); }
    Qt::ScreenOrientations supportedOrientations() const override { return Qt::LandscapeOrientation; }
    bool rotatesWindowContents() const override { return false; }
    bool isTouchApp() const override { return false; }
    bool exemptFromLifecycle() const override { return false; }
    void setExemptFromLifecycle(bool) override {}
    QSize initialSurfaceSize() const override { return QSize(); }
    void setInitialSurfaceSize(const QSize &) override {}
    MirSurfaceListInterface* surfaceList() const override { return &m_surfaceList; }
    MirSurfaceListInterface* promptSurfaceList() const override { return nullptr; }
    int surfaceCount() const override { return 0; }

    QString m_appId;
    State m_state;
    RequestedState m_requestedState;
    mutable MirSurfaceListModel m_surfaceList;
};

class ApplicationManager : public ApplicationManagerInterface
{
    Q_OBJECT

public:

    int rowCount(const QModelIndex &) const override
    {
        return m_applications.count();
    }

    QVariant data(const QModelIndex &/*index*/, int /*role*/) const override
    {
        return QVariant();
    }

    QString focusedApplicationId() const override {return QString();}

    ApplicationInfoInterface *get(int index) const override
    {
        return m_applications[index];
    }

    ApplicationInfoInterface *findApplication(const QString &appId) const override
    {
        Q_UNUSED(appId);
        return nullptr;
    }

    ApplicationInfoInterface *findApplicationWithSurface(MirSurfaceInterface* surface) const override
    {
        for (int i = 0; i < m_applications.count(); ++i) {
            if (m_applications[i]->m_surfaceList.contains(surface)) {
                return m_applications[i];
            }
        }
        return nullptr;
    }

    bool requestFocusApplication(const QString &appId) override
    {
        Q_UNUSED(appId);
        return false;
    }

    ApplicationInfoInterface *startApplication(const QString &appId, const QStringList &/*arguments*/) override
    {
        Application *application = new Application(appId);
        prepend(application);
        return application;
    }

    bool stopApplication(const QString &) override { return true; }

private:
    void prepend(Application *application)
    {
        beginInsertRows(QModelIndex(), 0 /*first*/, 0 /*last*/);
        m_applications.append(application);
        endInsertRows();
    }

    QList<Application*> m_applications;
};

#endif // UNITYAPPLICATIONMOCKS_H

#ifndef SCREEN_H
#define SCREEN_H

#include <qtmir/screen.h>
#include <QScopedPointer>
#include <QPointer>

#include "WorkspaceModel.h"

class ScreenProxy;

class Screen : public qtmir::Screen
{
    Q_OBJECT
    Q_PROPERTY(WorkspaceModel* workspaces READ workspaces CONSTANT)
    Q_PROPERTY(Workspace* currentWorkspace READ currentWorkspace WRITE setCurrentWorkspace NOTIFY currentWorkspaceChanged)

public:
    explicit Screen(qtmir::Screen*const wrapped);

    qtmir::OutputId outputId() const override;
    bool used() const override;
    QString name() const override;
    float scale() const override;
    QSizeF physicalSize() const override;
    qtmir::FormFactor formFactor() const override;
    qtmir::OutputTypes outputType() const override;
    MirPowerMode powerMode() const override;
    Qt::ScreenOrientation orientation() const override;
    QPoint position() const override;
    QQmlListProperty<qtmir::ScreenMode> availableModes() override;
    uint currentModeIndex() const override;
    bool isActive() const override;
    void setActive(bool active) override;

    QScreen* qscreen() const override;

    qtmir::ScreenConfiguration *beginConfiguration() const override;
    bool applyConfiguration(qtmir::ScreenConfiguration *configuration) override;

    qtmir::Screen* wrapped() const { return m_wrapped; }

    WorkspaceModel* workspaces() const;

    Workspace *currentWorkspace() const;
    void setCurrentWorkspace(Workspace* workspace);

    void sync(Screen* proxy);

public Q_SLOTS:
    void activate();

Q_SIGNALS:
    void currentWorkspaceChanged(Workspace*);

protected:
    Screen(Screen const& other);

    void resetCurrentWorkspace();

    qtmir::Screen*const m_wrapped;
    const QScopedPointer<WorkspaceModel> m_workspaces;
    QPointer<Workspace> m_currentWorspace;
};

class ScreenProxy : public Screen
{
    Q_OBJECT
public:
    explicit ScreenProxy(Screen*const screen);

    Screen* proxyObject() const { return m_original.data(); }

public Q_SLOTS:
    void addWorkspace();

private:
    const QPointer<Screen> m_original;
};

#endif // SCREEN_H

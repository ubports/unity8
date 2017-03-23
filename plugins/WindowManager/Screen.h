#ifndef SCREEN_H
#define SCREEN_H

#include <qtmir/screen.h>
#include <QScopedPointer>
#include <QPointer>

#include "WorkspaceModel.h"

class ProxyScreen;
class ScreenAttached;

class Screen: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool active READ isActive WRITE setActive NOTIFY activeChanged)

    Q_PROPERTY(bool used READ used NOTIFY usedChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(qtmir::OutputTypes outputType READ outputType NOTIFY outputTypeChanged)
    Q_PROPERTY(float scale READ scale NOTIFY scaleChanged)
    Q_PROPERTY(qtmir::FormFactor formFactor READ formFactor NOTIFY formFactorChanged)
    Q_PROPERTY(MirPowerMode powerMode READ powerMode NOTIFY powerModeChanged)
    Q_PROPERTY(Qt::ScreenOrientation orientation READ orientation NOTIFY orientationChanged)
    Q_PROPERTY(QPoint position READ position NOTIFY positionChanged)
    Q_PROPERTY(uint currentModeIndex READ currentModeIndex NOTIFY currentModeIndexChanged)
    Q_PROPERTY(QQmlListProperty<qtmir::ScreenMode> availableModes READ availableModes NOTIFY availableModesChanged)
    Q_PROPERTY(QSizeF physicalSize READ physicalSize NOTIFY physicalSizeChanged)
    Q_PROPERTY(QString outputTypeName READ outputTypeName NOTIFY outputTypeChanged)
    Q_PROPERTY(WorkspaceModel* workspaces READ workspaces CONSTANT)
    Q_PROPERTY(Workspace* currentWorkspace READ currentWorkspace WRITE setCurrentWorkspace NOTIFY currentWorkspaceChanged)
public:
    // From qtmir::Screen
    qtmir::OutputId outputId() const;
    bool used() const;
    QString name() const;
    float scale() const;
    QSizeF physicalSize() const;
    qtmir::FormFactor formFactor() const;
    qtmir::OutputTypes outputType() const;
    MirPowerMode powerMode() const;
    Qt::ScreenOrientation orientation() const;
    QPoint position() const;
    QQmlListProperty<qtmir::ScreenMode> availableModes();
    uint currentModeIndex() const;
    bool isActive() const;
    void setActive(bool active);
    QScreen* qscreen() const;
    QString outputTypeName() const;

    qtmir::ScreenConfiguration *beginConfiguration() const;
    bool applyConfiguration(qtmir::ScreenConfiguration *configuration);

    virtual WorkspaceModel* workspaces() const = 0;
    virtual Workspace *currentWorkspace() const = 0;
    virtual void setCurrentWorkspace(Workspace* workspace) = 0;

    void setSyncing(bool);
    void sync(Screen* proxy);

    qtmir::Screen* wrapped() const { return m_wrapped; }

public Q_SLOTS:
    void activate();

Q_SIGNALS:
    void usedChanged();
    void nameChanged();
    void outputTypeChanged();
    void outputTypeNameChanged();
    void scaleChanged();
    void formFactorChanged();
    void powerModeChanged();
    void orientationChanged();
    void positionChanged();
    void currentModeIndexChanged();
    void physicalSizeChanged();
    void availableModesChanged();
    void activeChanged(bool active);
    void currentWorkspaceChanged(Workspace*);

protected:
    Screen(QObject* parent = 0);

    void connectToScreen(qtmir::Screen* screen);
    void connectToScreen(Screen* screen);

protected:
    QPointer<qtmir::Screen> m_wrapped;
};


class ConcreteScreen : public Screen
{
    Q_OBJECT
public:
    explicit ConcreteScreen(qtmir::Screen*const wrapped);

    // From qtmir::Screen
    WorkspaceModel* workspaces() const override;
    Workspace *currentWorkspace() const override;
    void setCurrentWorkspace(Workspace* workspace) override;

    static ScreenAttached *qmlAttachedProperties(QObject *owner);

protected:
    void resetCurrentWorkspace();

    const QScopedPointer<WorkspaceModel> m_workspaces;
    QPointer<Workspace> m_currentWorspace;
};

class ProxyScreen : public Screen
{
    Q_OBJECT
public:
    explicit ProxyScreen(Screen*const screen);

    // From qtmir::Screen
    WorkspaceModel* workspaces() const override;
    Workspace *currentWorkspace() const override;
    void setCurrentWorkspace(Workspace* workspace) override;

    Screen* proxyObject() const { return m_original.data(); }

private:
    const QScopedPointer<WorkspaceModel> m_workspaces;
    const QPointer<Screen> m_original;
    QPointer<Workspace> m_currentWorspace;
};

#endif // SCREEN_H

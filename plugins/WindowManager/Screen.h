#ifndef SCREEN_H
#define SCREEN_H

#include <qtmir/screen.h>
#include <QScopedPointer>
#include <QPointer>

#include "WorkspaceModel.h"

class ProxyScreen;
class ProxyScreens;
class ScreenConfig;

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
    Q_PROPERTY(Workspace* currentWorkspace READ currentWorkspace WRITE setCurrentWorkspace2 NOTIFY currentWorkspaceChanged)
public:
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

    Q_INVOKABLE bool isSameAs(Screen*) const;

    Q_INVOKABLE ScreenConfig *beginConfiguration() const;
    Q_INVOKABLE bool applyConfiguration(ScreenConfig *configuration);

    virtual WorkspaceModel* workspaces() const = 0;
    virtual Workspace *currentWorkspace() const = 0;
    virtual void setCurrentWorkspace(Workspace* workspace) = 0;

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

private:
    void setCurrentWorkspace2(Workspace* workspace);

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

protected:
    void resetCurrentWorkspace();

    const QScopedPointer<WorkspaceModel> m_workspaces;
    QPointer<Workspace> m_currentWorspace;
};

class ProxyScreen : public Screen
{
    Q_OBJECT
public:
    explicit ProxyScreen(Screen*const screen, ProxyScreens* screens);

    // From qtmir::Screen
    WorkspaceModel* workspaces() const override;
    Workspace *currentWorkspace() const override;
    void setCurrentWorkspace(Workspace* workspace) override;

    Screen* proxyObject() const { return m_original.data(); }

    bool isSyncing() const;

private:
    const QScopedPointer<WorkspaceModel> m_workspaces;
    const QPointer<Screen> m_original;
    const ProxyScreens* m_screens;
    QPointer<Workspace> m_currentWorspace;
};

class ScreenConfig: public QObject
{
    Q_OBJECT
    Q_PRIVATE_PROPERTY(m_config, bool valid MEMBER used CONSTANT)
    Q_PRIVATE_PROPERTY(m_config, bool used MEMBER used)
    Q_PRIVATE_PROPERTY(m_config, float scale MEMBER scale)
    Q_PRIVATE_PROPERTY(m_config, qtmir::FormFactor formFactor MEMBER formFactor)
    Q_PRIVATE_PROPERTY(m_config, uint currentModeIndex MEMBER currentModeIndex)
    Q_PRIVATE_PROPERTY(m_config, QPoint position MEMBER topLeft)

public:
    ScreenConfig(qtmir::ScreenConfiguration*);
    ~ScreenConfig();

    qtmir::ScreenConfiguration* m_config;
};

#endif // SCREEN_H

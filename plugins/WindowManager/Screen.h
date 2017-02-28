#ifndef SCREEN_H
#define SCREEN_H

#include <qtmir/screen.h>
#include <QScopedPointer>

class WorkspaceModel;

class Screen : public qtmir::Screen
{
    Q_OBJECT
    Q_PROPERTY(WorkspaceModel* workspaces READ workspaces CONSTANT)

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

    WorkspaceModel* workspaces() const { return m_workspaces.data(); }

public Q_SLOTS:
    void activate();

private:
    qtmir::Screen*const m_wrapped;
    const QScopedPointer<WorkspaceModel> m_workspaces;
};

#endif // SCREEN_H

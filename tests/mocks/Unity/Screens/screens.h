/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#ifndef SCREENS_H
#define SCREENS_H

#include <QAbstractListModel>
#include <QScreen>
#include <QQmlListProperty>

class Screen;

class Screens : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum ItemRoles {
        ScreenRole = Qt::UserRole + 1,
        OutputTypeRole,
        EnabledRole,
        NameRole,
        ScaleRole,
        FormFactorRole,
        GeometryRole,
        SizesRole
    };

    enum OutputTypes {
        Unknown,
        VGA,
        DVII,
        DVID,
        DVIA,
        Composite,
        SVideo,
        LVDS,
        Component,
        NinePinDIN,
        DisplayPort,
        HDMIA,
        HDMIB,
        TV,
        EDP
    };
    Q_ENUM(OutputTypes)

    enum FormFactor {
        FormFactorUnknown,
        FormFactorPhone,
        FormFactorTablet,
        FormFactorMonitor,
        FormFactorTV,
        FormFactorProjector,
    };

    explicit Screens(QObject *parent = 0);
    virtual ~Screens() noexcept;

    /* QAbstractItemModel */
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = ScreenRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    int count() const;

public Q_SLOTS:
    void activateScreen(int index);

Q_SIGNALS:
    void countChanged();
    void screenAdded(QScreen *screen);
    void screenRemoved(QScreen *screen);

private:
    QList<Screen *> m_screenList;
};

class ScreenMode : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal refreshRate MEMBER refreshRate CONSTANT)
    Q_PROPERTY(QSize size MEMBER size CONSTANT)
public:
    ScreenMode() {}
    ScreenMode(qreal refreshRate, QSize size):refreshRate(refreshRate),size(size) {}
    ScreenMode(const ScreenMode& other)
        : QObject(nullptr),
          refreshRate{other.refreshRate},size{other.size}
    {}

    qreal refreshRate;
    QSize size;
};

class Screen : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool active MEMBER m_active NOTIFY activeChanged)

    Q_PROPERTY(bool used MEMBER m_used NOTIFY usedChanged)
    Q_PROPERTY(QString name MEMBER m_name NOTIFY nameChanged)
    Q_PROPERTY(Screens::OutputTypes outputType MEMBER m_outputType NOTIFY outputTypeChanged)
    Q_PROPERTY(float scale MEMBER m_scale NOTIFY scaleChanged)
    Q_PROPERTY(Screens::FormFactor formFactor MEMBER m_formFactor NOTIFY formFactorChanged)
    Q_PROPERTY(QPoint position MEMBER m_position NOTIFY positionChanged)
    Q_PROPERTY(uint currentModeIndex MEMBER m_currentModeIndex NOTIFY currentModeIndexChanged)
    Q_PROPERTY(QQmlListProperty<ScreenMode> availableModes READ availableModes NOTIFY availableModesChanged)
    Q_PROPERTY(QSizeF physicalSize MEMBER m_physicalSize NOTIFY physicalSizeChanged)
public:
    Screen(QObject* parent = 0);
    ~Screen();

    QQmlListProperty<ScreenMode> availableModes();

    Q_INVOKABLE Screen* beginConfiguration();
    Q_INVOKABLE void applyConfiguration();

Q_SIGNALS:
    void activeChanged();
    void usedChanged();
    void nameChanged();
    void outputTypeChanged();
    void scaleChanged();
    void formFactorChanged();
    void positionChanged();
    void currentModeIndexChanged();
    void availableModesChanged();
    void physicalSizeChanged();

public:
    bool m_active{false};
    bool m_used{true};
    QString m_name;
    Screens::OutputTypes m_outputType{Screens::Unknown};
    float m_scale{1.0};
    Screens::FormFactor m_formFactor{Screens::FormFactorMonitor};
    QPoint m_position;
    uint m_currentModeIndex{0};
    QList<ScreenMode*> m_sizes;
    QSizeF m_physicalSize;
};

Q_DECLARE_METATYPE(ScreenMode)

#endif // SCREENS_H

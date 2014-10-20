/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef ROOTACTIONSTATE_H
#define ROOTACTIONSTATE_H

#include "unityindicatorsglobal.h"

#include <actionstateparser.h>

class UnityMenuModel;

class UNITYINDICATORS_EXPORT RootActionState : public ActionStateParser
{
    Q_OBJECT
    Q_PROPERTY(UnityMenuModel* menu READ menu WRITE setMenu NOTIFY menuChanged)

    Q_PROPERTY(bool valid READ isValid NOTIFY validChanged)
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(QString leftLabel READ leftLabel NOTIFY leftLabelChanged)
    Q_PROPERTY(QString rightLabel READ rightLabel NOTIFY rightLabelChanged)
    Q_PROPERTY(QStringList icons READ icons NOTIFY iconsChanged)
    Q_PROPERTY(QString accessibleName READ accessibleName NOTIFY accessibleNameChanged)
    Q_PROPERTY(bool indicatorVisible READ indicatorVisible NOTIFY indicatorVisibleChanged)
public:
    RootActionState(QObject *parent = 0);
    virtual ~RootActionState();

    UnityMenuModel* menu() const;
    void setMenu(UnityMenuModel* menu);

    int index() const;
    void setIndex(int index);

    bool isValid() const;
    QString title() const;
    QString leftLabel() const;
    QString rightLabel() const;
    QStringList icons() const;
    QString accessibleName() const;
    bool indicatorVisible() const;

    // from ActionStateParser
    virtual QVariant toQVariant(GVariant* state) const override;

Q_SIGNALS:
    void updated();

    void menuChanged();
    void indexChanged();

    void validChanged();
    void titleChanged();
    void leftLabelChanged();
    void rightLabelChanged();
    void iconsChanged();
    void accessibleNameChanged();
    void indicatorVisibleChanged();

private Q_SLOTS:
    void onModelRowsAdded(const QModelIndex& parent, int start, int end);
    void onModelRowsRemoved(const QModelIndex& parent, int start, int end);
    void onModelDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRight, const QVector<int>&);
    void reset();

private:
    void updateActionState();

    UnityMenuModel* m_menu;
    QVariantMap m_cachedState;
};

#endif // ROOTACTIONSTATE_H

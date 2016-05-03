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
 */

#ifndef ROOTSTATEPARSER_H
#define ROOTSTATEPARSER_H

#include "unityindicatorsglobal.h"

#include <actionstateparser.h>

class UNITYINDICATORS_EXPORT RootStateParser : public ActionStateParser
{
Q_OBJECT
public:
    RootStateParser(QObject* parent = nullptr);
    virtual QVariant toQVariant(GVariant* state) const override;
};

class UNITYINDICATORS_EXPORT RootStateObject : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool valid READ valid NOTIFY validChanged)
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(QString leftLabel READ leftLabel NOTIFY leftLabelChanged)
    Q_PROPERTY(QString rightLabel READ rightLabel NOTIFY rightLabelChanged)
    Q_PROPERTY(QStringList icons READ icons NOTIFY iconsChanged)
    Q_PROPERTY(QString accessibleName READ accessibleName NOTIFY accessibleNameChanged)
    Q_PROPERTY(bool indicatorVisible READ indicatorVisible NOTIFY indicatorVisibleChanged)
public:
    RootStateObject(QObject* parent = 0);

    virtual bool valid() const = 0;

    QString title() const;
    QString leftLabel() const;
    QString rightLabel() const;
    QStringList icons() const;
    QString accessibleName() const;
    bool indicatorVisible() const;

    QVariantMap currentState() const { return m_currentState; }
    void setCurrentState(const QVariantMap& currentState);

Q_SIGNALS:
    void updated();

    void validChanged();
    void titleChanged();
    void leftLabelChanged();
    void rightLabelChanged();
    void iconsChanged();
    void accessibleNameChanged();
    void indicatorVisibleChanged();

protected:
    RootStateParser m_parser;
    QVariantMap m_currentState;
};

#endif // ROOTSTATEPARSER_H

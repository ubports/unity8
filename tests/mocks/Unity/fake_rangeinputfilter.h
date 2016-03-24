/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#ifndef FAKE_RANGEINPUTFILTER_H
#define FAKE_RANGEINPUTFILTER_H

#include <unity/shell/scopes/RangeInputFilterInterface.h>

class FakeRangeInputFilter : public unity::shell::scopes::RangeInputFilterInterface
{
    Q_OBJECT

public:
    FakeRangeInputFilter(const QString &id, const QString &tag, QObject* parent);

    QString filterId() const override;
    QString filterTag() const override;
    QString title() const override;

    double startValue() const override;
    double endValue() const override;
    void setStartValue(double value) override;
    void setEndValue(double value)  override;
    QString startPrefixLabel() const override;
    QString startPostfixLabel() const override;
    QString centralLabel() const override;
    QString endPrefixLabel() const override;
    QString endPostfixLabel() const override;
    bool hasStartValue() const override;
    bool hasEndValue() const override;

    void eraseStartValue() override;
    void eraseEndValue() override;

    // Not part of the iface, for mock/testing purposes
    bool isActive() const;

    void setTitle(const QString &title);
    void setStartPrefixLabel(const QString &startPrefixLabel);
    void setStartPostfixLabel(const QString &startPostfixLabel);
    void setCentralLabel(const QString &centralLabel);
    void setEndPrefixLabel(const QString &endPrefixLabel);
    void setEndPostfixLabel(const QString &endPostfixLabel);

Q_SIGNALS:
    void isActiveChanged();

private:
    QString m_filterId;
    QString m_filterTag;
    QString m_title;

    bool m_hasStartValue;
    bool m_hasEndValue;

    double m_startValue;
    double m_endValue;

    QString m_startPrefixLabel;
    QString m_startPostfixLabel;
    QString m_centralLabel;
    QString m_endPrefixLabel;
    QString m_endPostfixLabel;
};

#endif

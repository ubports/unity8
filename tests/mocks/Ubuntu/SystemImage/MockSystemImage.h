/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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

#ifndef MOCK_SYSTEMIMAGE_H
#define MOCK_SYSTEMIMAGE_H

#include <QObject>

class MockSystemImage : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(MockSystemImage)

    Q_PROPERTY(bool updateDownloaded READ updateDownloaded CONSTANT)
    Q_PROPERTY(QString availableVersion READ availableVersion CONSTANT)
    Q_PROPERTY(QString updateSize READ updateSize CONSTANT)
    Q_PROPERTY(bool updateApplying READ updateApplying NOTIFY updateApplyingChanged)

public:
    explicit MockSystemImage(QObject *parent = nullptr);

    Q_INVOKABLE void checkForUpdate();
    Q_INVOKABLE void applyUpdate();
    Q_INVOKABLE void factoryReset();

    bool updateApplying() const { return m_updateApplying; }
    // these are const only in mock
    bool updateDownloaded() const { return true; }
    QString availableVersion() const { return QStringLiteral("42"); }
    QString updateSize() const { return QStringLiteral("4.2 MB"); }

Q_SIGNALS:
    void resettingDevice(); // only for mock
    void updateApplyingChanged();

private Q_SLOTS:
    void setUpdateApplying(bool status);

private:
    bool m_updateApplying = false;
};

#endif // MOCK_SYSTEMIMAGE_H

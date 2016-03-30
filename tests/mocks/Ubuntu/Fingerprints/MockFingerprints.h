/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#ifndef MOCK_FINGERPRINTS_H
#define MOCK_FINGERPRINTS_H

#include <QObject>

class MockFingerprints : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(MockFingerprints)
    Q_ENUMS(IdentificationError)

public:
    enum IdentificationError {
         None,
         Error,
    };

    explicit MockFingerprints(QObject *parent = 0);

    Q_INVOKABLE void mockIdentification(int uid, IdentificationError error); // only in mock

Q_SIGNALS:
    void identificationCompleted(int uid);
    void identificationFailed(IdentificationError);
};

#endif // MOCK_FINGERPRINTS_H

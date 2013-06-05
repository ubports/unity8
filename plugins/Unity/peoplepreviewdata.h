/*
 * Copyright (C) 2012 Canonical, Ltd.
 *
 * Authors:
 *  Guenter Schwann <guenter.schwann@canonical.com>
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

#ifndef PEOPLEPREVIEWDATA_H
#define PEOPLEPREVIEWDATA_H

#include <QList>
#include <QObject>
#include <qqmllist.h>
#include <QString>

// libunity-core
#include <UnityCore/PeoplePreview.h>

#include <sigc++/connection.h>

class Lens;

/*!
 * \brief The PeoplePhoneData class stores the data for one phone number
 */
class PeoplePhoneData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString type READ type NOTIFY typeChanged)
    Q_PROPERTY(QString location READ location NOTIFY locationChanged)
    Q_PROPERTY(QString number READ number NOTIFY numberChanged)

Q_SIGNALS:
    void typeChanged();
    void locationChanged();
    void numberChanged();

public:
    explicit PeoplePhoneData(QObject *parent = 0) : QObject(parent) {}
    QString type() const { return m_type; }
    QString location() const { return m_location; }
    QString number() const { return m_number; }

private:
    QString m_type;
    QString m_location;
    QString m_number;
    friend class PeoplePreviewData;
};

/*!
 * \brief The PeopleAddressData class stores the data for one single post/email address
 */
class PeopleAddressData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString type READ type NOTIFY typeChanged)
    Q_PROPERTY(QString address READ address NOTIFY addressChanged)
    Q_PROPERTY(QString poBox READ poBox NOTIFY poBoxChanged)
    Q_PROPERTY(QString extension READ extension NOTIFY extensionChanged)
    Q_PROPERTY(QString street READ street NOTIFY streetChanged)
    Q_PROPERTY(QString locality READ locality NOTIFY localityChanged)
    Q_PROPERTY(QString region READ region NOTIFY regionChanged)
    Q_PROPERTY(QString postalCode READ postalCode NOTIFY postalCodeChanged)
    Q_PROPERTY(QString country READ country NOTIFY countryChanged)
    Q_PROPERTY(QString addressFormat READ addressFormat NOTIFY addressFormatChanged)

Q_SIGNALS:
    void typeChanged();
    void addressChanged();
    void poBoxChanged();
    void extensionChanged();
    void streetChanged();
    void localityChanged();
    void regionChanged();
    void postalCodeChanged();
    void countryChanged();
    void addressFormatChanged();

public:
    explicit PeopleAddressData(QObject *parent = 0) : QObject(parent) {}
    QString type() const { return m_type; }
    QString address() const { return m_address; }
    QString poBox() const { return m_poBox; }
    QString extension() const { return m_extension; }
    QString street() const { return m_street; }
    QString locality() const { return m_locality; }
    QString region() const { return m_region; }
    QString postalCode() const { return m_postalCode; }
    QString country() const { return m_country; }
    QString addressFormat() const { return m_addressFormat; }

private:
    QString m_type;
    QString m_address;
    QString m_poBox;
    QString m_extension;
    QString m_street;
    QString m_locality;
    QString m_region;
    QString m_postalCode;
    QString m_country;
    QString m_addressFormat;
    friend class PeoplePreviewData;
};

/*!
 * \brief The PeopleIMData class stores the data for one single post/email address
 */
class PeopleIMData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString protocol READ protocol NOTIFY protocolChanged)
    Q_PROPERTY(QString address READ address NOTIFY addressChanged)

Q_SIGNALS:
    void protocolChanged();
    void addressChanged();

public:
    explicit PeopleIMData(QObject *parent = 0) : QObject(parent) {}
    QString protocol() const { return m_protocol; }
    QString address() const { return m_address; }

private:
    QString m_protocol;
    QString m_address;
    friend class PeoplePreviewData;
};


/*!
 * \brief The PeoplePreviewData class providing information for one person
 */
class PeoplePreviewData : public QObject
{
    Q_OBJECT

    // These properties need to be set from QML
    Q_PROPERTY(Lens* lens READ lens WRITE setLens NOTIFY lensChanged)
    Q_PROPERTY(QString uri READ uri WRITE setUri NOTIFY uriChanged)
    // Read only properties containing general Preview information
    Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)
    Q_PROPERTY(QString renderName READ renderName NOTIFY renderNameChanged)
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(QString subTitle READ subTitle NOTIFY subTitleChanged)
    Q_PROPERTY(QString description READ description NOTIFY descriptionChanged)
    Q_PROPERTY(QString imageSource READ imageSource NOTIFY imageSourceChanged)
    // Read only properties containing PeoplePreview specific information
    Q_PROPERTY(QString displayName READ displayName NOTIFY displayNameChanged)
    Q_PROPERTY(QQmlListProperty<PeopleAddressData> emailAddresses READ emailAddresses NOTIFY emailAddressesChanged)
    Q_PROPERTY(QQmlListProperty<PeoplePhoneData> phoneNumbers READ phoneNumbers NOTIFY phoneNumbersChanged)
    Q_PROPERTY(QQmlListProperty<PeopleIMData> imAccounts READ imAccounts NOTIFY imAccountsChanged)
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)
    Q_PROPERTY(QString statusTime READ statusTime NOTIFY statusTimeChanged)
    Q_PROPERTY(QString statusService READ statusService NOTIFY statusServiceChanged)
    Q_PROPERTY(QString statusServiceIcon READ statusServiceIcon NOTIFY statusServiceIconChanged)
    Q_PROPERTY(QString statusPostUri READ statusPostUri NOTIFY statusPostUriChanged)
    Q_PROPERTY(QQmlListProperty<PeopleAddressData> addresses READ addresses NOTIFY addressesChanged)
    Q_PROPERTY(QString avatar READ avatar NOTIFY avatarChanged)

public:
    PeoplePreviewData(QObject *parent = 0);
    ~PeoplePreviewData();

    void setUnityPeoplePreview(const unity::dash::Preview::Ptr& preview);
    void setLens(Lens *lens);
    void setUri(const QString &uri);

    Lens *lens() const;
    QString uri() const;
    bool ready() const;
    QString renderName() const;
    QString title() const;
    QString subTitle() const;
    QString description() const;
    QString imageSource() const;
    QString displayName() const;
    QQmlListProperty<PeoplePhoneData> phoneNumbers();
    QQmlListProperty<PeopleAddressData> emailAddresses();
    QQmlListProperty<PeopleIMData> imAccounts();
    QString status() const;
    QString statusTime() const;
    QString statusService() const;
    QString statusServiceIcon() const;
    QString statusPostUri() const;
    QQmlListProperty<PeopleAddressData> addresses();
    QString avatar() const;

    QList<PeoplePhoneData*> &phoneNumberList() { return m_phoneList; }
    QList<PeopleAddressData*> &emailAddressesList() { return m_emailList; }
    QList<PeopleIMData*> &imAccountsList() { return m_imList; }
    QList<PeopleAddressData*> &addressesList() { return m_addressList; }

Q_SIGNALS:
    void lensChanged();
    void uriChanged();
    void readyChanged();
    void renderNameChanged();
    void titleChanged();
    void subTitleChanged();
    void descriptionChanged();
    void imageSourceChanged();
    void displayNameChanged();
    void phoneNumbersChanged();
    void emailAddressesChanged();
    void imAccountsChanged();
    void statusChanged();
    void statusTimeChanged();
    void statusServiceChanged();
    void statusServiceIconChanged();
    void statusPostUriChanged();
    void addressesChanged();
    void avatarChanged();
    void error();

private:
    void setReady(const bool &ready);
    void getPeoplePreview();
    void setUnityPreview(std::string const& uri, unity::dash::Preview::Ptr const& preview);
    void clearData();
    void getPhoneData();
    void getEmailAddresses();
    void getImAccounts();
    void getAddresses();

    Lens *m_lens;
    sigc::connection m_lensConnection;
    QString m_uri;
    bool m_ready;
    unity::dash::PeoplePreview::Ptr m_unityPreview;

    QList<PeoplePhoneData*> m_phoneList;
    QList<PeopleAddressData*> m_addressList;
    QList<PeopleIMData*> m_imList;
    QList<PeopleAddressData*> m_emailList;
};

#endif // PEOPLEPREVIEWDATA_H

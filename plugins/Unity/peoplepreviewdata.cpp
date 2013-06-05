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

#include "peoplepreviewdata.h"

#include <QDebug>

#include "lens.h"

static void phoneAppend(QQmlListProperty<PeoplePhoneData> *property, PeoplePhoneData *val)
{
    Q_UNUSED(val);
    Q_UNUSED(property);
}
static PeoplePhoneData *phoneAt(QQmlListProperty<PeoplePhoneData> *property, int index)
{
    PeoplePreviewData *d = static_cast<PeoplePreviewData*>(property->data);
    return d->phoneNumberList().at(index);
}
static int phoneCount(QQmlListProperty<PeoplePhoneData> *property)
{
    PeoplePreviewData *d = static_cast<PeoplePreviewData*>(property->data);
    return d->phoneNumberList().count();
}
static void phoneClear(QQmlListProperty<PeoplePhoneData> *property)
{
    Q_UNUSED(property);
}

static void emailAppend(QQmlListProperty<PeopleAddressData> *property, PeopleAddressData *val)
{
    Q_UNUSED(val);
    Q_UNUSED(property);
}
static PeopleAddressData *emailAt(QQmlListProperty<PeopleAddressData> *property, int index)
{
    PeoplePreviewData *d = static_cast<PeoplePreviewData*>(property->data);
    return d->emailAddressesList().at(index);
}
static int emailCount(QQmlListProperty<PeopleAddressData> *property)
{
    PeoplePreviewData *d = static_cast<PeoplePreviewData*>(property->data);
    return d->emailAddressesList().count();
}
static void emailClear(QQmlListProperty<PeopleAddressData> *property)
{
    Q_UNUSED(property);
}

static void imAppend(QQmlListProperty<PeopleIMData> *property, PeopleIMData *val)
{
    Q_UNUSED(val);
    Q_UNUSED(property);
}
static PeopleIMData *imAt(QQmlListProperty<PeopleIMData> *property, int index)
{
    PeoplePreviewData *d = static_cast<PeoplePreviewData*>(property->data);
    return d->imAccountsList().at(index);
}
static int imCount(QQmlListProperty<PeopleIMData> *property)
{
    PeoplePreviewData *d = static_cast<PeoplePreviewData*>(property->data);
    return d->imAccountsList().count();
}
static void imClear(QQmlListProperty<PeopleIMData> *property)
{
    Q_UNUSED(property);
}

static void addressAppend(QQmlListProperty<PeopleAddressData> *property, PeopleAddressData *val)
{
    Q_UNUSED(val);
    Q_UNUSED(property);
}
static PeopleAddressData *addressAt(QQmlListProperty<PeopleAddressData> *property, int index)
{
    PeoplePreviewData *d = static_cast<PeoplePreviewData*>(property->data);
    return d->addressesList().at(index);
}
static int addressCount(QQmlListProperty<PeopleAddressData> *property)
{
    PeoplePreviewData *d = static_cast<PeoplePreviewData*>(property->data);
    return d->addressesList().count();
}
static void addressClear(QQmlListProperty<PeopleAddressData> *property)
{
    Q_UNUSED(property);
}


using namespace unity;

PeoplePreviewData::PeoplePreviewData(QObject *parent)
:   QObject(parent)
,   m_lens(0)
,   m_ready(false)
{
}

PeoplePreviewData::~PeoplePreviewData()
{
    clearData();
}

Lens *PeoplePreviewData::lens() const
{
    return m_lens;
}

void PeoplePreviewData::setLens(Lens *lens)
{
    if (lens == m_lens)
        return;

    setReady(false);

    if (m_lensConnection.connected())
       m_lensConnection.disconnect();

    m_lens = lens;
    m_lensConnection = m_lens->unityLens()->preview_ready.connect(
                sigc::mem_fun(this, &PeoplePreviewData::setUnityPreview));
    Q_EMIT lensChanged();

    if (!m_uri.isEmpty() && !m_lens)
        getPeoplePreview();
}

QString PeoplePreviewData::uri() const
{
    return m_uri;
}

void PeoplePreviewData::setUri(const QString &uri)
{
    if (uri == m_uri)
        return;

    setReady(false);

    m_uri = uri;
    Q_EMIT uriChanged();
    if (!m_uri.isEmpty() && m_lens)
        getPeoplePreview();
}

bool PeoplePreviewData::ready() const
{
    return m_ready;
}

void PeoplePreviewData::setReady(const bool &ready)
{
    if (ready == m_ready)
        return;

    m_ready = ready;
    Q_EMIT readyChanged();
}

QString PeoplePreviewData::renderName() const
{
    if (!m_unityPreview)
        return QLatin1String("");

    return QString::fromStdString(m_unityPreview->renderer_name());
}

QString PeoplePreviewData::title() const
{
    if (!m_unityPreview)
        return QLatin1String("");

    return QString::fromStdString(m_unityPreview->title());
}

QString PeoplePreviewData::subTitle() const
{
    if (!m_unityPreview)
        return QLatin1String("");

    return QString::fromStdString(m_unityPreview->subtitle());
}

QString PeoplePreviewData::description() const
{
    if (!m_unityPreview)
        return QLatin1String("");

    return QString::fromStdString(m_unityPreview->description());
}

QString PeoplePreviewData::imageSource() const
{
    if (!m_unityPreview)
        return QLatin1String("");

    return QString::fromStdString(m_unityPreview->image_source_uri());
}

QQmlListProperty<PeoplePhoneData> PeoplePreviewData::phoneNumbers()
{
    return QQmlListProperty<PeoplePhoneData> (this, this,
                                              phoneAppend,
                                              phoneCount,
                                              phoneAt,
                                              phoneClear);
}

QQmlListProperty<PeopleAddressData> PeoplePreviewData::emailAddresses()
{
    return QQmlListProperty<PeopleAddressData> (this, this,
                                              emailAppend,
                                              emailCount,
                                              emailAt,
                                              emailClear);
}

QQmlListProperty<PeopleIMData> PeoplePreviewData::imAccounts()
{
    return QQmlListProperty<PeopleIMData> (this, this,
                                              imAppend,
                                              imCount,
                                              imAt,
                                              imClear);
}

QString PeoplePreviewData::displayName() const
{
    if (!m_unityPreview)
        return QLatin1String("");

    return QString::fromStdString(m_unityPreview->display_name());
}

QString PeoplePreviewData::status() const
{
    if (!m_unityPreview)
        return QLatin1String("");

    return QString::fromStdString(m_unityPreview->status());
}

QString PeoplePreviewData::statusTime() const
{
    if (!m_unityPreview)
        return QLatin1String("");

    return QString::fromStdString(m_unityPreview->status_time());
}

QString PeoplePreviewData::statusService() const
{
    if (!m_unityPreview)
        return QLatin1String("");

    return QString::fromStdString(m_unityPreview->status_service());
}

QString PeoplePreviewData::statusServiceIcon() const
{
    if (!m_unityPreview)
        return QLatin1String("");

    glib::Object<GIcon> icon = m_unityPreview->status_service_icon();
    if (!icon)
        return QLatin1String("");

    return QString(g_icon_to_string(icon));
}

QString PeoplePreviewData::statusPostUri() const
{
    if (!m_unityPreview)
        return QLatin1String("");

    return QString::fromStdString(m_unityPreview->status_post_uri());
}

QQmlListProperty<PeopleAddressData> PeoplePreviewData::addresses()
{
    return QQmlListProperty<PeopleAddressData> (this, this,
                                              addressAppend,
                                              addressCount,
                                              addressAt,
                                              addressClear);
}

QString PeoplePreviewData::avatar() const
{
    if (!m_unityPreview)
        return QLatin1String("");

    glib::Object<GIcon> avatar = m_unityPreview->avatar();
    if (!avatar)
        return QLatin1String("");

    return QString(g_icon_to_string(avatar));
}

void PeoplePreviewData::getPeoplePreview()
{
    m_lens->unityLens()->Preview(m_uri.toStdString());
}

void PeoplePreviewData::setUnityPreview(std::string const& uri, dash::Preview::Ptr const& preview)
{
    if (uri != m_uri.toStdString())
        return;

    dash::PeoplePreview::Ptr peoplePtr = std::dynamic_pointer_cast<dash::PeoplePreview>(preview);
    if (peoplePtr == nullptr) {
        qWarning() << "Backend returned a dash::Preview that isn't a dash::PeoplePreview";
        Q_EMIT error();
        return;
    }

    clearData();
    m_unityPreview = peoplePtr;
    getPhoneData();
    getEmailAddresses();
    getImAccounts();
    getAddresses();

    Q_EMIT renderNameChanged();
    Q_EMIT titleChanged();
    Q_EMIT subTitleChanged();
    Q_EMIT descriptionChanged();
    Q_EMIT imageSourceChanged();
    Q_EMIT phoneNumbersChanged();
    Q_EMIT emailAddressesChanged();
    Q_EMIT imAccountsChanged();
    Q_EMIT displayNameChanged();
    Q_EMIT statusChanged();
    Q_EMIT statusTimeChanged();
    Q_EMIT statusServiceChanged();
    Q_EMIT addressesChanged();
    Q_EMIT avatarChanged();

    setReady(true);
}

void PeoplePreviewData::clearData()
{
    while (!m_phoneList.empty()) {
        PeoplePhoneData *phone = m_phoneList.takeLast();
        delete phone;
    }
    while (!m_emailList.empty()) {
        PeopleAddressData *email = m_emailList.takeLast();
        delete email;
    }
    while (!m_imList.empty()) {
        PeopleIMData *im = m_imList.takeLast();
        delete im;
    }
    while (!m_addressList.empty()) {
        PeopleAddressData *address = m_addressList.takeLast();
        delete address;
    }
}

void PeoplePreviewData::getPhoneData()
{
    dash::PeoplePreview::PhonePtrList uPhoneList;
    uPhoneList = m_unityPreview->GetPhone();

    for (size_t i=0; i<uPhoneList.size(); ++i) {
        PeoplePhoneData *phone = new PeoplePhoneData;
        phone->m_type = QString::fromStdString(uPhoneList[i]->type);
        phone->m_location = QString::fromStdString(uPhoneList[i]->location);
        phone->m_number = QString::fromStdString(uPhoneList[i]->number);
        m_phoneList.append(phone);
    }
}

void PeoplePreviewData::getEmailAddresses()
{
    dash::PeoplePreview::EmailPtrList uEmailList;
    uEmailList = m_unityPreview->GetEmail();

    for (size_t i=0; i<uEmailList.size(); ++i) {
        PeopleAddressData *email = new PeopleAddressData;
        email->m_type = QString::fromStdString(uEmailList[i]->type);
        email->m_address = QString::fromStdString(uEmailList[i]->address);
        m_emailList.append(email);
    }
}

void PeoplePreviewData::getImAccounts()
{
    dash::PeoplePreview::IMAccountPtrList uIMList;
    uIMList = m_unityPreview->GetIMAccount();

    for (size_t i=0; i<uIMList.size(); ++i) {
        PeopleIMData *im = new PeopleIMData;
        im->m_protocol = QString::fromStdString(uIMList[i]->protocol);
        im->m_address = QString::fromStdString(uIMList[i]->address);
        m_imList.append(im);
    }
}

void PeoplePreviewData::getAddresses()
{
    dash::PeoplePreview::AddressPtrList uAddressList;
    uAddressList = m_unityPreview->GetAddress();

    for (size_t i=0; i<uAddressList.size(); ++i) {
        PeopleAddressData *address = new PeopleAddressData;
        address->m_type = QString::fromStdString(uAddressList[i]->type);
        address->m_address = QString::fromStdString(uAddressList[i]->address);
        address->m_poBox = QString::fromStdString(uAddressList[i]->po_box);
        address->m_extension = QString::fromStdString(uAddressList[i]->extension);
        address->m_street = QString::fromStdString(uAddressList[i]->street);
        address->m_locality = QString::fromStdString(uAddressList[i]->locality);
        address->m_region = QString::fromStdString(uAddressList[i]->region);
        address->m_postalCode = QString::fromStdString(uAddressList[i]->postal_code);
        address->m_country = QString::fromStdString(uAddressList[i]->country);
        address->m_addressFormat = QString::fromStdString(uAddressList[i]->address_format);
        m_addressList.append(address);
    }
}

/*
 * Copyright (C) 2015 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QLocale>
#include <QStringList>

#include <libintl.h>

#include "LocalePlugin.h"


class LocalePrivate {
public:
    LocalePrivate() {
        m_countryNames = QHash<QLocale::Country, QString>(
        {{QLocale::IvoryCoast,                 gettext("Ivory Coast")},
         {QLocale::Ghana,                      gettext("Ghana")},
         {QLocale::Ethiopia,                   gettext("Ethiopia")},
         {QLocale::Algeria,                    gettext("Algeria")},
         {QLocale::Eritrea,                    gettext("Eritrea")},
         {QLocale::Mali,                       gettext("Mali")},
         {QLocale::CentralAfricanRepublic,     gettext("Central African Republic")},
         {QLocale::Gambia,                     gettext("Gambia")},
         {QLocale::GuineaBissau,               gettext("Guinea Bissau")},
         {QLocale::Malawi,                     gettext("Malawi")},
         {QLocale::CongoBrazzaville,           gettext("Congo Brazzaville")},
         {QLocale::Burundi,                    gettext("Burundi")},
         {QLocale::Egypt,                      gettext("Egypt")},
         {QLocale::Morocco,                    gettext("Morocco")},
         {QLocale::Spain,                      gettext("Spain")},
         {QLocale::Guinea,                     gettext("Guinea")},
         {QLocale::Senegal,                    gettext("Senegal")},
         {QLocale::Tanzania,                   gettext("Tanzania")},
         {QLocale::Djibouti,                   gettext("Djibouti")},
         {QLocale::Cameroon,                   gettext("Cameroon")},
         {QLocale::WesternSahara,              gettext("Western Sahara")},
         {QLocale::SierraLeone,                gettext("Sierra Leone")},
         {QLocale::Botswana,                   gettext("Botswana")},
         {QLocale::Zimbabwe,                   gettext("Zimbabwe")},
         {QLocale::SouthAfrica,                gettext("South Africa")},
         {QLocale::SouthSudan,                 gettext("South Sudan")},
         {QLocale::Uganda,                     gettext("Uganda")},
         {QLocale::Sudan,                      gettext("Sudan")},
         {QLocale::Rwanda,                     gettext("Rwanda")},
         {QLocale::CongoKinshasa,              gettext("Congo (Kinshasa)")},
         {QLocale::Nigeria,                    gettext("Nigeria")},
         {QLocale::Gabon,                      gettext("Gabon")},
         {QLocale::Togo,                       gettext("Togo")},
         {QLocale::Angola,                     gettext("Angola")},
         {QLocale::Zambia,                     gettext("Zambia")},
         {QLocale::EquatorialGuinea,           gettext("Equatorial Guinea")},
         {QLocale::Mozambique,                 gettext("Mozambique")},
         {QLocale::Lesotho,                    gettext("Lesotho")},
         {QLocale::Swaziland,                  gettext("Swaziland")},
         {QLocale::Somalia,                    gettext("Somalia")},
         {QLocale::Liberia,                    gettext("Liberia")},
         {QLocale::Kenya,                      gettext("Kenya")},
         {QLocale::Chad,                       gettext("Chad")},
         {QLocale::Niger,                      gettext("Niger")},
         {QLocale::Mauritania,                 gettext("Mauritania")},
         {QLocale::BurkinaFaso,                gettext("Burkina Faso")},
         {QLocale::Benin,                      gettext("Benin")},
         {QLocale::SaoTomeAndPrincipe,         gettext("Sao Tome And Principe")},
         {QLocale::Libya,                      gettext("Libya")},
         {QLocale::Tunisia,                    gettext("Tunisia")},
         {QLocale::Namibia,                    gettext("Namibia")},
         {QLocale::UnitedStates,               gettext("United States")},
         {QLocale::Anguilla,                   gettext("Anguilla")},
         {QLocale::AntiguaAndBarbuda,          gettext("Antigua And Barbuda")},
         {QLocale::Brazil,                     gettext("Brazil")},
         {QLocale::Argentina,                  gettext("Argentina")},
         {QLocale::Aruba,                      gettext("Aruba")},
         {QLocale::Paraguay,                   gettext("Paraguay")},
         {QLocale::Canada,                     gettext("Canada")},
         {QLocale::Mexico,                     gettext("Mexico")},
         {QLocale::Barbados,                   gettext("Barbados")},
         {QLocale::Belize,                     gettext("Belize")},
         {QLocale::Colombia,                   gettext("Colombia")},
         {QLocale::Venezuela,                  gettext("Venezuela")},
         {QLocale::FrenchGuiana,               gettext("French Guiana")},
         {QLocale::CaymanIslands,              gettext("Cayman Islands")},
         {QLocale::CostaRica,                  gettext("Costa Rica")},
         {QLocale::CuraSao,                    gettext("Cura Sao")},
         {QLocale::Greenland,                  gettext("Greenland")},
         {QLocale::Dominica,                   gettext("Dominica")},
         {QLocale::ElSalvador,                 gettext("El Salvador")},
         {QLocale::TurksAndCaicosIslands,      gettext("Turks And Caicos Islands")},
         {QLocale::Grenada,                    gettext("Grenada")},
         {QLocale::Guadeloupe,                 gettext("Guadeloupe")},
         {QLocale::Guatemala,                  gettext("Guatemala")},
         {QLocale::Ecuador,                    gettext("Ecuador")},
         {QLocale::Guyana,                     gettext("Guyana")},
         {QLocale::Cuba,                       gettext("Cuba")},
         {QLocale::Jamaica,                    gettext("Jamaica")},
         {QLocale::Bonaire,                    gettext("Bonaire")},
         {QLocale::Bolivia,                    gettext("Bolivia")},
         {QLocale::Peru,                       gettext("Peru")},
         {QLocale::SintMaarten,                gettext("Sint Maarten")},
         {QLocale::Nicaragua,                  gettext("Nicaragua")},
         {QLocale::SaintMartin,                gettext("Saint Martin")},
         {QLocale::Martinique,                 gettext("Martinique")},
         {QLocale::SaintPierreAndMiquelon,     gettext("Saint Pierre And Miquelon")},
         {QLocale::Uruguay,                    gettext("Uruguay")},
         {QLocale::Montserrat,                 gettext("Montserrat")},
         {QLocale::Bahamas,                    gettext("Bahamas")},
         {QLocale::Panama,                     gettext("Panama")},
         {QLocale::Suriname,                   gettext("Suriname")},
         {QLocale::Haiti,                      gettext("Haiti")},
         {QLocale::TrinidadAndTobago,          gettext("Trinidad And Tobago")},
         {QLocale::PuertoRico,                 gettext("Puerto Rico")},
         {QLocale::Chile,                      gettext("Chile")},
         {QLocale::DominicanRepublic,          gettext("Dominican Republic")},
         {QLocale::SaintBarthelemy,            gettext("Saint Barthelemy")},
         {QLocale::SaintKittsAndNevis,         gettext("Saint Kitts And Nevis")},
         {QLocale::SaintLucia,                 gettext("Saint Lucia")},
         {QLocale::UnitedStatesVirginIslands,  gettext("United States Virgin Islands")},
         {QLocale::SaintVincentAndTheGrenadines, gettext("Saint Vincent And The Grenadines")},
         {QLocale::Honduras,                   gettext("Honduras")},
         {QLocale::BritishVirginIslands,       gettext("British Virgin Islands")},
         {QLocale::Antarctica,                 gettext("Antarctica")},
         {QLocale::Australia,                  gettext("Australia")},
         {QLocale::SvalbardAndJanMayenIslands, gettext("Svalbard And Jan Mayen Islands")},
         {QLocale::Yemen,                      gettext("Yemen")},
         {QLocale::Kazakhstan,                 gettext("Kazakhstan")},
         {QLocale::Jordan,                     gettext("Jordan")},
         {QLocale::Russia,                     gettext("Russia")},
         {QLocale::Turkmenistan,               gettext("Turkmenistan")},
         {QLocale::Iraq,                       gettext("Iraq")},
         {QLocale::Bahrain,                    gettext("Bahrain")},
         {QLocale::Azerbaijan,                 gettext("Azerbaijan")},
         {QLocale::Thailand,                   gettext("Thailand")},
         {QLocale::Lebanon,                    gettext("Lebanon")},
         {QLocale::Kyrgyzstan,                 gettext("Kyrgyzstan")},
         {QLocale::Brunei,                     gettext("Brunei")},
         {QLocale::Mongolia,                   gettext("Mongolia")},
         {QLocale::China,                      gettext("China")},
         {QLocale::SriLanka,                   gettext("Sri Lanka")},
         {QLocale::Syria,                      gettext("Syria")},
         {QLocale::Bangladesh,                 gettext("Bangladesh")},
         {QLocale::EastTimor,                  gettext("East Timor")},
         {QLocale::UnitedArabEmirates,         gettext("United Arab Emirates")},
         {QLocale::Tajikistan,                 gettext("Tajikistan")},
         {QLocale::PalestinianTerritories,     gettext("Palestinian Territories")},
         {QLocale::Vietnam,                    gettext("Vietnam")},
         {QLocale::HongKong,                   gettext("Hong Kong")},
         {QLocale::Indonesia,                  gettext("Indonesia")},
         {QLocale::Israel,                     gettext("Israel")},
         {QLocale::Afghanistan,                gettext("Afghanistan")},
         {QLocale::Pakistan,                   gettext("Pakistan")},
         {QLocale::Nepal,                      gettext("Nepal")},
         {QLocale::India,                      gettext("India")},
         {QLocale::Malaysia,                   gettext("Malaysia")},
         {QLocale::Kuwait,                     gettext("Kuwait")},
         {QLocale::Macau,                      gettext("Macau")},
         {QLocale::Philippines,                gettext("Philippines")},
         {QLocale::Oman,                       gettext("Oman")},
         {QLocale::Cyprus,                     gettext("Cyprus")},
         {QLocale::Cambodia,                   gettext("Cambodia")},
         {QLocale::NorthKorea,                 gettext("North Korea")},
         {QLocale::Qatar,                      gettext("Qatar")},
         {QLocale::Myanmar,                    gettext("Myanmar")},
         {QLocale::SaudiArabia,                gettext("Saudi Arabia")},
         {QLocale::Uzbekistan,                 gettext("Uzbekistan")},
         {QLocale::SouthKorea,                 gettext("South Korea")},
         {QLocale::Singapore,                  gettext("Singapore")},
         {QLocale::Taiwan,                     gettext("Taiwan")},
         {QLocale::Georgia,                    gettext("Georgia")},
         {QLocale::Iran,                       gettext("Iran")},
         {QLocale::Bhutan,                     gettext("Bhutan")},
         {QLocale::Japan,                      gettext("Japan")},
         {QLocale::Laos,                       gettext("Laos")},
         {QLocale::Armenia,                    gettext("Armenia")},
         {QLocale::Portugal,                   gettext("Portugal")},
         {QLocale::Bermuda,                    gettext("Bermuda")},
         {QLocale::CapeVerde,                  gettext("Cape Verde")},
         {QLocale::FaroeIslands,               gettext("Faroe Islands")},
         {QLocale::Iceland,                    gettext("Iceland")},
         {QLocale::SouthGeorgiaAndTheSouthSandwichIslands, gettext("South Georgia And The South Sandwich Islands")},
         {QLocale::SaintHelena,                gettext("Saint Helena")},
         {QLocale::FalklandIslands,            gettext("Falkland Islands")},
         {QLocale::Netherlands,                gettext("Netherlands")},
         {QLocale::Andorra,                    gettext("Andorra")},
         {QLocale::Greece,                     gettext("Greece")},
         {QLocale::Serbia,                     gettext("Serbia")},
         {QLocale::Germany,                    gettext("Germany")},
         {QLocale::Slovakia,                   gettext("Slovakia")},
         {QLocale::Belgium,                    gettext("Belgium")},
         {QLocale::Romania,                    gettext("Romania")},
         {QLocale::Hungary,                    gettext("Hungary")},
         {QLocale::Moldova,                    gettext("Moldova")},
         {QLocale::Denmark,                    gettext("Denmark")},
         {QLocale::Ireland,                    gettext("Ireland")},
         {QLocale::Gibraltar,                  gettext("Gibraltar")},
         {QLocale::Guernsey,                   gettext("Guernsey")},
         {QLocale::Finland,                    gettext("Finland")},
         {QLocale::IsleOfMan,                  gettext("Isle Of Man")},
         {QLocale::Turkey,                     gettext("Turkey")},
         {QLocale::Jersey,                     gettext("Jersey")},
         {QLocale::Ukraine,                    gettext("Ukraine")},
         {QLocale::Slovenia,                   gettext("Slovenia")},
         {QLocale::UnitedKingdom,              gettext("United Kingdom")},
         {QLocale::Luxembourg,                 gettext("Luxembourg")},
         {QLocale::Malta,                      gettext("Malta")},
         {QLocale::AlandIslands,               gettext("Aland Islands")},
         {QLocale::Belarus,                    gettext("Belarus")},
         {QLocale::Monaco,                     gettext("Monaco")},
         {QLocale::Norway,                     gettext("Norway")},
         {QLocale::France,                     gettext("France")},
         {QLocale::Montenegro,                 gettext("Montenegro")},
         {QLocale::CzechRepublic,              gettext("Czech Republic")},
         {QLocale::Latvia,                     gettext("Latvia")},
         {QLocale::Italy,                      gettext("Italy")},
         {QLocale::SanMarino,                  gettext("San Marino")},
         {QLocale::BosniaAndHerzegowina,       gettext("Bosnia And Herzegowina")},
         {QLocale::Macedonia,                  gettext("Macedonia")},
         {QLocale::Bulgaria,                   gettext("Bulgaria")},
         {QLocale::Sweden,                     gettext("Sweden")},
         {QLocale::Estonia,                    gettext("Estonia")},
         {QLocale::Albania,                    gettext("Albania")},
         {QLocale::Liechtenstein,              gettext("Liechtenstein")},
         {QLocale::VaticanCityState,           gettext("Vatican City State")},
         {QLocale::Austria,                    gettext("Austria")},
         {QLocale::Lithuania,                  gettext("Lithuania")},
         {QLocale::Poland,                     gettext("Poland")},
         {QLocale::Croatia,                    gettext("Croatia")},
         {QLocale::Switzerland,                gettext("Switzerland")},
         {QLocale::Madagascar,                 gettext("Madagascar")},
         {QLocale::BritishIndianOceanTerritory, gettext("British Indian Ocean Territory")},
         {QLocale::ChristmasIsland,            gettext("ChristmasIsland")},
         {QLocale::CocosIslands,               gettext("CocosIslands")},
         {QLocale::Comoros,                    gettext("Comoros")},
         {QLocale::FrenchSouthernTerritories,  gettext("French Southern Territories")},
         {QLocale::Seychelles,                 gettext("Seychelles")},
         {QLocale::Maldives,                   gettext("Maldives")},
         {QLocale::Mauritius,                  gettext("Mauritius")},
         {QLocale::Mayotte,                    gettext("Mayotte")},
         {QLocale::Reunion,                    gettext("Reunion")},
         {QLocale::Samoa,                      gettext("Samoa")},
         {QLocale::NewZealand,                 gettext("New Zealand")},
         {QLocale::Micronesia,                 gettext("Micronesia")},
         {QLocale::Vanuatu,                    gettext("Vanuatu")},
         {QLocale::Kiribati,                   gettext("Kiribati")},
         {QLocale::Tokelau,                    gettext("Tokelau")},
         {QLocale::Fiji,                       gettext("Fiji")},
         {QLocale::Tuvalu,                     gettext("Tuvalu")},
         {QLocale::FrenchPolynesia,            gettext("French Polynesia")},
         {QLocale::SolomonIslands,             gettext("Solomon Islands")},
         {QLocale::Guam,                       gettext("Guam")},
         {QLocale::UnitedStatesMinorOutlyingIslands, gettext("United States Minor Outlying Islands")},
         {QLocale::MarshallIslands,            gettext("Marshall Islands")},
         {QLocale::NauruCountry,               gettext("Nauru")},
         {QLocale::Niue,                       gettext("Niue")},
         {QLocale::NorfolkIsland,              gettext("Norfolk Island")},
         {QLocale::NewCaledonia,               gettext("New Caledonia")},
         {QLocale::AmericanSamoa,              gettext("American Samoa")},
         {QLocale::Palau,                      gettext("Palau")},
         {QLocale::Pitcairn,                   gettext("Pitcairn")},
         {QLocale::PapuaNewGuinea,             gettext("Papua New Guinea")},
         {QLocale::CookIslands,                gettext("Cook Islands")},
         {QLocale::NorthernMarianaIslands,     gettext("Northern Mariana Islands")},
         {QLocale::Tonga,                      gettext("Tonga")},
         {QLocale::Kosovo,                     gettext("Kosovo")},
         {QLocale::WallisAndFutunaIslands,     gettext("Wallis And Futuna Islands")} });
    }

    QString countryToString(QLocale::Country c) {
        return m_countryNames.value(c);
    }

private:
    QHash<QLocale::Country, QString> m_countryNames;
};

Q_GLOBAL_STATIC(LocalePrivate, d)

LocaleAttached::LocaleAttached(QObject* parent)
    : QObject(parent)
{
}

QJsonObject LocaleAttached::languages() const
{
    QJsonObject result;
    for (int i = QLocale::C + 1; i < QLocale::LastLanguage; ++i) {
        QLocale loc(static_cast<QLocale::Language>(i));
        result.insert(loc.name().split('_').first(), QLocale::languageToString(loc.language()));
    }

    return result;
}

QJsonObject LocaleAttached::countriesForLanguage(const QString &code) const
{
    QLocale tmp(code);
    const QList<QLocale> allLocales = QLocale::matchingLocales(tmp.language(), QLocale::AnyScript, QLocale::AnyCountry);
    QJsonObject result;
    Q_FOREACH(const QLocale &loc, allLocales) {
        const QString countryCode = loc.name().section('_', 1, 1);
        //qDebug() << "Matching country:" << countryCode;
        if (!countryCode.isEmpty()) {
            result.insert(countryCode, d->countryToString(loc.country()));
        }
    }
    return result;
}

QJsonObject LocaleAttached::countries() const
{
    const QList<QLocale> allLocales = QLocale::matchingLocales(QLocale::AnyLanguage, QLocale::AnyScript, QLocale::AnyCountry);
    QJsonObject result;

    Q_FOREACH(const QLocale &loc, allLocales) {
        const QString countryCode = loc.name().section('_', 1, 1);
        if (countryCode.length() == 2) {
            result.insert(countryCode, d->countryToString(loc.country()));
        }
    }

    return result;
}

QString LocaleAttached::countryToString(QLocale::Country c)
{
    return d->countryToString(c);
}


LocalePlugin::LocalePlugin(QObject* parent)
    : QObject(parent)
{
}

LocaleAttached* LocalePlugin::qmlAttachedProperties(QObject* parent)
{
    return new LocaleAttached(parent);
}

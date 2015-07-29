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

        m_mccCodes = QHash<int, QString>
                ({{202,"gr"},
                  {204,"nl"},
                  {206,"be"},
                  {208,"fr"},
                  {212,"mc"},
                  {213,"ad"},
                  {214,"es"},
                  {216,"hu"},
                  {218,"ba"},
                  {219,"hr"},
                  {220,"rs"},
                  {222,"it"},
                  {226,"ro"},
                  {228,"ch"},
                  {230,"cz"},
                  {231,"sk"},
                  {232,"at"},
                  {234,"gb"},
                  {235,"gb"},
                  {238,"dk"},
                  {240,"se"},
                  {242,"no"},
                  {244,"fi"},
                  {246,"lt"},
                  {247,"lv"},
                  {248,"ee"},
                  {250,"ru"},
                  {255,"ua"},
                  {257,"by"},
                  {259,"md"},
                  {260,"pl"},
                  {262,"de"},
                  {266,"gi"},
                  {268,"pt"},
                  {270,"lu"},
                  {272,"ie"},
                  {274,"is"},
                  {276,"al"},
                  {278,"mt"},
                  {280,"cy"},
                  {282,"ge"},
                  {283,"am"},
                  {284,"bg"},
                  {286,"tr"},
                  {288,"fo"},
                  {289,"ge"},
                  {290,"gl"},
                  {292,"sm"},
                  {293,"si"},
                  {294,"mk"},
                  {295,"li"},
                  {297,"me"},
                  {302,"ca"},
                  {308,"pm"},
                  {310,"gu"},
                  {310,"us"},
                  {311,"gu"},
                  {311,"us"},
                  {312,"us"},
                  {316,"us"},
                  {330,"pr"},
                  {334,"mx"},
                  {338,"jm"},
                  {340,"fg"},
                  {340,"gp"},
                  {340,"mq"},
                  {342,"bb"},
                  {344,"ag"},
                  {346,"ky"},
                  {348,"vg"},
                  {350,"bm"},
                  {352,"gd"},
                  {354,"ms"},
                  {356,"kn"},
                  {358,"lc"},
                  {360,"vc"},
                  {362,"an"},
                  {362,"cw"},
                  {363,"aw"},
                  {364,"bs"},
                  {365,"ai"},
                  {366,"dm"},
                  {368,"cu"},
                  {370,"do"},
                  {372,"ht"},
                  {374,"tt"},
                  {376,"tc"},
                  {376,"vi"},
                  {400,"az"},
                  {401,"kz"},
                  {402,"bt"},
                  {404,"in"},
                  {405,"in"},
                  {410,"pk"},
                  {412,"af"},
                  {413,"lk"},
                  {414,"mm"},
                  {415,"lb"},
                  {416,"jo"},
                  {417,"sy"},
                  {418,"iq"},
                  {419,"kw"},
                  {420,"sa"},
                  {421,"ye"},
                  {422,"om"},
                  {424,"ae"},
                  {425,"il"},
                  {425,"ps"},
                  {426,"bh"},
                  {427,"qa"},
                  {428,"mn"},
                  {429,"np"},
                  {430,"ae"},
                  {431,"ae"},
                  {432,"ir"},
                  {434,"uz"},
                  {436,"tk"},
                  {437,"kg"},
                  {438,"tm"},
                  {440,"jp"},
                  {441,"jp"},
                  {450,"kr"},
                  {452,"vn"},
                  {454,"hk"},
                  {455,"mo"},
                  {456,"kh"},
                  {457,"la"},
                  {460,"cn"},
                  {466,"tw"},
                  {467,"kp"},
                  {470,"bd"},
                  {472,"mv"},
                  {502,"my"},
                  {505,"au"},
                  {510,"id"},
                  {514,"tp"},
                  {515,"ph"},
                  {520,"th"},
                  {525,"sg"},
                  {528,"bn"},
                  {530,"nz"},
                  {537,"pg"},
                  {539,"to"},
                  {540,"sb"},
                  {541,"vu"},
                  {542,"fj"},
                  {544,"as"},
                  {545,"ki"},
                  {546,"nc"},
                  {547,"pf"},
                  {548,"ck"},
                  {549,"ws"},
                  {550,"fm"},
                  {552,"pw"},
                  {553,"tv"},
                  {555,"nu"},
                  {602,"eg"},
                  {603,"dz"},
                  {604,"ma"},
                  {605,"tn"},
                  {606,"ly"},
                  {607,"gm"},
                  {608,"sn"},
                  {609,"mr"},
                  {610,"ml"},
                  {611,"gn"},
                  {612,"ci"},
                  {613,"bf"},
                  {614,"ne"},
                  {615,"tg"},
                  {616,"bj"},
                  {617,"mu"},
                  {618,"lr"},
                  {619,"sl"},
                  {620,"gh"},
                  {621,"ng"},
                  {622,"td"},
                  {623,"cf"},
                  {624,"cm"},
                  {625,"cv"},
                  {626,"st"},
                  {627,"gq"},
                  {628,"ga"},
                  {629,"cg"},
                  {630,"cd"},
                  {631,"ao"},
                  {632,"gw"},
                  {633,"sc"},
                  {634,"sd"},
                  {635,"rw"},
                  {636,"et"},
                  {637,"so"},
                  {638,"dj"},
                  {639,"ke"},
                  {640,"tz"},
                  {641,"ug"},
                  {642,"bi"},
                  {643,"mz"},
                  {645,"zm"},
                  {646,"mg"},
                  {647,"re"},
                  {648,"zw"},
                  {649,"na"},
                  {650,"mw"},
                  {651,"ls"},
                  {652,"bw"},
                  {653,"sz"},
                  {654,"km"},
                  {655,"za"},
                  {657,"er"},
                  {659,"ss"},
                  {702,"bz"},
                  {704,"gt"},
                  {706,"sv"},
                  {708,"hn"},
                  {710,"ni"},
                  {712,"cr"},
                  {714,"pa"},
                  {716,"pe"},
                  {722,"ar"},
                  {724,"br"},
                  {730,"cl"},
                  {732,"co"},
                  {734,"ve"},
                  {736,"bo"},
                  {738,"gy"},
                  {740,"ec"},
                  {744,"py"},
                  {746,"sr"},
                  {748,"uy"},
                  {750,"fk"}}
                 );
    }

    QString countryToString(QLocale::Country c) const {
        return m_countryNames.value(c);
    }

    QString mccToCountryCode(int mcc) const {
        return m_mccCodes.value(mcc, "us").toUpper();
    }

private:
    QHash<QLocale::Country, QString> m_countryNames;
    QHash<int,QString> m_mccCodes;
};

Q_GLOBAL_STATIC(LocalePrivate, d)

LocaleAttached::LocaleAttached(QObject* parent)
    : QObject(parent)
{
}

QJsonObject LocaleAttached::languages() const
{
    QJsonObject result;

    const QList<QLocale> allLocales = QLocale::matchingLocales(QLocale::AnyLanguage, QLocale::AnyScript, QLocale::AnyCountry);
    Q_FOREACH(const QLocale &loc, allLocales) {
        result.insert(loc.name().split('_').first(), loc.nativeLanguageName());
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

QString LocaleAttached::qlocToCountryCode(QLocale::Country c)
{
    const QList<QLocale> locales = QLocale::matchingLocales(QLocale::AnyLanguage, QLocale::AnyScript, c);
    if (!locales.isEmpty()) {
        return locales.first().name().section('_', 1, 1);
    }

    return QString();
}

QString LocaleAttached::mccToCountryCode(int mcc) const
{
    return d->mccToCountryCode(mcc);
}

LocalePlugin::LocalePlugin(QObject* parent)
    : QObject(parent)
{
}

LocaleAttached* LocalePlugin::qmlAttachedProperties(QObject* parent)
{
    return new LocaleAttached(parent);
}

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

    QString mccToCountryCode(int mcc) const {
        return m_mccCodes.value(mcc, "us").toUpper();
    }

private:
    // MCC = Mobile Country Code, see https://en.wikipedia.org/wiki/Mobile_country_code
    QHash<int,QString> m_mccCodes;
};

Q_GLOBAL_STATIC(LocalePrivate, d)

LocaleAttached::LocaleAttached(QObject* parent)
    : QObject(parent)
{
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

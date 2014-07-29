#ifndef RELATIVETIMEFORMATTER_H
#define RELATIVETIMEFORMATTER_H

#include "timeformatter.h"

class RelativeTimeFormatter : public GDateTimeFormatter
{
    Q_OBJECT
public:
    RelativeTimeFormatter(QObject *parent = 0);

    QString format() const override;
};

#endif // RELATIVETIMEFORMATTER_H

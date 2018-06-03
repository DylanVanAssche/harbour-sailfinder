#ifndef ENUM_H
#define ENUM_H

#include <QtCore/QObject>
#include <QtCore/QMetaType>
#include <QtNetwork/QNetworkConfiguration>

class Sailfinder
{
    // Enums can use the lightweight Q_GADGET type instead of Q_OBJECT
    Q_GADGET

public:
    explicit Sailfinder();

    enum class Gender {
        Male = 0,
        Female = 1,
        All = 2
    };

    enum class Size {
        Avatar = 0, // 84x84
        Small = 1, // 172x172
        Medium = 2, // 320x320
        Large = 3, // 640x640
        Full = 5 // 1080x1080
    };

    // Stripped down from QNetworkConfiguration
    enum class ConnectionType {
        Ethernet = QNetworkConfiguration::BearerEthernet,
        WLAN = QNetworkConfiguration::BearerWLAN,
        LTE = QNetworkConfiguration::Bearer4G,
        UTMS = QNetworkConfiguration::Bearer3G,
        GRPS = QNetworkConfiguration::Bearer2G
    };

    Q_ENUMS(Gender)
    Q_ENUMS(Size)
    Q_ENUMS(ConnectionType)
};

Q_DECLARE_METATYPE(Sailfinder::Gender)
Q_DECLARE_METATYPE(Sailfinder::Size)


#endif // ENUM_H

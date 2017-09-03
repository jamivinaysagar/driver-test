#!/bin/sh

INTERFACE=
DRIVERTYPE=
NETWORK=
PASSWORD=
PINGLOC=
FORCEVERSION="true"

usage()
{
    echo "Usage: $0 [OPTIONS]" >&2
    echo ""
    echo "Options: -i [Interface]           The WiFi interface. Defaults to wlan0."
    echo "         -d [Driver Type]         The driver type for wpa_supplicant. Defaults to nl80211."
    echo "         -n [Network ssid]        The ssid of the network to connect to."
    echo "         -p [Password]            The password for the ssid being connected to."
    echo "         -l [Ping Location]       The domain to ping."
    echo "         -u [Use any version]     Allows any version of wpa_supplicant to be used."
    echo "Examples: $0 -i wlan0 -d nl80211"
    echo "          $0 -n NETGEAR00 -p pass123 -l kernel.org"
}

versioncheck()
{
    VERSION=$(wpa_supplicant -v | grep -o -E '[0-9]' | head -1)

    if [ "$VERSION" -lt "2" ] || [ -z "$VERSION" ]; then
        echo "This test requires that wpa_supplicant's version be at least 2.0."
        echo "This is because earlier versions are known to cause problems on some systems."
        echo "If factory is being used, select wpa_supplicant2. This may require cleaning the"
        echo "rfs completely and then rebuilding it."
        echo ""
        echo "This behavior can be overidden with the -u flag."

        exit 1;
    fi
}

while getopts ":i:d:n:p:l:u" opt; do
    case "$opt" in
    i)
        INTERFACE=$OPTARG
        ;;
    d)
        FILE_PATH=$OPTARG
        ;;
    n)
        NETWORK=$OPTARG
        ;;
    p)
        PASSWORD=$OPTARG
        ;;
    l)
        PINGLOC=$OPTARG
        ;;
    u)
        FORCEVERSION=""
        ;;
    \?)
        usage
        exit 1
        ;;
    esac
done

if [ -z "$FORCEVERSION" ]; then
    echo 'Using any version of wpa_supplicant for this test.'
    echo ''
else
    versioncheck
fi

if [ -z "$INTERFACE" ]; then
    INTERFACE=wlan0
fi

if [ -z "$DRIVERTYPE" ]; then
    DRIVERTYPE=nl80211
fi

if [ -z "$NETWORK" ] || [ -z "$PASSWORD" ]; then
    SKIPCONNECTIONTEST=1
    echo "Skipping connection test"
fi

if [ -z "$PINGLOC" ]; then
    SKIPPINGTEST=1
    echo "Skipping ping test"
fi

if ! ifconfig $INTERFACE; then
    echo "Device $INTERFACE not found!"
    exit 1
fi

# Disable RFKill
if which rfkill > /dev/null; then
    rfkill unblock all
fi

if [ -z "$SKIPCONNECTIONTEST" ]; then
    killall wpa_supplicant
    wpa_passphrase $NETWORK $PASSWORD > /tmp/wpa.conf
    wpa_supplicant -D $DRIVERTYPE -c/tmp/wpa.conf -i$INTERFACE -B

    if ! udhcpc -i $INTERFACE -t 5 -n; then
        echo "Could not get IP Address from $NETWORK"
	killall wpa_supplicant
	rm /tmp/wpa.conf
        exit 1
    fi

    if [ -z "$SKIPPINGTEST" ] && ! ping $PINGLOC -c 5; then
        echo "Could not connect to internet"
	killall wpa_supplicant
	rm /tmp/wpa.conf
        exit 1
    fi

    killall wpa_supplicant
    rm /tmp/wpa.conf
fi

exit 0

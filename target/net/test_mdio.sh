#!/bin/sh

# write to SMI PHY Command Register to read from PHY Identify Registers
# verify Marvell Organizationally Unique Identifier, model number, and revision
# see page 438 of 88E6240 Functional Specification, Doc. No. MV-S108006-00

echo "w 1c 18 9802" > /dev/mdio-gpio-char	# read PHY register 0x2
echo "r 1c 19" > /dev/mdio-gpio-char		# read result
REGTWO=$(cat /dev/mdio-gpio-char)
TWO="read phy: 1C	reg: 19		val:0141"

echo "w 1c 18 9803" > /dev/mdio-gpio-char	# read PHY register 0x3
echo "r 1c 19" > /dev/mdio-gpio-char		# read result
REGTHREE=$(cat /dev/mdio-gpio-char)
THREE="read phy: 1C	reg: 19		val:0EB1"

if [[ "$REGTWO" == "$TWO" ]]; then
    if [[ "$REGTHREE" == "$THREE" ]]; then
        echo "+++ Files match"
        exit 0
    fi
fi

echo "+++ Data mismatch"
exit 1

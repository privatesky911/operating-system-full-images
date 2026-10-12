#!/bin/bash
# flash-ums.sh - Flash HA OS image via UMS (USB Mass Storage) mode through serial
# Usage: ./flash-ums.sh [image_path]

set -e
SERIAL="/dev/ttyUSB0"
BAUD=1500000

echo "=== Entering UMS mode via serial ==="
sudo python3 -c "
import serial, time, sys
ser = serial.Serial('$SERIAL', $BAUD, timeout=0.2)

# Login and reboot
ser.write(b'\n')
time.sleep(0.5)
d = ser.read(4096)
if b'#' in d or b'login' in d:
    if b'login' in d:
        ser.write(b'root\n')
        time.sleep(0.3)
        ser.write(b'\n')
        time.sleep(1)
        ser.read(4096)
    ser.write(b'reboot -f\n')
    time.sleep(1)
    ser.read(16384)
    for i in range(40):
        ser.write(b' ')
        time.sleep(0.1)
        d = ser.read(16384)
        if b'HAOS>' in d:
            ser.write(b'ums 0 mmc 0\n')
            time.sleep(3)
            print('UMS started')
            break
ser.close()
"

echo "=== Waiting for block device ==="
for i in $(seq 1 10); do
    sleep 1
    if lsblk -o NAME 2>/dev/null | grep -q '^sda$'; then
        echo "Device /dev/sda found"
        break
    fi
done

if ! lsblk -o NAME 2>/dev/null | grep -q '^sda$'; then
    echo "ERROR: /dev/sda not found"
    exit 1
fi

echo "=== Done ==="

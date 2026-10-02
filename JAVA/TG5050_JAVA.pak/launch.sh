#!/bin/sh
ROM="$1"
EMU_ROOT="/mnt/SDCARD/Emus/JAVA"
if [ -f "$EMU_ROOT/launch.sh" ]; then
    exec "$EMU_ROOT/launch.sh" "$ROM"
else
    cd "$EMU_ROOT/zulu17/bin"
    exec ./java -Djava.awt.headless=true -jar ./freej2me-sdl.jar "$ROM"
fi
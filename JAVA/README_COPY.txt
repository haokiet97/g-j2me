COPY NHANH - CHỈ CẦN COPY THƯ MỤC NÀY
======================================

CẤU TRÚC:
JAVA/
├── launch.sh              # Script chính chạy game
├── config.json            # Cấu hình emulator
├── cpuswitch.sh           # Chuyển CPU governor
├── cpufreq.sh             # Đặt tần số CPU
├── *.png                  # Icon (32.png, 80.png, i.png, bg.png)
├── zulu17/
│   ├── bin/
│   │   ├── java                  # JVM executable
│   │   ├── freej2me-sdl.jar      # Emulator core
│   │   ├── sdl_interface         # SDL native lib
│   │   ├── font.ttf              # Font
│   │   ├── control_profile.cfg   # Profile điều khiển
│   │   ├── control_cycle.cfg     # Cycle điều khiển
│   │   ├── keymap.cfg            # Map phím
│   │   ├── renderer.conf         # Render settings
│   │   ├── keytool               # Keytool
│   │   └── shaders/              # 6 shader files
│   └── lib/
│       ├── *.so (26 files)       # Native libraries
│       ├── jrt-fs.jar
│       ├── jspawnhelper
│       ├── jvm.cfg
│       └── jexec
├── timidity/
│   ├── timidity.cfg
│   └── instruments/ (128 file .pat)
├── LICENSES/ (4 file license)
├── TG5040_JAVA.pak/launch.sh   # Cho NextUI TG5040
└── TG5050_JAVA.pak/launch.sh   # Cho NextUI TG5050


CÁCH COPY (chạy trên thiết bị - TrimUI/NextUI):

1. Copy thư mục JAVA -> /mnt/SDCARD/Emus/JAVA
   cp -r JAVA /mnt/SDCARD/Emus/JAVA

2. Copy 2 file NextUI pak:
   cp -r JAVA/TG5040_JAVA.pak /mnt/SDCARD/Emus/TG5040/JAVA.pak
   cp -r JAVA/TG5050_JAVA.pak /mnt/SDCARD/Emus/TG5050/JAVA.pak

3. XONG! Chạy game:
   /mnt/SDCARD/Emus/JAVA/launch.sh /path/to/game.jar


LƯU Ý:
- Đã chmod +x sẵn các file executable
- render_mode mặc định trong renderer.conf
- User data (RMS, config) sẽ tự tạo khi chạy lần đầu
- Không cần chạy script install_j2me.sh
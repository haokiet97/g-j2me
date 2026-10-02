HƯỚNG DẪN CÀI ĐẶT (COPY FOLDER JAVA/)
=========================================

Folder JAVA/ ở root project đã chứa toàn bộ file cần thiết, đã chmod +x sẵn.

CÁCH CÀI ĐẶT (chạy trên thiết bị - TrimUI/NextUI):
---------------------------------------------------

1. Copy thư mục JAVA -> /mnt/SDCARD/Emus/JAVA
   cp -r /path/to/project/JAVA /mnt/SDCARD/Emus/JAVA

2. Copy 2 file NextUI pak (cho TG5040/TG5050):
   cp -r /path/to/project/JAVA/TG5040_JAVA.pak /mnt/SDCARD/Emus/TG5040/JAVA.pak
   cp -r /path/to/project/JAVA/TG5050_JAVA.pak /mnt/SDCARD/Emus/TG5050/JAVA.pak

3. XONG! Chạy game:
   /mnt/SDCARD/Emus/JAVA/launch.sh /path/to/game.jar


LƯU Ý:
- Đã chmod +x sẵn các file executable
- render_mode mặc định trong zulu17/bin/renderer.conf
- User data (RMS, config) sẽ tự tạo khi chạy lần đầu
- Không cần chạy script install_j2me.sh
- Script install_j2me.sh dùng cho: backup/restore user data, auto-upgrade bản cũ, giữ render settings
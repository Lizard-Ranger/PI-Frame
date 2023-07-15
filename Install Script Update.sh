#!/bin/sh

# Create the Directory for the Mapped Drive.
mkdir /home/pi/frame
chmod +rw /home/pi/frame
chown pi /home/pi/frame

# Creating of Script (feh.sh)
echo '#!/bin/sh' >> /home/pi/frame/feh.sh
echo DISPLAY=:0.0 XAUTHORITY=/home/pi/.Xauthority /usr/bin/feh -q -p -z -F -R  60 -Y -D 60.0 /home/pi/Pictures >> /home/pi/frame/feh.sh

#Setting file Permissions
chmod +rwx /home/pi/frame/feh.sh
chown pi /home/pi/frame/feh.sh

# Creating of Script (gdconnect.sh)
echo '#!/bin/sh' >> /home/pi/frame/gdconnect.sh
echo google-drive-ocamlfuse /home/pi/MyGDrive >> /home/pi/frame/gdconnect.sh

#Setting file Permissions
chmod +rwx /home/pi/frame/gdconnect.sh
chown pi /home/pi/frame/gdconnect.sh

# Creating of Script (GDrive_sync.sh)
echo '#!/bin/sh' >> /home/pi/frame/GDrive_sync.sh
echo rm /home/pi/Pictures/* >> /home/pi/frame/GDrive_sync.sh
echo rm -rf ~/.local/share/Trash/* >> /home/pi/frame/GDrive_sync.sh
echo 'rsync -r /home/pi/MyGDrive/Picture-Frame/pictures/* /home/pi/Pictures' >> /home/pi/frame/GDrive_sync.sh
echo sudo shutdown -r now >> /home/pi/frame/GDrive_sync.sh

#Setting file Permissions
chmod +rwx /home/pi/frame/GDrive_sync.sh
chown pi /home/pi/frame/GDrive_sync.sh

# Creating of Script (GDrive_sync_update.sh)
echo '#!/bin/sh' >> /home/pi/frame/GDrive_sync_update.sh
echo 'rsync -r /home/pi/MyGDrive/Picture-Frame/pictures/* /home/pi/Pictures' >> /home/pi/frame/GDrive_sync_update.sh

#Setting file Permissions
chmod +rwx /home/pi/frame/GDrive_sync_update.sh
chmod +rwx /home/pi/frame/GDrive_sync_update.sh

# Updating Crontab for some auotmation and automatic updating.
(crontab -u pi -l; echo "* 0 * * 1 shutdown -r now >/dev/null 2>&1" ) | crontab -u pi -
(crontab -u pi -l; echo "@reboot /home/pi/frame/gdconnect.sh") | crontab -u pi -
(crontab -u pi -l; echo "@reboot /home/pi/frame/feh.sh") | crontab -u pi -
(crontab -u pi -l; echo "* 0 * * 5 /home/pi/frame/Gdrive_sync.sh >/dev/null 2>&1") | crontab -u pi -
(crontab -u pi -l; echo "0 0 * * 1,3 /home/pi/frame/GDrive_sync_update.sh >/dev/null 2>&1") | crontab -u pi -

./frame/GDrive_sync.sh
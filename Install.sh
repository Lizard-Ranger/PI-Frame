#!/bin/sh

# Set the username and new password
username="root"
new_password="password"

# Change the user's password
echo -e "$new_password\n$new_password" | sudo passwd $username > /dev/null 2>&1

# Check if the script is being run with root privileges
if [ "$(id -u)" -ne 0 ]; then
  # If not running as root, re-execute the script with sudo
  exec sudo "$0" "$@"
fi

# Update and Upgrade System
apt update && sudo apt upgrade -y

# Install required app (NTP - keep time correct, FEH - Picture Frame app, RSYNC - to copy pictures Xscreensaver)
apt install ntp feh rsync xscreensaver -y

# Check if the password change was successful
if [ $? -eq 0 ]; then
    echo "Password changed successfully for user $username."
else
    echo "Failed to change the password for user $username."
fi

# Install Rustdesk (Teamviewer Alternative) - Is Open Source
wget https://github.com/rustdesk/rustdesk/releases/download/1.1.9/rustdesk-1.1.9-raspberry-armhf.deb
chmod rustdesk-1.1.9-raspberry-armhf.deb
sudo dpkg --install rustdesk-1.1.9-raspberry-armhf.deb -y

# Disable Bluetooth
echo dtoverlay=pi3-disable-bt >> /boot/config.txt

# Disable Screen Saver
rm /home/pi/.xscreensaver
echo mode: off >> /home/pi/.xscreensaver

# Add Repos for the Google Drive Connector
echo deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main >> /etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa-bionic.list
echo deb-src http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main >> /etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa-bionic.list

# Install Certificates and Install Google Drive Connector
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AD5F235DF639B041
apt update -y
apt install -y google-drive-ocamlfuse

# Create the Directory for the Mapped Drive
mkdir /home/pi/MyGDrive
google-drive-ocamlfuse /home/pi/MyGDrive

# Creating of Script (feh.sh)
echo '#!/bin/sh' >> /home/pi/feh.sh
echo DISPLAY=:0.0 XAUTHORITY=/home/pi/.Xauthority /usr/bin/feh -q -p -z -F -R  60 -Y -D 60.0 /home/pi/Pictures >> /home/pi/feh.sh

# Creating of Script (gdconnect.sh)
echo '#!/bin/sh' >> /home/pi/gdconnect.sh
echo google-drive-ocamlfuse /home/pi/MyGDrive >> /home/pi/gdconnect.sh

# Creating of Script (GDrive_sync.sh)
echo '#!/bin/sh' >> /home/pi/GDrive_sync.sh
echo rm /home/pi/Pictures/* >> /home/pi/GDrive_sync.sh
echo rm -rf ~/.local/share/Trash/* >> /home/pi/GDrive_sync.sh
echo 'rsync -r /home/pi/MyGDrive/* /home/pi/Pictures' >> /home/pi/GDrive_sync.sh
echo sudo shutdown -r now >> /home/pi/GDrive_sync.sh

#Setting file Permissions
chmod +rwx feh.sh
chown pi feh.sh
chmod +rwx gdconnect.sh
chown pi gdconnect.sh
chmod +rwx GDrive_sync.sh
chown pi GDrive_sync.sh
chmod +rw /home/pi/MyGDrive
chown pi /home/pi/MyGDrive

# Updating Crontab for some auotmation and automatic updating.
(crontab -u pi -l; echo "@reboot /home/pi/gdconnect.sh") | crontab -u pi -
(crontab -u pi -l; echo "@reboot /home/pi/feh.sh") | crontab -u pi -
(crontab -u pi -l; echo "* 0 * * 5 /home/pi/Gdrive_sync.sh >/dev/null 2>&1") | crontab -u pi -

# User Note
echo Please run "google-drive-ocamlfuse /home/pi/MyGDrive" from the terminal on your linux desktop.
echo Once the url is given in the terminal screen please run it in your browser.
echo Login to Google and Grant permission, then reboot.
echo Thank you for using this script.
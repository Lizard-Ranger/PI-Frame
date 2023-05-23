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
sudo dpkg --install rustdesk-1.1.9-raspberry-armhf.deb

# Disable Bluetooth.
echo dtoverlay=pi3-disable-bt >> /boot/config.txt

# Disable Screen Saver.
rm /home/pi/.xscreensaver
echo mode: off >> /home/pi/.xscreensaver

# Add Repos for the Google Drive Connector.
echo deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main >> /etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa-bionic.list
echo deb-src http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main >> /etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa-bionic.list

# Install Certificates and Install Google Drive Connector.
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AD5F235DF639B041
apt update -y
apt install -y google-drive-ocamlfuse

# Create the Directory for the Mapped Drive.
mkdir /home/pi/frame
mkdir /home/pi/frame/commands

# Create the Directory for the Picture Frame Scripts.
mkdir /home/pi/MyGDrive
google-drive-ocamlfuse /home/pi/MyGDrive/

# Creating of Script (feh.sh)
echo '#!/bin/sh' >> /home/pi/frame/feh.sh
echo DISPLAY=:0.0 XAUTHORITY=/home/pi/.Xauthority /usr/bin/feh -q -p -z -F -R  60 -Y -D 60.0 /home/pi/Pictures >> /home/pi/frame/feh.sh

# Creating of Script (gdconnect.sh)
echo '#!/bin/sh' >> /home/pi/frame/gdconnect.sh
echo google-drive-ocamlfuse /home/pi/MyGDrive >> /home/pi/frame/gdconnect.sh

# Creating of Script (GDrive_sync.sh)
echo '#!/bin/sh' >> /home/pi/frame/GDrive_sync.sh
echo rm /home/pi/Pictures/* >> /home/pi/frame/GDrive_sync.sh
echo rm -rf ~/.local/share/Trash/* >> /home/pi/frame/GDrive_sync.sh
echo 'rsync -r /home/pi/MyGDrive/mpf/pictures/* /home/pi/Pictures' >> /home/pi/frame/GDrive_sync.sh
echo sudo shutdown -r now >> /home/pi/frame/GDrive_sync.sh

# Creating of Script (Manual_Sync.py)
echo import os >> /home/pi/frame/Manual_Sync.py
echo file_path = '/home/pi/MyGDrive/mpf/to_sync.txt' >> /home/pi/frame/Manual_Sync.py
echo #
echo # Read the contents of the file >> /home/pi/frame/Manual_Sync.py
echo with open(file_path, 'r') as file: >> /home/pi/frame/Manual_Sync.py
echo     file_contents = file.read() >> /home/pi/frame/Manual_Sync.py
echo #
echo '# Check if the file contents are true' >> /home/pi/frame/Manual_Sync.py
echo if file_contents.strip() == 'true': >> /home/pi/frame/Manual_Sync.py
echo     '# Change the value to false' >> /home/pi/frame/Manual_Sync.py
echo     file_contents = file_contents.replace('true', 'false') >> /home/pi/frame/Manual_Sync.py
echo #
echo     '# Write the modified contents back to the file' >> /home/pi/frame/Manual_Sync.py
echo     with open(file_path, 'w') as file: >> /home/pi/frame/Manual_Sync.py
echo         file.write(file_contents) >> /home/pi/frame/Manual_Sync.py
echo     print('Value changed from true to false') >> /home/pi/frame/Manual_Sync.py
echo #
echo     '# Perform system reboot' >> /home/pi/frame/Manual_Sync.py
echo     os.system('./home/pi/frame/Force_Google_Sync.sh') >> /home/pi/frame/Manual_Sync.py
echo else: >> /home/pi/frame/Manual_Sync.py
echo     print('The file does not contain "true"') >> /home/pi/frame/Manual_Sync.py
echo     "# Perform actions for other conditions if needed" >> /home/pi/frame/Manual_Sync.py

# Creating of Script (Force_Google_Sync.sh)
echo '#!/bin/sh' >> /home/pi/frame/Force_Google_Sync.sh
echo rm /home/pi/frame/commands/* >> /home/pi/frame/Force_Google_Sync.sh
echo rm -rf ~/.local/share/Trash/* >> /home/pi/frame/Force_Google_Sync.sh
echo 'rsync -r /home/pi/MyGDrive/mpf/commands/* /home/pi/frame/commands/' >> /home/pi/frame/Force_Google_Sync.sh
echo py /home/pi/frame/Manual_Sync.py >> /home/pi/frame/Force_Google_Sync.sh

#Setting file Permissions
chmod +rwx /home/pi/frame/feh.sh
chown pi /home/pi/frame/feh.sh
chmod +rwx /home/pi/frame/gdconnect.sh
chown pi /home/pi/frame/gdconnect.sh
chmod +rwx /home/pi/frame/GDrive_sync.sh
chown pi /home/pi/frame/GDrive_sync.sh
chmod +rwx /home/pi/frame/Force_Google_Sync.sh
chown pi /home/pi/frame/Force_Google_Sync.sh
chmod +rwx /home/pi/frame/Manual_Sync.py
chown pi /home/pi/frame/Manual_Sync.py
chmod +rw /home/pi/MyGDrive
chown pi /home/pi/MyGDrive
chmod +rw /home/pi/frame
chown pi /home/pi/frame

# Updating Crontab for some auotmation and automatic updating.
(crontab -u pi -l; echo "* 0 * * 1 shutdown -r now >/dev/null 2>&1" ) | crontab -u pi -
(crontab -u pi -l; echo "@reboot /home/pi/frame/gdconnect.sh") | crontab -u pi -
(crontab -u pi -l; echo "@reboot /home/pi/frame/feh.sh") | crontab -u pi -
(crontab -u pi -l; echo "* 0 * * 5 /home/pi/frame/Gdrive_sync.sh >/dev/null 2>&1") | crontab -u pi -
(crontab -u pi -l; echo "*/30 * * * * /home/pi/frame/Force_Google_Sync.sh" >/dev/null 2>&1) | crontab -u pi -

google-drive-ocamlfuse /home/pi/MyGDrive

# User Note
echo Please run "google-drive-ocamlfuse /home/pi/MyGDrive" from the terminal on your linux desktop.
echo Once the url is given in the terminal screen please run it in your browser.
echo Login to Google and Grant permission.
echo - Run **./GDrive_sync.sh** to start the Pictures copy. 
echo Thank you for using this script.
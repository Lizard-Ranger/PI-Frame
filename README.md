# PI Frame
Pi Frame is a "Digital Photo Frame" Built on a  Raspberry PI 3 with Google Drive accsess.

I built this as a gift for my Mother on her birthday.

The requirements for this build:
   Raspberry pi 3
   32 Gb Micro SD card
   Wave 10.1" Capacitive Touch LCD D 1024X600 
   HDMI Male - Ribbon Connector (Straight) 
   HDMI Ribbon Cable 10cm
   DC Jack Female 2155 Pigtail Cable - 500mm
   DC Jack Male 2155 Pigtail Cable
   HDMI LCD Controller - 40 Pin 
   DC-DC Buck Voltage Regulator, Vin 6-18V Vout 5V 4.5A 
   AC Adapter 12V 5A
   Micro USB Connector + Pigtail 4 Pin Cable
   Super glue
   
   Printed Parts 
	1 x Picture Frame
	2 x Leg
	
Build Steps
		Instert the DC Jack Female
		**_NB NB Please Double check Polarity_**
		Solder the DC Jack Female and DC Jack male ends to the DC Buck Voltage Regulator's **Input (VIN)**
		Solder Micro USB cable to the 5v output (**NB Red is +, Black is - (VOUT)** )
	Connect all cables and ribbon cables.
	
If all is connected correctly the display connected to the Raspberry PI will work.
	
Installation process

** MB ** Keyboard and Mouse will be needed.

	Image SD card with **Raspberry PI Imager**
		Choose **Debian Bulleseye with the Raspberry Pi Desktop**
	Boot Raspberry PI (Wait for it to complete the process)
		It will
			Resize the storage
			Prompt for
				Location
				Username and Password
				Wireless connectivity
				Upgrades
	
	Once complete and booted into the Desktop
	open raspi-config one of two ways
		Terminal - sudo raspi-config
		Desktop  - menu -> Preferances -> Raspberry PI Configuration
		
		Things to change
			System
				Hostname
				Network at Boot = Yes
			Display
				Screan Blanking = Yes
			Interfaces
				SSH = Yes
				VNC = Yes
	Basic config is now complete
	
	Now download the install.sh script to the Raspberry Home Directory (/home/pi)
	Correct Permissions 
		sudo chmod +x install.sh
	
	Things to edit in the install.sh file is the Root Password.
	
	nano install.sh
	
	
	
	Now you can run it.
		./install.sh

#!/bin/sh

# Set the username and new password
username="root"
**new_password="password"** Please replace password to your desired password.

	During the install prossess.
		Update and Upgrade will run
		Packages **ntp**, **feh** **rsync** will installed.
		RustDesk will be downloaded and installed.
		Bluetooth and screensaver will be disabled
		Repos and keys added for **ocamlfuse** (Google Drive Connector)
		MyGDrive will be created and mapped.
		
		Three Scripts will be created
			feh.sh
				Runs the slide show on the screen.
			gdconnect.sh
				Connects the mapped drive.
			GDrive_sync.sh
				Removed Pictures from the Pictures folder
				Empties the trash folder.
				Copies pictures from the MyGDrive folder to Pictures folder
				Then reboots the Raspberry PI
		
		File permissions will be corrected
		Crobtab will be updated to automate the prossess ( Will run every Friday @ Midnight).

The last part once the script is complete from the desktop.
Run **google-drive-ocamlfuse /home/pi/MyGDrive** from the terminal screen.
This will supply a URL for the Google Authentication, copy it and run it from the Desktop Web browser.
This will prompt you to enter you Google username and Password, and ask you to allow **gfuse**
Once you have allowed it close the web browser, in the terminal screen you will see tocken created.

Reboot the Raspberry PI.
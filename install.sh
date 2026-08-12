#!/data/data/com.termux/files/usr/bin/bash

clear

# Center Logo
COLS=$(tput cols)
echo -e "\e[1;31m"
while IFS= read -r line; do
    printf "%*s\n" $(( (${#line} + COLS) / 2 )) "$line"
done << "LOGO"
 ██████╗  ██████╗  ███████╗
██╔════╝  ██╔══██╗ ██╔════╝
██║       ██████╔╝ █████╗  
██║       ██╔══██╗ ██╔══╝  
╚██████╗  ██║  ██║ ██║     
 ╚═════╝  ╚═╝  ╚═╝ ╚═╝     
LOGO
echo -e "\e[0m"
echo ""

echo -e "\e[1;33m=== Starting CRF Auto Setup ===\e[0m"
sleep 2

echo -e "\e[1;32m[1/9] Updating packages...\e[0m"
pkg update -y

echo -e "\e[1;32m[2/9] Installing x11-repo...\e[0m"
pkg install x11-repo -y

echo -e "\e[1;32m[3/9] Installing termux-x11-nightly...\e[0m"
pkg install termux-x11-nightly -y

echo -e "\e[1;32m[4/9] Installing proot-distro and tools...\e[0m"
pkg install proot-distro wget git unzip -y

echo -e "\e[1;32m[5/9] Installing Debian... This will take time\e[0m"
proot-distro install debian

echo -e "\e[1;32m[6/9] Updating Debian and installing Xfce4 + Theme...\e[0m"
proot-distro login debian -- /bin/bash -c "
    set -e
    apt update -y
    apt install xfce4 dbus dbus-x11 xfce4-terminal wget unzip git gtk2-engines-murrine sassc -y
    
    # Install Kali Theme - Direct from GitHub
    cd /tmp
    wget https://github.com/B00merang-Project/kali-xfce4-theme/archive/refs/heads/master.zip -O kali-theme.zip
    unzip kali-theme.zip
    mkdir -p /usr/share/themes /usr/share/icons
    cp -r kali-xfce4-theme-master/Kali-* /usr/share/themes/
    
    # Install Icon Theme
    wget https://github.com/B00merang-Project/Kali-Linux-icons/archive/refs/heads/master.zip -O kali-icons.zip
    unzip kali-icons.zip
    cp -r Kali-Linux-icons-master/Kali-* /usr/share/icons/
    
    # Set theme as default for new users
    mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml
    cat > /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'THEMEOF'
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<channel name=\"xsettings\" version=\"1.0\">
  <property name=\"Net\" type=\"empty\">
    <property name=\"ThemeName\" type=\"string\" value=\"Kali-Dark\"/>
    <property name=\"IconThemeName\" type=\"string\" value=\"Kali-Dark\"/>
  </property>
  <property name=\"Gtk\" type=\"empty\">
    <property name=\"CursorThemeName\" type=\"string\" value=\"Kali-Dark\"/>
  </property>
</channel>
THEMEOF

    # Set wallpaper
    mkdir -p /etc/skel/.config/xfce4/desktop
    wget https://gitlab.com/kalilinux/packages/kali-wallpapers/-/raw/kali/master/backgrounds/kali-metal-dark/kali-metal-dark-16x9.png -O /usr/share/backgrounds/kali-wallpaper.png
    echo 'background=/usr/share/backgrounds/kali-wallpaper.png' > /etc/skel/.config/xfce4/desktop/xfce4-desktop.xml
"

echo -e "\e[1;32m[7/9] Creating kali command...\e[0m"
cat > $PREFIX/bin/kali << 'KALIEOF'
#!/data/data/com.termux/files/usr/bin/bash

clear

# Center Logo
COLS=$(tput cols)

echo -e "\e[1;31m"
while IFS= read -r line; do
    printf "%*s\n" $(( (${#line} + COLS) / 2 )) "$line"
done << "EOF"
 ██████╗  ██████╗  ███████╗
██╔════╝  ██╔══██╗ ██╔════╝
██║       ██████╔╝ █████╗  
██║       ██╔══██╗ ██╔══╝  
╚██████╗  ██║  ██║ ██║     
 ╚═════╝  ╚═╝  ╚═╝ ╚═╝     
EOF
echo -e "\e[0m"

echo ""
tput cup 8 $(( (COLS - 23) / 2 ))
echo -e "\e[1;37mPress ENTER to launch\e[0m"
read

echo -e "\e[1;32m[1/3] Starting X11 Server...\e[0m"
pkill -9 -f "termux-x11|Xwayland|xfce4|dbus" 2>/dev/null
rm -rf $PREFIX/tmp/.X*-lock $PREFIX/tmp/.X11-unix/* 2>/dev/null
termux-x11 :0 -ac >/dev/null 2>&1 &
sleep 2

echo -e "\e[1;32m[2/3] Opening Termux:X11...\e[0m"
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
sleep 1

echo -e "\e[1;32m[3/3] Starting Debian + Xfce4...\e[0m"
proot-distro login debian --shared-tmp -- /bin/bash -c "
    export DISPLAY=:0
    export PULSE_SERVER=127.0.0.1
    unset DBUS_SESSION_BUS_ADDRESS
    dbus-launch --exit-with-session startxfce4
"

clear
echo -e "\e[1;31mXfce4 Closed\e[0m"
KALIEOF

chmod +x $PREFIX/bin/kali

echo -e "\e[1;32m[8/9] Creating widget shortcut...\e[0m"
mkdir -p ~/.shortcuts
cat > ~/.shortcuts/CRF.sh << 'SHORTCUTEOF'
#!/data/data/com.termux/files/usr/bin/bash
kali
SHORTCUTEOF

chmod +x ~/.shortcuts/CRF.sh

echo -e "\e[1;32m[9/9] Setting kali to run on Termux startup...\e[0m"
echo "kali" > ~/.bashrc

clear
echo -e "\e[1;32m=== Installation Complete ===\e[0m"
echo ""
echo -e "\e[1;37mTo start the desktop:\e[0m"
echo "1. Just reopen Termux - it will start automatically"
echo "2. Or type: kali"
echo "3. Or use CRF widget on home screen"
echo ""
echo -e "\e[1;31mIMPORTANT: Install Termux:X11 app from F-Droid first\e[0m"
echo -e "\e[1;31mRestart Termux now to launch\e[0m"
sleep 5
exit

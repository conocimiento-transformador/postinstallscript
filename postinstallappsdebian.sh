#!/bin/bash

# Actualizar repositorios e instalar nala, axel, git
sudo apt update -y
sudo apt install -y nala
sudo nala install -y axel git

# Comprobar si dialog está instalado, si no, instalarlo
if ! command -v dialog &> /dev/null; then
    echo "dialog no está instalado. Instalándolo ahora..."
    sudo nala install -y dialog
fi

# Inicializar variables
log_file="/home/resumen_instalacion.txt"
start_time=$(date +%s)
installed_apps=()

# Crear o limpiar el archivo de log
echo "Resumen de instalación - $(date)" > "$log_file"
echo "-----------------------------------" >> "$log_file"

# Medir velocidad de internet y registrar en el archivo de log
echo "Velocidad de conexión a internet:" >> "$log_file"
speedtest_result=$(speedtest-cli --simple)
echo "$speedtest_result" >> "$log_file"
echo "-----------------------------------" >> "$log_file"

# Mostrar el menú de selección múltiple con las aplicaciones agrupadas por tipo
opciones=$(dialog --stdout --checklist "Selecciona las aplicaciones que deseas instalar:" 0 0 0 \
    0 "Actualizar el sistema" on \
    1 "Instalar Flatpak" on \
    2 "Navegadores: Brave (Flatpak)" on \
    3 "Navegadores: Librewolf (Flatpak)" off \
    4 "Navegadores: Firefox (Flatpak)" off \
    5 "Navegadores: Tor Browser (Instalación manual)" off \
    6 "Navegadores: Chromium (Debian)" off \
    7 "Navegadores: Google Chrome (Flatpak)" off \
    8 "Suites Ofimáticas: Onlyoffice (Flatpak)" on \
    9 "Suites Ofimáticas: LibreOffice (Flatpak)" off \
    10 "Suites Ofimáticas: WPS Office (Flatpak)" off \
    11 "Multimedia: VLC (Flatpak)" on \
    12 "Multimedia: Smplayer (Debian)" on \
    13 "Multimedia: Kdenlive (Flatpak)" off \
    14 "Multimedia: Strawberry (Flatpak)" off \
    15 "Multimedia: Audacity (Flatpak)" off \
    16 "Multimedia: Handbrake (Flatpak)" off \
    17 "Utilidades: qBittorrent (Flatpak)" on \
    18 "Utilidades: Onion mediaX (Flatpak)" on \
    19 "Utilidades: Localsend (Flatpak)" on \
    20 "Utilidades: Reco (Flatpak)" on \
    21 "Utilidades: Vokoscreen (Flatpak)" on \
    22 "Utilidades: IPTVnator (.deb)" on \
    23 "Utilidades: Filezilla (Flatpak)" off \
    24 "Utilidades: kio-gdrive (Debian)" off \
    25 "Utilidades: kaccounts-providers (Debian)" off \
    26 "Utilidades: fwupd (Debian)" on \
    27 "Utilidades: JDownloader (Flatpak)" on \
    28 "Utilidades: ifuse (Debian)" on \
    29 "Utilidades: Codecs Multimedia (Debian)" on \
    30 "Utilidades: Autocpufreq (GitHub)" on \
    32 "Utilidades: Fastfetch (Debian)" on \
    33 "Utilidades: KDE Partition Manager (Debian)" on \
    34 "Utilidades: Gufw (Debian)" on \
    35 "Utilidades: Kshutdown (Debian)" on \
    36 "Utilidades: Gparted (Debian)" off \
    37 "Utilidades: Hardware Probe (Flatpak)" off \
    38 "Utilidades: Firmware (Flatpak)" on \
    39 "PDF y OCR: Okular (Flatpak)" on \
    40 "PDF y OCR: OCR Feeder (Flatpak)" off \
    41 "PDF y OCR: GImageReader (Flatpak)" off \
    42 "PDF y OCR: Master PDF Editor (Flatpak)" off \
    43 "Bajos Recursos: Vokoscreen (Debian)" off \
    44 "Bajos Recursos: Smplayer (Debian)" off \
    45 "Bajos Recursos: Chromium (Debian)" off \
    46 "Bajos Recursos: Transmission-GTK (Debian)" off \
    47 "Bajos Recursos: Transmission-QT (Debian)" off \
    48 "Bajos Recursos: Deluge (Debian)" off \
    49 "Bajos Recursos: Pragha (Debian)" off \
    50 "Bajos Recursos: Evince (Debian)" off \
    51 "Bajos Recursos: Gthumb (Debian)" off \
    52 "Apagar el equipo" off)

# Comprobar si se ha cancelado la selección
if [ $? -ne 0 ]; then
    echo "Instalación cancelada."
    exit 1
fi

# Ejecutar la actualización del sistema si se selecciona
IFS=' ' read -r -a seleccionadas <<< "$opciones"

if [[ " ${seleccionadas[@]} " =~ "0" ]]; then
    sudo nala update && sudo apt full-upgrade -y
    installed_apps+=("Sistema Actualizado")
fi

# Ejecutar la instalación de Flatpak si se selecciona
if [[ " ${seleccionadas[@]} " =~ "1" ]]; then
    sudo apt install -y flatpak
    sudo -n flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    installed_apps+=("Flatpak")
fi

# Ejecutar la instalación de las aplicaciones seleccionadas
for opcion in "${seleccionadas[@]}"; do
    case $opcion in
        2)
            flatpak install -y flathub com.brave.Browser
            installed_apps+=("Brave")
            ;;
        3)
            flatpak install -y flathub io.gitlab.librewolf-community
            installed_apps+=("Librewolf")
            ;;
        4)
            flatpak install -y flathub org.mozilla.firefox
            installed_apps+=("Firefox")
            ;;
        5)
            axel -a https://www.torproject.org/dist/torbrowser/13.5.2/tor-browser-linux-x86_64-13.5.2.tar.xz
            tar -xf tor-browser-linux-x86_64-13.5.2.tar.xz
            rm tor-browser-linux-x86_64-13.5.2.tar.xz
            installed_apps+=("Tor Browser")
            ;;
        6)
            flatpak install -y flathub org.chromium.Chromium
            installed_apps+=("Chromium")
            ;;
        7)
            flatpak install -y flathub com.google.Chrome
            installed_apps+=("Google Chrome")
            ;;
        8)
            flatpak install -y flathub org.onlyoffice.desktopeditors
            installed_apps+=("Onlyoffice")
            ;;
        9)
            flatpak install -y flathub org.libreoffice.LibreOffice
            installed_apps+=("LibreOffice")
            ;;
        10)
            flatpak install -y flathub com.wps.Office
            installed_apps+=("WPS Office")
            ;;
        11)
            flatpak install -y flathub org.videolan.VLC
            installed_apps+=("VLC")
            ;;
        12)
            sudo nala install -y smplayer smplayer-l10n
            installed_apps+=("Smplayer")
            # Habilitar la aceleración por hardware en Smplayer (mpv)
if [ ! -f ~/.config/mpv/mpv.conf ]; then
    mkdir -p ~/.config/mpv
    touch ~/.config/mpv/mpv.conf
fi
echo "hwdec=auto" >> ~/.config/mpv/mpv.conf
            ;;
        13)
            flatpak install -y flathub org.kde.kdenlive
            installed_apps+=("Kdenlive")
            ;;
        14)
            flatpak install -y flathub org.strawberrymusicplayer.strawberry
            installed_apps+=("Strawberry")
            ;;
        15)
            flatpak install -y flathub org.audacityteam.Audacity
            installed_apps+=("Audacity")
            ;;
        16)
            flatpak install -y flathub fr.handbrake.ghb
            installed_apps+=("Handbrake")
            ;;
        17)
            flatpak install -y flathub org.qbittorrent.qBittorrent
            installed_apps+=("qBittorrent")
            ;;
        18)
            flatpak install -y flathub io.github.onionware_github.onionmedia
            installed_apps+=("Onion mediaX")
            ;;
        19)
            flatpak install -y flathub org.localsend.localsend_app
            installed_apps+=("Localsend")
            ;;
        20)
            flatpak install -y flathub com.github.ryonakano.reco
            installed_apps+=("Reco")
            ;;
        21)
            flatpak install -y flathub com.github.vkohaupt.vokoscreenNG
            installed_apps+=("Vokoscreen")
            ;;
        22)
            axel -a https://github.com/4gray/iptvnator/releases/download/v0.15.1/iptvnator_0.15.1_amd64.deb
            sudo dpkg -i iptvnator_0.15.1_amd64.deb
            rm -rf iptvnator_0.15.1_amd64.deb
            installed_apps+=("IPTVnator")
            ;;
        23)
            flatpak install -y flathub org.filezillaproject.Filezilla
            installed_apps+=("Filezilla")
            ;;
        24)
            sudo nala install -y kio-gdrive
            installed_apps+=("kio-gdrive")
            ;;
        25)
            sudo nala install -y kaccounts-providers
            installed_apps+=("kaccounts-providers")
            ;;
        26)
            sudo nala install -y fwupd
            sudo fwupdmgr refresh
            sudo fwupdmgr get-updates
            installed_apps+=("fwupd")
            ;;
        27)
            flatpak install -y flathub org.jdownloader.JDownloader
            installed_apps+=("JDownloader")
            ;;
        28)
            sudo nala install -y ifuse
            installed_apps+=("ifuse")
            ;;
        29)
            sudo nala install -y \
            ubuntu-restricted-extras \
            libavcodec-extra \
            ffmpeg
            installed_apps+=("Codecs Multimedia")
            ;;
        30)
            git clone https://github.com/AdnanHodzic/auto-cpufreq.git /home/auto-cpufreq
            cd /home/auto-cpufreq
            sudo bash auto-cpufreq-installer -y << EOF
I
EOF
            installed_apps+=("Autocpufreq")
            ;;
        32)
            axel -a https://github.com/fastfetch-cli/fastfetch/releases/download/2.22.0/fastfetch-linux-amd64.deb
            sudo dpkg -i fastfetch-linux-amd64.deb
            rm -rf fastfetch-linux-amd64.deb
            sudo nala autoremove
            installed_apps+=("Fastfetch")
            ;;
        33)
            sudo nala install -y partitionmanager
            installed_apps+=("KDE Partition Manager")
            ;;
        34)
            sudo nala install -y gufw
            sudo ufw enable
            installed_apps+=("Gufw")
            ;;
        35)
            sudo nala install -y kshutdown
            installed_apps+=("Kshutdown")
            ;;
        36)
            sudo nala install -y gparted
            installed_apps+=("Gparted")
            ;;
        37)
            flatpak install -y flathub org.linux_hardware.hw-probe
            installed_apps+=("Hardware Probe")
            ;;
        38)
            flatpak install -y flathub org.gnome.Firmware
            installed_apps+=("Firmware")
            ;;
        39)
            flatpak install -y flathub org.kde.okular
            installed_apps+=("Okular")
            ;;
        40)
            flatpak install -y flathub org.gnome.OCRFeeder
            installed_apps+=("OCR Feeder")
            ;;
        41)
            flatpak install -y flathub io.github.manisandro.gImageReader
            installed_apps+=("GImageReader")
            ;;
        42)
            flatpak install -y flatpak install flathub net.codeindustry.MasterPDFEditor
            installed_apps+=("Master PDF Editor")
            ;;
        43)
            sudo nala install -y vokoscreen
            installed_apps+=("Vokoscreen (Bajos Recursos)")
            ;;
        44)
            sudo nala install -y smplayer smplayer-l10n
            installed_apps+=("Smplayer (Bajos Recursos)")
            ;;
        45)
            sudo nala install -y chromium chromium-l10n
            installed_apps+=("Chromium (Bajos Recursos)")
            ;;
        46)
            sudo nala install -y deluge
            installed_apps+=("Deluge")
            ;;
        47)
            sudo nala install -y transmission-gtk
            installed_apps+=("Transmission GTK")
            ;;
        48)
            sudo nala install -y transmission-qt
            installed_apps+=("Transmission QT")
            ;;
        49)
            sudo nala install -y pragha
            installed_apps+=("Pragha")
            ;;
        50)
            sudo nala install -y evince
            installed_apps+=("Evince")
            ;;
        51)
            sudo nala install -y gthumb
            installed_apps+=("Gthumb")
            ;;
        52)
            # Apagar el equipo
            sudo shutdown -h now
            ;;
    esac
done

# Define the log file path
log_file="/home/installation_log.txt"

# Record start time
start_time=$(date +%s)

# Install applications
# (Assuming the rest of the script is correct and doesn't need modification)

# Record end time
end_time=$(date +%s)
execution_time=$((end_time - start_time))

# Write execution time to log file
echo "Tiempo total de ejecución: $((execution_time / 60)) minutos y $((execution_time % 60)) segundos." >> "$log_file"
internet_speed=$(curl -s -w %{speed_download} -o /dev/null http://example.com)
echo "Velocidad de conexión a internet: $internet_speed MB/seg" >> "$log_file"

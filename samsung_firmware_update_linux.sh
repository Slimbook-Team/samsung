#!/bin/bash
# SLIMBOOK TEAM 2023
# Script for update Samsung firmware
# instructions:
# open a terminal and run:
# wget https://raw.githubusercontent.com/Slimbook-Team/samsung/master/samsung_firmware_update_linux.sh
# Exec:
# bash samsung_firmware_update_linux.sh
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# follow the instructions and reboot your computer.
# Original idea: https://blog.quindorian.org/2021/05/firmware-update-samsung-ssd-in-linux.html/


# Aviso de versión beta y recomendación de hacer una copia de seguridad
echo "This is a beta and unofficial Samsung script, we recommend to make a backup before continuing."


# Solicitar confirmación al usuario
while true; do
  read -p "Have you understood the warning and made a backup copy? Please answer 'Y' for yes or 'N' for no. " respuesta
  case $respuesta in
    [Yy]* )
      break;;
    [Nn]* )
      echo "Please, make a backup before running this script."
      exit;;
    * )
      echo "Please answer 'Y' for yes or 'N' for no.";;
  esac
done

# Distro de Linux
distro=""
if command -v apt &> /dev/null; then
  distro="apt"
elif command -v pacman &> /dev/null; then
  distro="pacman"
elif command -v dnf &> /dev/null; then
  distro="dnf"
else
  echo "The supported Linux distribution (apt, pacman or dnf) could not be determined."
  exit 1
fi

# instalar paquetes
programas=("git" "gzip" "unzip" "wget" "cpio")
paquetes_faltantes=()

for programa in "${programas[@]}"; do
  if ! command -v "$programa" &> /dev/null; then
    paquetes_faltantes+=("$programa")
  fi
done

if [ ${#paquetes_faltantes[@]} -gt 0 ]; then
  echo "The following packages are required but they are not installed: ${paquetes_faltantes[*]}"

  if [ "$distro" = "apt" ]; then
    echo "Installing missing packages with apt..."
    sudo apt-get update
    sudo apt-get install -y "${paquetes_faltantes[@]}"
    echo "Packages installed correctly."
  elif [ "$distro" = "pacman" ]; then
    echo "Installing missing packages with pacman..."
    sudo pacman -Sy --noconfirm "${paquetes_faltantes[@]}"
    echo "Packages installed correctly."
  elif [ "$distro" = "dnf" ]; then
    echo "Installing missing packages with dnf..."
    sudo dnf install -y "${paquetes_faltantes[@]}"
    echo "Packages installed correctly."
  fi
fi

directorio="/tmp/samsung"
mkdir -p "$directorio"
echo "The 'samsung' subdirectory has been created in /tmp"

repositorio="https://github.com/Slimbook-Team/samsung"
git clone "$repositorio" "$directorio"


# Obtener la lista de discos duros excluyendo los loop y los que comienzan con "sd"
discos=$(lsblk -o NAME,MODEL -n -l -d | grep -Ev "loop|^sd")

# Verificar si existen discos duros
if [[ -z "$discos" ]]; then
  echo "No hard disks were found in the system."
  exit 0
fi

# Mostrar el modelo de cada disco duro
echo "Samsung SSD model in the system"
echo

while IFS= read -r linea; do
  nombre=$(echo "$linea" | awk '{print $1}')
  modelo=$(echo "$linea" | awk '{$1=""; print $0}')

  echo "SSD: $nombre"
  echo "Model: $modelo"
  echo
done <<< "$discos"

# Solicitar confirmación al usuario
echo "(IMPORTANT) Above this sentence, there is a list of hard drives detected in your computer. Memorize the exact model, it should be Samsung and after the model could be PRO/EVO/EVO_Plus or nothing at all. Flash only the exact model."
echo "Be aware, it is very important to remember this because below you will have to select ONLY THE CORRECT FILE, or you could ruin your hard disk forever."

while true; do
  read -p "Have you memorized the model of your hard disk correctly? Please answer 'Y' for yes or 'N' for no." respuesta
  case $respuesta in
    [Yy]* )
      break;;
    [Nn]* )
      echo "Please memorize the model of your hard disk before proceeding."
      exit;;
    * )
      echo "Please answer 'Y' for yes or 'N' for no.";;
  esac
done

# Leer directorio del firmware y guardar en un array
archivos=()
while IFS= read -r -d '' archivo; do
  archivos+=("$archivo")
done < <(find "$directorio/firmware" -maxdepth 1 -type f -print0)

echo "Choose a file :"
for i in "${!archivos[@]}"; do
  echo "$((i+1)). ${archivos[$i]}"
done

echo "Above you have a list of firmware files in lines starting with a number, type the number that is called like your hard disk with low dashes. "
echo "For example, if you have a Samsung SSD 840 EVO, dial number 1. "
read -p "If your hard disk does not appear in the list, Samsung has not released the firmware, so it may not have the problem. Enter your disk number or press Control+C: " opcion

# aplicar cambios
if [[ $opcion =~ ^[0-9]+$ && $opcion -gt 0 && $opcion -le ${#archivos[@]} ]]; then
  archivo_elegido="${archivos[$opcion-1]}"
  echo "You have chosen the file: $archivo_elegido"

  # Montar archivo elegido y ejecutar comandos adicionales
  sudo mkdir /mnt/iso
  sudo mount -o loop "$archivo_elegido" /mnt/iso/
  mkdir /tmp/fwupdate
  cd /tmp/fwupdate
  gzip -dc /mnt/iso/initrd | cpio -idv --no-absolute-filenames
  cd root/fumagician/
  sudo ./fumagician
fi
echo "The process has finished, the program will have indicated if it has finished successfully, if so, restart the computer to apply the changes."

#!/bin/bash
# SLIMBOOK TEAM 2023
# Script for update Samsung firmware
# instructions:
# open a terminal and run:
# wget https://raw.githubusercontent.com/Slimbook-Team/samsung/master/samsung_firmware_update_linux.sh
# Exec:
# bash samsung_firmware_update_linux.sh
# follow the instructions and reboot your computer.
# Original idea: https://blog.quindorian.org/2021/05/firmware-update-samsung-ssd-in-linux.html/


# Aviso de versión beta y recomendación de hacer una copia de seguridad
echo "¡Aviso! Este script es una versión beta con un método que SAMSUNG no garantiza. Se recomienda hacer una copia de seguridad antes de continuar."

# Solicitar confirmación al usuario
while true; do
  read -p "¿Has entendido el aviso y has hecho una copia de seguridad? (s/n): " respuesta
  case $respuesta in
    [Ss]* )
      break;;
    [Nn]* )
      echo "Por favor, haz una copia de seguridad antes de ejecutar este script."
      exit;;
    * )
      echo "Por favor, responde 's' para sí o 'n' para no.";;
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
  echo "No se pudo determinar la distribución de Linux compatible (apt, pacman o dnf)."
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
  echo "Los siguientes paquetes son necesarios pero no están instalados: ${paquetes_faltantes[*]}"

  if [ "$distro" = "apt" ]; then
    echo "Instalando paquetes faltantes con apt..."
    sudo apt-get update
    sudo apt-get install -y "${paquetes_faltantes[@]}"
    echo "Paquetes instalados correctamente."
  elif [ "$distro" = "pacman" ]; then
    echo "Instalando paquetes faltantes con pacman..."
    sudo pacman -Sy --noconfirm "${paquetes_faltantes[@]}"
    echo "Paquetes instalados correctamente."
  elif [ "$distro" = "dnf" ]; then
    echo "Instalando paquetes faltantes con dnf..."
    sudo dnf install -y "${paquetes_faltantes[@]}"
    echo "Paquetes instalados correctamente."
  fi
fi

directorio="/tmp/samsung"
mkdir -p "$directorio"
echo "Se ha creado el subdirectorio 'samsung' en /tmp"

repositorio="https://github.com/Slimbook-Team/samsung"
git clone "$repositorio" "$directorio"


# Obtener la lista de discos duros excluyendo los loop y los que comienzan con "sd"
discos=$(lsblk -o NAME,MODEL -n -l -d | grep -Ev "loop|^sd")

# Verificar si existen discos duros
if [[ -z "$discos" ]]; then
  echo "No se encontraron discos duros en el sistema."
  exit 0
fi

# Mostrar el modelo de cada disco duro
echo "Modelo de los discos duros en el sistema:"
echo

while IFS= read -r linea; do
  nombre=$(echo "$linea" | awk '{print $1}')
  modelo=$(echo "$linea" | awk '{$1=""; print $0}')

  echo "Disco: $nombre"
  echo "Modelo: $modelo"
  echo
done <<< "$discos"

# Solicitar confirmación al usuario
echo "Encima de esta frase, hay una lista de discos duros detectados en tu ordenador. Memoriza el modelo, si es un Samsung será algo como 'Samsung SSD 980 PRO 1TB' u otro similar. Es muy importante que lo recuerdes porque más abajo deberás seleccionar ÚNICAMENTE EL FICHERO CORRECTO, o podrías estropear tu disco duro para siempre."

while true; do
  read -p "¿Has memorizado el modelo de tu disco duro correctamente? (s/n): " respuesta
  case $respuesta in
    [Ss]* )
      break;;
    [Nn]* )
      echo "Por favor, memoriza el modelo de tu disco duro antes de continuar."
      exit;;
    * )
      echo "Por favor, responde 's' para sí o 'n' para no.";;
  esac
done

# Leer directorio del firmware y guardar en un array
archivos=()
while IFS= read -r -d '' archivo; do
  archivos+=("$archivo")
done < <(find "$directorio/firmware" -maxdepth 1 -type f -print0)

echo "Archivos en el directorio:"
for i in "${!archivos[@]}"; do
  echo "$((i+1)). ${archivos[$i]}"
done
read -p "Elige un número de archivo: " opcion

# aplicar cambios
if [[ $opcion =~ ^[0-9]+$ && $opcion -gt 0 && $opcion -le ${#archivos[@]} ]]; then
  archivo_elegido="${archivos[$opcion-1]}"
  echo "Has elegido el archivo: $archivo_elegido"

  # Montar archivo elegido y ejecutar comandos adicionales
  sudo mkdir /mnt/iso
  sudo mount -o loop "$archivo_elegido" /mnt/iso/
  mkdir /tmp/fwupdate
  cd /tmp/fwupdate
  gzip -dc /mnt/iso/initrd | cpio -idv --no-absolute-filenames
  cd root/fumagician/
  sudo ./fumagician
fi
echo "El proceso ha finalizado, el programa te habrá indicado si ha temrinado con éxito, en tal caso, reinicia."

# SLIMBOOK TEAM 2023
# Script for update SAMSUNG firmware
instructions:

open a terminal and run 2 lines:

`wget https://raw.githubusercontent.com/Slimbook-Team/samsung/master/samsung_firmware_update_linux.sh

bash samsung_firmware_update_linux.sh`

- You will have to answer several questions, and before finishing, one will open in which we are going to follow the indicated steps.

![Screenshot](https://raw.githubusercontent.com/Slimbook-Team/samsung/main/image.png)

- After that we will have to restart the computer and we should have updated the FW.

( You can chek firmware version with this comand: sudo smartctl --xall /dev/nvme0n1 | grep -i firmware )

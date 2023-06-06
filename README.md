# SLIMBOOK TEAM 2023
# Script for update SAMSUNG NVMe firmware 970 980 990 EVO PLUS PRO...

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

open a terminal and run 2 lines:

```
wget https://raw.githubusercontent.com/Slimbook-Team/samsung/master/samsung_firmware_update_linux.sh

bash samsung_firmware_update_linux.sh
```

- You will have to answer several questions, and before finishing, one will open in which we are going to follow the indicated steps.

![Screenshot1](https://raw.githubusercontent.com/Slimbook-Team/samsung/main/image1.png)

- After that we will have to restart the computer and we should have updated the FW.

![Screenshot2](https://raw.githubusercontent.com/Slimbook-Team/samsung/main/image2.png)


PS: You can chek firmware version with this comand: 

sudo smartctl --xall /dev/nvme0n1 | grep -i firmware

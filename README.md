# Caldera-Tips
Tips and QOL tricks for [mitre/caldera](https://github.com/mitre/caldera). 

You can either follow along this guide section by section, or clone the repo to use the [scripts](#scripts) on your system.

## Caldera fresh install

_Please note: These steps have been tested only on Ubuntu 22.04 LTS_

### Dependencies
1. Update & install required system packages `sudo apt update && sudo apt upgrade -y && sudo apt install build-essential python3-dev python3-venv git snapd -y`

2. Ensure Go is installed with `go version`. If not installed, install it with `sudo snap install go --classic`

3. Ensure UPX is installed with `snap --version`. If not installed, install it with `sudo snap install upx`

3. Ensure NodeJS 16+ is installed with `node -v`. If not installed, install the LTS version with `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && source ~/.bashrc && nvm install --lts`

### Install
1. Clone Caldera repo
   ```
   sudo mkdir caldera && sudo chown -R $(whoami):$(whoami) caldera
   git clone https://github.com/mitre/caldera.git --recursive
   ```

2. Create and activate virtual environment
   ```
   cd caldera && python3 -m venv .venv && source .venv/bin/activate
   ```

3. Install required python modules
   ```
   pip install setuptools wheel && pip install pyminizip donut-shellcode && pip install -r requirements.txt
   ```

4. Run caldera server for the first time
   ```
   cd /opt/caldera/ && python3 server.py --build
   ```
   Keep note the passwords & api keys. If only testing or it's temporary, you can add the _--insecure_ flag `python3 server.py --build --insecure` and use the default red/admin credentials.

   Navigate to http://localhost:8888 to launch caldera and login with the creds you noted earlier.

   To run caldera again after the first build, the _--build_ flag is not required, and make sure you have activated the virtual environment with `source .venv/bin/activate` before starting the server.

## Post install tips

### Enable emu plugin
_Make sure caldera is **not** running before continuing_
1. This sed command enables the emu plugin in the local.yml config file. If using the _--insecure_ flag, make sure you run the same command on the default.yml file too
   ```
   cd /opt/caldera/
   sed -i '/- training/a\- emu' conf/local.yml
   ```
   ```
   cd /opt/caldera/
   sed -i '/- training/a\- emu' conf/default.yml
   ```

2. Start caldera to download the emu plugin repo. If using venv, make sure you activate the environment first with `source .venv/bin/activate`
   ```
   cd /opt/caldera/ && python3 server.py --build
   ```
   Once caldera fully starts (after the CALDERA banner), stop the server process with _CTRL+C_.

3. Run the download_payloads.sh file to download the required payloads and decrypt malware
   ```
   cd plugins/emu && ./download_payloads.sh && python3 data/adversary-emulation-plans/sandworm/Resources/utilities/crypt_executables.py -i ./ -p malware --decrypt
   ```

4. Restart and re-build caldera to activate emu abilities & adversaries
   ```
   cd /opt/caldera/ && python3 server.py --build
   ```
### Update caldera
_Make sure caldera is **not** running before continuing_
1. **(optional by highly recommended)** Backup current installation to a `tar.gz` compressed file
   ```
   tar -czvf ~/caldera-$(date +%m-%d-%Y).tar.gz /opt/caldera
   ```
2. Update to the latest code on github
   ```
   cd /opt/caldera/
   git pull
   ```
3. Start caldera with the `--build` flag to rebuild the cache. If using venv, make sure you activate the environment first with `source .venv/bin/activate`.
   ```
   cd /opt/caldera/ && python3 server.py --build
   ```
### Background process - tmux

1. Ensure tmux is installed with `tmux -V`. If not, install it with `sudo apt update && sudo apt install tmux`
2. Start a tmux session named `caldera`
   ```
   tmux new-session -d -s caldera 'cd /opt/caldera/ && source .venv/bin/activate && python3 server.py'
   ```
3. To verify if the session is running, run `tmux ls`. To attach to the session run `tmux attach-session -t caldera`. To disconnect from a tmux session and place it in the background, press `CTRL+B` then `D`. To kill the caldera a tmux session, run `tmux kill-session -t caldera`

### Run caldera at system boot - systemd
_You must already have installed tmux as per section [tmux](#background-process---tmux)_

0. If you haven't done so already, create a log file
   ```
   sudo touch /var/log/caldera.log && sudo chown $(whoami):$(whoami) /var/log/caldera.log
   ```
1. Create a `caldera.service` file in `/etc/systemd/system/`
   ```
   sudo echo "[Unit]
   Description=Caldera C2 Framework
   After=network.target

   [Service]
   Type=forking
   User=${SUDO_USER:-$(whoami)}
   WorkingDirectory=/opt/caldera
   ExecStart=/usr/bin/tmux new-session -d -s caldera 'cd /opt/caldera && source .venv/bin/activate && python3 server.py'
   Restart=always
   RestartSec=3
   StandardOutput=append:/var/log/caldera.log
   StandardError=append:/var/log/caldera.log
 
   [Install]
   WantedBy=multi-user.target" | sudo tee /etc/systemd/system/caldera.service > /dev/null && sudo chmod 644 /etc/systemd/system/caldera.service
   ```
2. Set the permissions for `caldera.service`
   ```
   sudo chmod 644 /etc/systemd/system/caldera.service
   ```
3. Reload systemd
   ```
   sudo systemctl daemon-reload
   ```
4. Enable the service to start on boot
   ```
   sudo systemctl enable caldera.service
   ```
5. Start the service
   ```
   sudo systemctl start caldera.service
   ```
   Troubleshooting:
* You can check the status of the service with `sudo systemctl status caldera.service` or list the current tmux sessions with `tmux ls` to see if the caldera session is running. 
* To disable the service, run `sudo systemctl disable caldera.service`. 
* To stop the service, run `sudo systemctl stop caldera.service`. 
* If you change `caldera.service`, make sure to reload systemd with `sudo systemctl daemon-reload` prior to restarting the service with `sudo systemctl restart caldera.service`
* To view the log file, run `cat /var/log/caldera.log`
## Scripts

_Clone this repo with `git clone https://github.com/endiz/Caldera-Tips.git` to download the scripts to your server before proceeding._

### [backup_caldera.sh](scripts/backup_caldera.sh)

Use this script to stop caldera service, backup, and restart the service

_You must have already created a service per section [Run caldera at system boot - systemd](#run-caldera-at-system-boot---systemd)_

1. Make the backup script executable
   ```
   chmod +x scripts/backup_caldera.sh
   ```
2. Run backup script
   ```
   sudo ./scripts/backup_caldera.sh
   ```
3. **(optional but highly recommended)** Run backup script nightly at 4am EDT with a cron job
   ```
   sudo cp scripts/backup_caldera.sh /usr/local/sbin/backup_caldera.sh
   sudo chmod +x /usr/local/sbin/backup_caldera.sh
   echo "# Caldera C2 Framework
   0  4    * * *   root    /usr/local/sbin/backup_caldera.sh" | sudo tee -a /etc/crontab > /dev/null
   ```

### [install_caldera.sh](scripts/install_caldera.sh)

Use this script to install all dependencies, create a virtual environment, install caldera with default plugins, create and start the caldera service, and create a caldera backup cron job and log. This script has only been tested with a fresh install of Ubuntu 22.04 OS. Other OS's based on debian may work.

1. Make the backup script executable
   ```
   chmod +x scripts/install_caldera.sh
   ```
2. Run install script
   ```
   sudo ./scripts/install_caldera.sh
   ```
   Check `/var/log/caldera_install.log` for details of installation.

## Notebooks

### [examples_api_caldera.ipynb](notebooks/examples_api_caldera.ipynb)
Jupyter Notebook to interact with caldera using the API

## Errors & bug fixing

### Ability not found

### Payload not found

### Docker not found

# Caldera-Tips
Tips and QOL tricks for [mitre/caldera](https://github.com/mitre/caldera)

## Caldera Fresh Install

_Please note: These steps have been tested only on Ubuntu 22.04 LTS_

### Dependencies
1. Update & install required system packages `sudo apt update && sudo apt upgrade -y && sudo apt install build-essential python3-dev python3-venv git snapd -y`

2. Install Go & UPX `sudo snap install go --classic && sudo snap install upx`

3. Ensure NodeJS 16+ is installed with `node -v`. If not installed, install the LTS version with `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && source ~/.bashrc && nvm install --lts`

### Install
1. Clone Caldera repo
   ```
   git clone https://github.com/mitre/caldera.git --recursive
   ```

2. **(optional by highly recommended)** Create and activate virtual environment
   ```
   cd caldera && python3 -m venv .venv && source .venv/bin/activate
   ```

3. Install required python modules
   ```
   pip install setuptools wheel && pip install pyminizip donut-shellcode && pip install -r requirements.txt
   ```

4. Run caldera server for the first time
   ```
   python3 server.py --build
   ```
   Keep note the passwords & api keys. If only testing or it's temporary, you can add the _--insecure_ flag `python3 server.py --build --insecure` and use the default red/admin credentials.

   Navigate to http://localhost:8888 to launch caldera and login with the creds you noted earlier.

   To run caldera again after the first build, the _--build_ flag is not required.

## Post install tips

### Enable the emu plugin
1. This sed command enables the emu plugin in the local.yml config file. If using the _--insecure_ flag, make sure you run the same command on the default.yml file too
   ```
   sed -i '/- training/a\- emu' conf/local.yml
   ```
   ```
   sed -i '/- training/a\- emu' conf/default.yml
   ```

2. Start caldera to download the emu plugin repo
   ```
   python3 server.py --build
   ```
   Once caldera fully starts (after the CALDERA banner), stop the server process with _CTRL+C_.

3. Run the download_payloads.sh file to download the required payloads and decrypt malware
   ```
   cd plugins/emu && ./download_payloads.sh && python3 data/adversary-emulation-plans/sandworm/Resources/utilities/crypt_executables.py -i ./ -p malware --decrypt
   ```

4. Restart and re-build caldera to activate emu abilities & adversaries
   ```
   python3 server.py --build
   ```

# Caldera-Tips
Tips and QOL tricks for [mitre/caldera](https://github.com/mitre/caldera)

## Caldera Fresh Install

These steps have been tested on Ubuntu 22.04 LTS.

1. Ensure python 3.9+ is installed with `python3 --version`. If not installed, install with `sudo apt update && sudo apt install python3`
2. Ensure NodeJS 16+ is installed with `node -v`. If not installed, install with `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && nvm install --lts`
3. Clone Caldera repo
```
git clone https://github.com/mitre/caldera.git --recursive
```
4. (optional by highly recommended) Create and activate virtual environment
```
cd caldera && python3 -m venv .venv && source .venv/bin/activate
```
5. Install required python modules
```
pip install setuptools wheel && pip install pyminizip donut-shellcode && pip install -r requirements.txt
```
6. Run caldera server for the first time
```
python3 server.py --build
```
If only testing or it's temporary, you can add the _--insecure_ flag `python3 server.py --build --insecure`.

To run caldera again after the first build, the _--build_ flag is not required.

## Post install tips

### Enable the emu plugin
1. This sed command enables the emu plugin in the local.yml config file. If using the --insecure flag, make sure you run the same command on the default.yml file too
```
sed -i '/- training/a\- emu' caldera/conf/local.yml
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
4. Restart and re-build caldera with `python3 server.py --build` to activate emu abilities & adversaries

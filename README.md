# BashScript
Some useful script for linux
(All of them need wget)

install.sh
=======

- Description: Auto install many thing for Ubuntu 16
```bash
sudo apt update && sudo apt install expect -y
wget -O install.sh https://raw.githubusercontent.com/kaixinguo360/BashScript/master/install.sh && chmod +x install.sh && ./install.sh
```

lnmp.sh
=======

- Description: Auto install LNMP for Ubuntu 16
```bash
wget -O lnmp.sh https://raw.githubusercontent.com/kaixinguo360/BashScript/master/lnmp/lnmp.sh && chmod +x lnmp.sh && sudo ./lnmp.sh
```

wp.sh
=======

- Description: Auto install WordPress for Ubuntu 16
- Dependent: LNMP installed
```bash
wget -O wp.sh https://raw.githubusercontent.com/kaixinguo360/BashScript/master/wp/wp.sh && chmod +x wp.sh && sudo ./wp.sh
```

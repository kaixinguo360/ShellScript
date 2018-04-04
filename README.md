# BashScript
Some useful script for linux
(All of them need wget)

install.sh
=======

- Description: Auto install many things for Ubuntu 16
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

rewrite.sh
=======

- Description: Rewrite unbound domain request
- Dependent: LNMP installed
```bash
wget -O rewrite.sh https://raw.githubusercontent.com/kaixinguo360/BashScript/master/rewrite/rewrite.sh && chmod +x rewrite.sh && sudo ./rewrite.sh
```

ssl.sh
=======

- Description: Auto enable SSL for LNMP
- Dependent: LNMP installed
```bash
wget -O ssl.sh https://raw.githubusercontent.com/kaixinguo360/BashScript/master/ssl/ssl.sh && chmod +x ssl.sh && sudo ./ssl.sh
```

v2ray.sh
=======

- Description: Auto install V2Ray for Ubuntu 16
- Author: Not Me
```bash
wget -O v2ray.sh https://raw.githubusercontent.com/kaixinguo360/BashScript/master/v2ray/v2ray.sh && chmod +x v2ray.sh && sudo ./v2ray.sh
```

bbr.sh
=======

- Description: Auto install BBR for Ubuntu 16
- Author: Not Me
```bash
wget -O bbr.sh https://raw.githubusercontent.com/kaixinguo360/BashScript/master/bbr/bbr.sh && chmod +x bbr.sh && sudo ./bbr.sh
```

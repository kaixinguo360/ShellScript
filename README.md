# BashScript
Some useful script for linux
(All of them need wget)

lnmp.sh
=======

- Description: Auto install LNMP for Ubuntu 16.04
```bash
wget -O lnmp.sh https://raw.githubusercontent.com/kaixinguo360/BashScript/master/lnmp/lnmp.sh && chmod +x lnmp.sh && sudo ./lnmp.sh
```

wp.sh
=======

- Description: Auto install WordPress for Ubuntu 16.04
- Dependent: LNMP installed
```bash
wget -O wp.sh https://raw.githubusercontent.com/kaixinguo360/BashScript/master/wp/wp.sh && chmod +x wp.sh && sudo ./wp.sh
```

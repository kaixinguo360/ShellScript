# ShellScript
Some useful script for linux
(All of them need wget)

install.sh
=======

- Description: Auto install many things for Ubuntu 16
```bash
sudo apt update && sudo apt install expect -y
wget -O install.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/install.sh && chmod +x install.sh && sudo ./install.sh --help
```

lnmp.sh
=======

- Description: Auto install LNMP for Ubuntu 16
```bash
wget -O lnmp.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/lnmp/lnmp.sh && chmod +x lnmp.sh && sudo ./lnmp.sh
```

wp.sh
=======

- Description: Auto install WordPress for Ubuntu 16
- Dependent: LNMP installed
```bash
wget -O wp.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/wp/wp.sh && chmod +x wp.sh && sudo ./wp.sh
```

v2ray.sh
=======

- Description: Auto install V2Ray for Ubuntu 16
- Author: Not Me
```bash
wget -O v2ray.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/v2ray/v2ray.sh && chmod +x v2ray.sh && sudo ./v2ray.sh
```

v2ray_ssl.sh
=======

- Description: Auto enable WS + TLS + Web for V2Ray
```bash
wget -O v2ray_ssl.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/v2ray/v2ray_ssl.sh && chmod +x v2ray_ssl.sh && sudo ./v2ray_ssl.sh
```

bbr.sh
=======

- Description: Auto install BBR for Ubuntu 16
- Author: Not Me
```bash
wget -O bbr.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/bbr/bbr.sh && chmod +x bbr.sh && sudo ./bbr.sh
```

mail.sh
=======

- Description: Auto install Mail System (Postfix + Dovecot + RainLoop) for Ubuntu 16
- DO NOT set IMAP/SMTP server as 127.0.0.1 on RainLoop, or you will waste whole night for auth failed as me...
```bash
wget -O mail.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/mail/mail.sh && chmod +x mail.sh && sudo ./mail.sh
```

owncloud.sh
=======

- Description: Auto install OwnCloud for Ubuntu 16
- Default database's name is oc
```bash
wget -O owncloud.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/cloud/owncloud.sh && chmod +x owncloud.sh && sudo ./owncloud.sh
```

nextcloud.sh
=======

- Description: Auto install NextCloud for Ubuntu 16
- Default database's name is nc
```bash
wget -O nextcloud.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/cloud/nextcloud.sh && chmod +x nextcloud.sh && sudo ./nextcloud.sh
```

proxy.sh
=======

- Description: Auto create reverse proxy use nginx for Ubuntu 16
```bash
wget -O proxy.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/proxy/proxy.sh && chmod +x proxy.sh && sudo ./proxy.sh
```

proxys.sh
=======

- Description: Batch create reverse proxys use nginx for Ubuntu 16
```bash
wget -O proxys.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/proxy/proxys.sh && chmod +x proxys.sh && sudo ./proxys.sh
```

gitea.sh
=======

- Description: Auto Install Gitea on Ubuntu 16
```bash
wget -O gitea.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/git/gitea.sh && chmod +x gitea.sh && sudo ./gitea.sh
```

backup.sh
=======

- Description: Auto Backup Data And Config on Ubuntu 16
```bash
wget -O backup.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/backup/backup.sh && chmod +x backup.sh && sudo ./backup.sh -h
```

restore.sh
=======

- Description: Auto Restore Data And Config on Ubuntu 16
```bash
wget -O restore.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/backup/restore.sh && chmod +x restore.sh && sudo ./restore.sh -h
```

# Other

new_site.sh
=======

- Description: Auto create new virtual server for Ubuntu 16
```bash
wget -O new_site.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/other/new_site.sh && chmod +x new_site.sh && sudo ./new_site.sh
```

rewrite.sh
=======

- Description: Rewrite unbound domain request
- Dependent: LNMP installed
```bash
wget -O rewrite.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/other/rewrite.sh && chmod +x rewrite.sh && sudo ./rewrite.sh
```

ssl.sh
=======

- Description: Auto enable SSL for LNMP
- Dependent: LNMP installed
```bash
wget -O ssl.sh https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/other/ssl.sh && chmod +x ssl.sh && sudo ./ssl.sh
```

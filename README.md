## What you need:

A vServer with at least:
```
- 1 CPU Core
- 2 GB RAM
- KVM virtualized server (Openvz [...] will not work!)
- The latest "clean" Ubuntu 20.04 minimal installed on the server (with all updates!)
- rDNS set to the desired Domain
- root user access
- 9 GB free disk space

- IPv4 Adress
- A Domain and the ability to change the DNS Settings
- DNS Settings described in the dns_settings.txt
- Time... the DNS system may need 24 to 48 hours to recognize the changes you made!

- The will to learn something about Linux ;)
```

## Quick start

Several quick start options are available:

Important!:
Login with:
- `su -`
otherwise the script will throw multiple errors!

Install with [git]:
- `cd /root/; apt update; apt install git -y; git clone https://github.com/axiades/Perfectrootserver; cd Perfectrootserver; bash nxt.sh
`

Install dev mode [git]:

DO NOT USE FOR PRODUCTION!

The Mailserver and other features won't work!
(This will create a fake Let's Encrypt Cert, you won't run into the limition of weekly cert's)
- `cd /root/; apt update; apt install git -y; git clone https://github.com/axiades/Perfectrootserver; cd Perfectrootserver; touch dev.conf; bash nxt.sh

## Copyright and license

Code and documentation copyright 2017-2020 the [Perfectrootserver Authors](https://github.com/axiades/Perfectrootserver/graphs/contributors)
Code released under the [GNU General Public License v3.0](https://github.com/axiades/Perfectrootserver/blob/master/LICENSE).

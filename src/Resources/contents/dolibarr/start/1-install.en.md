---
lang: en
permalink: start/dolibarr-install
title: Install a Module
---

### Install via User Interface

The best way to install a Dolibarr module is the user interface. 

Go to **Setup >> Modules/Applications** and select **Deploy/install external app/module**.

![]({{ "/assets/img/dolibarr-web-install.png" | relative_url }})

Now select your module .zip file and SEND. 

#### What if your module is too large ?

Go to **Setup >> Security** and select **Files (Upload)**. Then increase maximum size for uploaded files. 

![]({{ "/assets/img/dolibarr-security.png" | relative_url }})

### Install via FTP

Unzip you module, it should contain a folder called  **{{ site.title | split: " " | join: "" | downcase }}**.

Just upload this folder to your Dolibarr **htdocs/custom** folder. 

```
|-- htdocs
|   |-- ...
|   |-- custom
|   |   |-- {{ site.title | split: " " | join: "" | downcase }}
|   |-- ...
```

# Enable the module

Now your module should appear on modules list, you can enable and configure...

![]({{ "/assets/img/dolibarr-module.png" | relative_url }})
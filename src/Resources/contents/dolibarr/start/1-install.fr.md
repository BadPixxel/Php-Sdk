---
lang: fr
permalink: start/dolibarr-install
title: Installer un Module
---

### Installation via l'Interface Utilisateur

La meilleure façon d'installer un module Dolibarr est l'interface utilisateur.

Accédez à **Configuration >> Modules / Applications** et sélectionnez **Déployer/Installer un module externe**.

![]({{ "/assets/img/dolibarr-web-install.png" | relative_url }})

Sélectionnez maintenant votre fichier .zip de module et envoyez le.

#### Et si votre module est trop volumineux?

Allez dans **Setup >> Sécurité** et sélectionnez **Fichiers (Envoyer fichier)**. Augmentez ensuite la taille maximale des fichiers pouvant être téléchargés.

![]({{ "/assets/img/dolibarr-security.png" | relative_url }})

### Installation via FTP

Décompressez votre module, il doit contenir un dossier appelé **{{ site.title | split: " " | join: "" | downcase }}**.

Téléchargez simplement ce dossier dans votre dossier **htdocs/custom** Dolibarr.

```
|-- htdocs
|   |-- ...
|   |-- custom
|   |   |-- {{ site.title | split: " " | join: "" | downcase }}
|   |-- ...
```

# Activer le module

Maintenant, votre module devrait apparaître sur la liste des modules, vous pouvez l'activer et le configurer ...

![]({{ "/assets/img/dolibarr-module.png" | relative_url }})
---
created:
  - "2025-10-06 14:47"
---

> [!info] Contact
> Nom Prénom : Monnier Matthieu
> Email : matthieumm444444@gmail.com
> Email Scolaire : matthieu.monnier@ecoles-epsi.net

---

- 2025-10-06 14:47 - Création initiale

---

> [!info] Sommaire
>
> ```table-of-contents
> 
> ```

---
# Accès au projet :
Des VMs clients sont disponibles depuis les proxmox :
- proxmox 002 à 172.16.127.63
- proxmox 000 à 172.16.127.64
Les vms sont installées avec interface graphiques, disponibles depuis l'onglet "Console" dans proxmox, avec identifiant + mot de passe sous le nom Clients dans la base de mots de passe.

---
# Rappel du sujet

## But

Mettre en place une infrastructure pour la société Dino shop, possédant deux sites (Paris et Honfleur), avec 35 salariés. Le but est de créer une infrastructure fonctionnelle de A à Z pour pouvoir rapatrier tout les services en interne.

## Services à mettre en place

- Site web
- BDD
- Firewall
- Proxmox
- Router
- Support
- DCHP
- LDAP
- Nextcloud
- Vlans

---

# Documentation et outils de suivi

- Schémas à l'aide de Draw.io
- Mots de passes générés et stockés via une base de mots de passe kdbx (mot de passe RTYfghvbn#123)
- Suivi de l'avancée du projet à l'aide d'une Timeline sur Notion
- Documentation écrite via obsidian

---

# Prévisions

## Convention de nommage

- Machines aux noms de 000 à 999

## Plan

Les vlans :

| Acronyme | VLAN | Réseau Paris | Gateway Paris  | Réseau Honfleur | Gateway Honfleur | Masque    |
|----------|------|--------------|----------------|-----------------|------------------|-----------|
| LAN      | 10   | 192.168.10.0 | 192.168.10.254 | 192.168.11.0    | 192.168.11.254   | /24       |
| SRV      | 20   | 192.168.20.0 | 192.168.20.254 | 192.168.21.0    | 192.168.21.254   | /24       |
| DMZ      | 30   | 192.168.30.0 | 192.168.30.254 | 192.168.31.0    | 192.168.31.254   | /24       |
| GUEST    | 40   | 192.168.40.0 | 192.168.40.254 | 192.168.41.0    | 192.168.41.254   | /24       |
| WAN      | 50   | Wifi Labo    | Wifi Labo      | Wifi Labo       | Wifi Labo        | Wifi Labo |

## Schéma

!\[\[Infra.drawio.png\]\]

---

# Mise en place du proxmox

Pour le proxmox 000
On choisis l'ip 172.16.127.64/16, et le mot de passe généré par keepassxc
FQDN : proxmox.000.loc
Une fois connecté au proxmox j'en profite pour télécharger une image de conteneur debian 13 pour stocker les vms
Le deuxième proxmox se situe à 172.16.127.63/16, avec le FQDN proxmox.003.loc

---

# Configuration du switch

```
## HP
- Modèle : HP A5500 Series Switch JG240A2 
```

Reinitialisation du système :

```
reset saved-configuration
Y
reboot
N
Y
```

- On choisis l'ip 172.16.127.65 Pour le switch :

```cli
system-view  
interface vlan-interface 1  
ip address 172.16.127.66 255.255.0.0  
quit
```

(66 pour le deuxième switch)
// optionnel
j'ajoute l'accès à la gestion web du switch
(PASSWORD est le mot de base enregistré dans la base de mots de passe)

```
local-user admin  
service-type telnet  
authorization-attribute level 3  
password simple PASSWORD
quit
ip http enable
```

Je peux donc m'y connecter via http://172.16.127.65 et le login admin / mot de passe PASSWORD
De même pour le deuxième switch http://172.16.127.66

Je les configures de base pour avoir un port access en 47, que je branche au wifi labo, ainsi qu'un port trunk pour l'instant contenant seulement le vlan 1 en port 1 pour brancher les Proxmox sur chacun des switch

---

# Mise en place des VLANs

On veut ici mettre en place les vlans, sur les 2 switchs.

- On enregistre les vlans dans la base de VLANs du switch : 10, 20, 30, 40 et 50 avec leurs noms correspondants : LAN, SRV, DMZ, GUEST et WAN

## Proxmox

On doit changer la configuration réseau de proxmox, sinon quoi il continuera d'essayer d'écouter sur le vlan1 qui n'existera plus dans notre trunk le reliant au switch
Pour cela on crée un "Linux VLAN" avec le nom suivant :

- Name enp2s0.50  
  Nous avons une carte virtuelle écoutant le vlan 50 de notre carte réseau de base,  
  Il faut ensuite modifier le vmbr0 : remplacer enp2s0 par enp2s0.50 pour qu'il comprenne bien que notre accès au réseau est cette carte réseau virtuelle  
  En appliquant la configuration, nous perdont pour l'instant l'accès au proxmox, il faut retourner sur la configuration du switch

## Switch

On retourne sur le switch, ici j'utilise l'interface web d'hp pour configurer les ports :
Je change le PVID du port 1 en 10 pour le lan, et j'ajoute les vlans 20, 30, 40 et 50 la partie "tagged" de ce port, j'enlève ensuite le vlan 1 des membres de ce port
Je me retrouve avec un port trunk au pvid 10 contenant les membres 20, 30, 40 et 50, c'est ce que nous voulons.

Il faut ensuite modifier le port d'où nous vient notre WAN, autrement dit ici le wifi labo sur le port 47

> [!warning] Attention
> À cette étape nous perdont à un moment ou un autre l'accès à distance au switch, je m'y connecte donc via la console pour finir en ligne de commandes

Je change la configuration du port 47 en access pour le vlan 50, à ce moment nous perdons donc la main sur le switch, je finis par quelques lignes de codes pour remettre convenablement l'accès :

```
interface Vlan-interface1
undo ip address
quit
undo interface Vlan-interface1

interface Vlan-interface50
ip address 172.16.127.66 255.255.0.0
quit
save
```

Pour le premier switch, le deuxième nécéssitant une addresse différente qui est 172.16.127.65.

On peut vérifier avec la commande `display ip interface brief` si l'addresse s'est correctement mise, et de nouveau y accéder en interface web.

Nous avons donc maintenant des vlans fonctionnels, pour utilser nos proxmox.

---

# Etat du projet le 29/10/2025

- Les switchs et proxmox sont en place, le réseau fonctionne, les vlans sont configurés, on peut donc maintenant utiliser les proxmox pour toutes les parties de virtualisation.
- Photo du projet :  
  !\[\[IMG_20251029_164418.jpg\]\]  
  On voit d'ailleurs ici un cable branché de 003 port 48 à 001 port 47, c'est l'accès internet qui est partagé d'un switch à l'autre en access des 2 côtés, pour éviter de tirer deux cables depuis le wifi labo, et avoir le même effet.

---

# Virtualisation

## Nommage

- Les VMs auront l'id 1XXX, XXX étant leur nom (ex : 004 pour le pfsense dans 000)
- Elles auront ensuite le nom XXX-ROLE (ex : 004-PFSENSE)

## 004-OPNSENSE

Il aura pour ip sur le WAN (Epsi) : 172.16.124.30

## Template pour les VMs

On crée un template de debian13 avec cloud init en suivant cette documentation :
https://legeekheureux.fr/tutoriel-creez-votre-template-debian-13-cloud-init-sur-proxmox-en-quelques-minutes/
Les commandes exécutées sur proxmox sont donc :

- Variables définissant la VM

```bash
VMID="8001"                           
VMNAME="debian13-cloudinit"           
STORAGE="local-lvm"                   
BRIDGE="vmbr0"                        
CPU="x86-64-v2-AES"
```

- Commande pour télécharger l'image

```bash
wget -N https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2
```

- Commande pour créer la VM qui servira de template

```bash
qm create ${VMID} --name debian13-cloudinit --net0 virtio,bridge=${BRIDGE} --scsihw virtio-scsi-pci --machine q35
```

- Commandes pour configurer le stockage

```bash
qm set ${VMID} --scsi0 ${STORAGE}:0,discard=on,ssd=1,format=qcow2,import-from=$(pwd)/debian-13-genericcloud-amd64.qcow2
 
qm disk resize ${VMID} scsi0 8G
 
qm set ${VMID} --boot order=scsi0
```

- Commandes pour configurer le cpu et la ram

```bash
qm set ${VMID} --cpu ${CPU} --cores 1 --memory 1024
 
qm set ${VMID} --bios ovmf --efidisk0 ${STORAGE}:1,format=qcow2,efitype=4m,pre-enrolled-keys=1
 
qm set ${VMID} --ide2 ${STORAGE}:cloudinit
```

- Commande pour convertir la VM en template

```bash
qm template ${VMID}
```

## Création d'un token terraform

L'intérêt d'avoir créé ce template cloud init est ensuite de pouvoir facilement l'utiliser, notamment pour créer des vms de façon rapide via Terraform, c'est pourquoi je crée, sur les 2 proxmox, un token d'api pour terraform.

On se rend dans le menu Datacenter -> API Tokens
!\[\[Pasted image 20260414091505.png\]\]
On ajoute ensuite le nouveau token, que j'appelle terraform
!\[\[Pasted image 20260414091534.png\]\]
Proxmox nous montre une seule fois le mot de passe pour le token, que je range dans la base de donnée Keepass
On ajoute ensuite les permissions au token
!\[\[Pasted image 20260414094937.png\]\]


## 006-GLPI & 007-BDD

Le GLPI est monté avec docker compose dans le réseau SRV accompagné de la base de donnée :
- GLPI joignable à l'addresse 192.168.20.2
- BDD joignable à l'addresse 192.168.20.1

## 005-LDAP

Le LDAP est un OpenLdap installé à l'addresse 192.168.20.3 controlé par PhpLdapAdmin
Le dc est dinoshop et fr.
Un fichier LDIF est disponible sur le client de paris, dans les Downloads du compte.
Il est utilisé pour peuplé en partie le LDAP et pouvoir effectuer des tests.

## 012-Nextcloud

Nextcloud est installé à l'addresse 192.168.30.1, et connecté au ldap.

## 011-Grafana

Grafana est installé via un playbook ansible, disponible lui aussi dans le dossier Downloads, via le playbook monitoring2.yml
Grafana est accessible depuis 192.168.30.2:3000
Et est utilisé via les credentials par défaut admin admin

## Notes sur l'ipsec et les routeurs :
Il semblerait que malgré des configurations identiques, le routeur d'Honfleur ne fonctionne pas de la même manière que celui de Paris, ne permettant par exemple pas à des machines du réseau SRV d'accéder à internet malgré les règles de firewall prêtes pour.
Le sujet s'est donc essentiellement porté à configurer le premier proxmox, site de Paris.
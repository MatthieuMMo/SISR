
# Configuration du switch HP

- Modèle : HP A5500 Series Switch JG240A

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
ip address 172.16.127.65 255.255.0.0  
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

---


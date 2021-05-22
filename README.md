# docker
Environnement Docker pour les développements

## Configurations

### Variables d'environnements

Configurer au préalable le `.env`, ou bien identifier le fichier d'environnement avec l'option de commande, ici pour visualiser la configuration :

``docker-compose --env-file .env.dev config``

### Hosts local

Edition du fichier hosts (Windows `C:\Windows\System32\drivers\etc\hosts`)

```
127.0.0.1 maildev.localhost
```

### Traefik

Ajouter les DNS mappé sur le reverse-proxy Traefik, pour cela il est possible de rajouter des `labels` sur le conteneurs, exemple :


```
    labels:
      # Route le domaine http://local.my-site.com/ sur ce conteneur (web = http)
      - "traefik.http.routers.mysite.rule=Host(`local.my-site.com`)"
      - "traefik.http.routers.mysite.entrypoints=web"
      # Route le domaine https://local.my-site.com/ sur ce conteneur (websecure = https)
      - "traefik.http.routers.mysite-https.rule=Host(`local.my-site.com`)"
      - "traefik.http.routers.mysite-https.entrypoints=websecure"
      - "traefik.http.routers.mysite-https.tls=true"
```

Plus d'info sur la documentation officiel : <https://doc.traefik.io/traefik/v1.7/configuration/backends/docker/>

#### Routing en dehors des conteneurs

Editer le fichier de config `./traefik/traefik.toml`, puis ajouter l'entypoint suivant (selon vos besoins) :

```
[entryPoints.web]
  [entryPoints.http.redirect]
    regex = "^http://local.my-site.com/(.*)"
    replacement = "http://localhost:8000/$1"
```

### Certificats SSL

Emplacement des certificats : `./certs`

Configurer le fichier de configuration Traefik `./traefik/config/cert-dynamic.toml`

Le nom de domaine associé au certificat dépend de son nom de fichier, exemple pour le domaine www.mathieu-fournial.fr :

```
# ./traefik/config/cert-dynamic.toml
[tls.stores]
  [tls.stores.default]
    [tls.stores.default.defaultCertificate]
      certFile = "/cert/www.mathieu-fournial.fr.crt"
      keyFile = "/cert/www.mathieu-fournial.fr.key"

[[tls.certificates]]
  certFile = "/cert/www.mathieu-fournial.fr.crt"
  keyFile = "/cert/www.mathieu-fournial.fr.key"
```

Remplacer `www.` par `_.` pour un certificat wildcard.

_A noter_ : les fichiers doivent être physiquement présent dans le sous-répertoire `./cert/`

### Virtual Hosts Apache

Pour permettre de router correctement l'ensemble des sites exécuté par nos conteneurs il faut permettre à Apache de router les différents hosts.

Créer vos fichiers dans `./vhosts`, nommé `my-site.com.conf` :

```
#####################
# Site My-site
#####################

<VirtualHost *:80 *:443>
    DocumentRoot "/var/www/my-site"
    ServerName local.my-site.com
    ServerAlias local.my-site.com:*
    ErrorLog /var/log/apache2/local.my-site.com.error.log
    CustomLog /var/log/apache2/access.log common

    <Directory "/var/www/www.my-site.com">
        Options Indexes FollowSymLinks
        AllowOverride all
        <IfVersion >= 2.4>
            Require ip 127.0.0.1
            Require ip 172.0.0.0/8
            Require ip 192.168.0.0/16
            Require host localhost
        </IfVersion>
        <IfVersion < 2.4>
            Order Deny,Allow
            Deny from all
            Allow from 127.0.0.1 localhost 172.0.0.0/8 192.168.0.0/16
        </IfVersion>
    </Directory>

    <IfModule mod_php5.c|mod_php7.c>
        php_admin_value error_log /var/log/apache2/php_error.my-site.log
    </IfModule>
</VirtualHost>
```

_A noter_ : 

- que `ServerName` et `ServerAlias` permette de faire le lien entre le DNS et le Vhosts
- le répertoire `/var/www` correspond à la racine indiqué dans la variable d'environnement `DIR_WEB`
- le répertoire `/var/log/apache2/` correspond au répertoire `./logs`
- l'autorisation `172.0.0.0/8` permet la communication entre conteneurs Docker
- l'autorisation `192.168.0.0/16` permet la communication entre postes utilisateurs du réseau

## Moniteurs et logs

Il est possible de consulter la configuration Traefik via la page <http://localhost:8080/>

Tous les logs Traefik, Apache et PHP sont stockés dans le sous-répertoire `./logs`

## Sites accessibles au lancement

Commande de lancement de tous les conteneurs en tache de fond : `docker-compose up -d [name]`

Indiquer le nom du conteneur pour n'en lancer qu'un seul.

- Traefik : <http://localhost:8080/>
- MailDev : <http://localhost:1080/> (ou <http://maildev.localhost/>)

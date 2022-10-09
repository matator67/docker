#!/bin/bash

rsync -av --update --delete --include=".env" --include="node_modules/*" --include="public/*" --include=".env.local" --include="storage/*" --exclude=".git" --exclude '.merge_file*' --exclude-from="/var/www_local/perso/sites-symfony/.gitignore" /var/www_local/perso/sites-symfony/ /var/www/perso/sites-symfony/ >> /root/rsync.log
rsync -av --update --delete --exclude=".git" --exclude '.merge_file*' --exclude-from="/var/www_local/perso/gite-le-jardin-emma/.gitignore" /var/www_local/perso/gite-le-jardin-emma/ /var/www/perso/gite-le-jardin-emma/ >> /root/rsync.log
rsync -av --update --delete --exclude=".git" --exclude '.merge_file*' --exclude-from="/var/www_local/perso/a2p-deco/.gitignore" /var/www_local/perso/a2p-deco/ /var/www/perso/a2p-deco/ >> /root/rsync.log

while true
do
	date -u > /root/rsync.log
	rsync -av --update --delete --include=".env" --include=".env*" --exclude=".git" --exclude="public/*" --exclude="storage/*" --exclude '.merge_file*' --exclude-from="/var/www_local/perso/sites-symfony/.gitignore" /var/www_local/perso/sites-symfony/ /var/www/perso/sites-symfony/ >> /root/rsync.log
	rsync -av --update --delete --exclude=".git" --exclude="storage/*" --exclude '.merge_file*' --exclude-from="/var/www_local/perso/gite-le-jardin-emma/.gitignore" /var/www_local/perso/gite-le-jardin-emma/ /var/www/perso/gite-le-jardin-emma/ >> /root/rsync.log
	rsync -av --update --delete --exclude=".git" --exclude="storage/*" --exclude '.merge_file*' --exclude-from="/var/www_local/perso/a2p-deco/.gitignore" /var/www_local/perso/a2p-deco/ /var/www/perso/a2p-deco/ >> /root/rsync.log

	sleep 1
done

exit 0

#Authentication and host information for PBS server
export PBS_REPOSITORY=<apikey>@pbs@<IP or hostname>:<datastore>
export PBS_PASSWORD=<apisecret>

# Backup Specifications
SPEC=""

#Backup dataset media on pool tank
SPEC="$SPEC tank.pxar:/mnt/tank/media"

#Backup dataset backup on pool tank
SPEC="$SPEC backup.pxar:/mnt/tank/backup"

#Backup a zvol
#I don't use this personally, so I can't test it, but this is the syntax for the backup client
#Don't try to back up a zvol while it is mounted / in use
SPEC="$SPEC zvol.img:/dev/zvol/tank/volume"

#Perform backup
#You may add your own client-side encryption if you wish
#By default, the client hostname is used as the backup id in PBS
#You can optionally specify your own using --backup-id <name>
#If you want each pool to have a unique backup ID, you'll need to call the client
#one time for each backup ID, each with a different spec.
echo SPEC is $SPEC
proxmox-backup-client backup $SPEC --all-file-systems true

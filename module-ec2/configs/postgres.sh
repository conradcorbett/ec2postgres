#!/bin/bash

# This script is for use with the DevOps Challenge of installing PostgreSQL 9.6 on to a provisioned AWS EC2 instance running Ubuntu.

# This script will perform the following steps:
# 1. Set variables such as $packages, $rfolder, $dfolder, $gitloc, $sysuser, $logfile, and $helloscript
# 2. Install packages based off of $packages.
# 3. Create directory: /postgres and other required.
# 4. Create system user 'postgres'.
# 5. Pull PostgreSQL from Git depot and confirm it is correct: git clone git://git.postgresql.org/git/postgresql.git.
# 6. Install PostgreSQL. ensuring the data files are stored in $dataFolder.
# 7. Start the PostgreSQL service using the pg_ctl command.
# 8. Run create_hello.sql script.
# 9. Run '/postgres/bin/psql -c 'select * from hello;' -U user hello_postgres;' against newly created DB and test for succesful response.

# Section 1 - Variable Creation

echo "Creating variables for use throughout the PSQL installation process"
# $packages is an array containing the dependencies for PostgreSQL
packages=('git' 'gcc' 'tar' 'gzip' 'libreadline5' 'make' 'zlib1g' 'zlib1g-dev' 'flex' 'bison' 'perl' 'python3' 'tcl' 'gettext' 'odbc-postgresql' 'libreadline6-dev')
# $rfolder is the install directory for PostgreSQL
rfolder='/postgres'
# $dfolder is the root directory for various types of read-only data files
dfolder='/postgres/data'
# $gitloc is the location of the PosgreSQL git repo
gitloc='git://git.postgresql.org/git/postgresql.git'
# $sysuser is the system user for running PostgreSQL
sysuser='postgres'
# $helloscript is the sql script for creating the PSQL user and creating a database.
#helloscript='/home/leewalker/scripts/hello.sql'
# $logfile is the log file for this installation.
logfile='psqlinstall-log'

# Section 2 - Package Installation

# Ensures the server is up to date before proceeding.
#echo "Updating server..."
sleep 15
sudo apt-get update -y >> $logfile

# This for-loop will pull all packages from the package array and install them using apt-get
echo "Installing PostgreSQL dependencies"
sudo apt-get -y install git gcc tar gzip libreadline5 
sleep 5
sudo apt-get -y install make zlib1g zlib1g-dev flex
sleep 5
sudo apt-get -y install bison perl python3 tcl
sleep 5
sudo apt-get -y install gettext odbc-postgresql libreadline6-dev
sleep 5

# Section 3 - Create required directories

echo "Creating folders $dfolder..."
sudo mkdir -p $dfolder >> $logfile


# Section 4 - Create system user

echo "Creating system user '$sysuser'"
sudo adduser --system $sysuser >> $logfile


# Section 5 - Pull down PSQL using git

echo "Pulling down PostgreSQL from $gitloc"
git clone $gitloc >> $logfile


# Section 6 - Install and configure PSQL

# Configuring PostgreSQL to be installed at /postgres with a data root directory of /postgres/data
echo "Configuring PostgreSQL"
sudo ~/postgresql/configure --prefix=$rfolder --datarootdir=$dfolder >> $logfile

echo "Making PostgreSQL"
make >> $logfile

echo "installing PostgreSQL"
sudo make install >> $logfile

echo "Giving system user '$sysuser' control over the $dfolder folder"
sudo chown postgres $dfolder >> $logfile

# InitDB is used to create the location of the database cluster, for the purpose of this exercise it will be placed in the $dfolder under /db.
echo "Running initdb"
sudo -u postgres $rfolder/bin/initdb -D $dfolder/db >> $logfile


# Section 7 - Start PSQL

# PostgreSQL is being started, using pg_ctl as the system user postgres.
echo "Starting PostgreSQL"
sudo -u postgres $rfolder/bin/pg_ctl -D $dfolder/db -l $dfolder/logfilePSQL start >> $logfile

# Section 8 - Add PostgreSQL to /etc/rc.local and add environment variables to /etc/profile

# The command to start PostgreSQL at launch is added to /etc/rc.local, again using the system user postgres.
#echo "Set PostgreSQL to launch on startup"
#sudo sed -i '$isudo -u postgres /postgres/bin/pg_ctl -D /postgres/data/db -l /postgres/data/logfilePSQL start' /etc/rc.local >> $logfile

# This block adds the environment variables for PostgreSQL to /etc/profile in order to set them for all users.
echo "Writing PostgreSQL environment variables to /etc/profile"
cat << EOL | sudo tee -a /etc/profile

# PostgreSQL Environment Variables

LD_LIBRARY_PATH=/postgres/lib
export LD_LIBRARY_PATH
PATH=/postgres/bin:$PATH
export PATH
EOL


# Section 8 - hello.sql script is ran

echo "Wait for PostgreSQL to finish starting up..."
sleep 5

# The hello.sql script is ran to create the user, database, and populate the database.
#wget -O hello1.sql https://raw.githubusercontent.com/theleewalker/PSQL-BASH-Install/master/hello.sql
#echo "Running script"
#$rfolder/bin/psql -U postgres -f hello1.sql

# Section 9 - hello_postgres is queried

#echo "Querying the newly created table in the newly created database."
#/postgres/bin/psql -c 'select * from hello;' -U psqluser hello_postgres;
#/postgres/bin/psql -c 'select * from hello;' -U postgres hello_postgres;

#Helpful postgres commands
#login as postgres user: psql -U postgres
#list all databases: \l
#quit: \q
#login into hello_postgres DB as psqluser: psql hello_postgres -U psqluser
#list tables: \dt
#query table: select * from hello;
#connect to new DB: \c [DBNAME] connect to new database, e.g., \c template1

#Once postgres server is running, you will need to edit postgresql.conf and pg_hba.conf to allow remote connections
#psql -c 'SHOW hba_file;' -U postgres;
#add line for unsecure, use the line below instead of this one: hostnossl    all          all            0.0.0.0/0  trust    
#add line once you've created psql user and db: host  all  all 0.0.0.0/0 md5
#sudo echo 'host  all  all 0.0.0.0/0 md5' >> /postgres/data/db/pg_hba.conf
sudo sed -i '/Unix domain socket connections only/a host  all  all 0.0.0.0/0 md5' /postgres/data/db/pg_hba.conf
#psql -c 'SHOW config_file;' -U postgres;
#modify line: listen_addresses = '*'  
sudo sed -i "/Connection Settings -/a listen_addresses = \'*\'" /postgres/data/db/postgresql.conf
sudo sed -i "/scram-sha-256 or md5/a password_encryption = md5" /postgres/data/db/postgresql.conf

sudo -u postgres /postgres/bin/pg_ctl -D /postgres/data/db -l /postgres/data/logfilePSQL restart
#connect to DB jane_db, with user jane, at host: psql jane_db -U jane -h 52.43.33.6
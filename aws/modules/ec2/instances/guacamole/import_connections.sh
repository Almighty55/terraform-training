# #!/bin/bash

# # Guac server install/setup
sudo apt-get -y update
sudo apt-get -y install build-essential
sudo apt-get -y upgrade
wget https://git.io/fxZq5 -O guac-install.sh
sudo chmod +x guac-install.sh
sudo ./guac-install.sh --mysqlpwd password --guacpwd password --nomfa --installmysql
sudo mkdir -m 777 /mnt/GuacShare

# working 
#TODO: increment the 1 value in the sql commands for each server++
privateIP=$1
pw=$2;
count=1;
database=guacamole_db;
table=guacamole_connection;

mysql -u guacamole_user -ppassword -e "USE $database;
INSERT INTO guacamole_connection
            (connection_name,protocol)
VALUES      ('SQL_Server','rdp');

INSERT INTO $table
            (connection_id,parameter_name,parameter_value)
VALUES      ('$count','ignore-cert','true');

INSERT INTO $table
            (connection_id,parameter_name,parameter_value)
VALUES      ('$count','port','3389');

INSERT INTO $table
            (connection_id,parameter_name,parameter_value)
VALUES      ('$count','security','nla');

INSERT INTO $table
            (connection_id,parameter_name,parameter_value)
VALUES      ('$count','username','Administrator');

INSERT INTO $table
            (connection_id,parameter_name,parameter_value)
VALUES      ('$count','hostname','$1');

INSERT INTO $table
            (connection_id,parameter_name,parameter_value)
VALUES      ('$count','password','$2');

INSERT INTO $table
            (connection_id,parameter_name,parameter_value)
VALUES      ('$count','create-drive-path','true');

INSERT INTO $table
            (connection_id,parameter_name,parameter_value)
VALUES      ('$count','drive-name','GuacShare');

INSERT INTO $table
            (connection_id,parameter_name,parameter_value)
VALUES      ('$count','drive-path','/mnt/GuacShare');

INSERT INTO $table
            (connection_id,parameter_name,parameter_value)
VALUES      ('$count','enable-drive','true');"

# for c in "${privateIP[@]}"
# do
#     mysql -u guacamole_user -ppassword -e "USE guacamole_db;INSERT INTO guacamole_connection(connection_name,protocol) Values ('SQL_Server','rdp');INSERT INTO guacamole_connection_parameter(connection_id,parameter_name,parameter_value) Values ('1','ignore-cert','true');INSERT INTO guacamole_connection_parameter(connection_id,parameter_name,parameter_value) Values ('1','port','3389');INSERT INTO guacamole_connection_parameter(connection_id,parameter_name,parameter_value) Values ('1','security','nla');INSERT INTO guacamole_connection_parameter(connection_id,parameter_name,parameter_value) Values ('1','username','Administrator');INSERT INTO guacamole_connection_parameter(connection_id,parameter_name,parameter_value) Values ('1','hostname','${privateIP[$i]}');INSERT INTO guacamole_connection_parameter(connection_id,parameter_name,parameter_value) Values ('1','password','${pw[$c]}');"
# done

#! Troubleshooting on gauc server
# mysql -u guacamole_user -ppassword
# USE guacamole_db;
# show tables;
# select * from guacamole_connection_parameter;
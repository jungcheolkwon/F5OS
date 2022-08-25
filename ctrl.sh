#!/bin/bash

#edited by JC
#j.kwon@f5.com
# https://clouddocs.f5.com/api/velos-api/api-workflows.html

#change to your username
name="username"
#change the password for your user
password="password"

echo -e "\033[35mType your rSeries IPaddress or hostname: \033[0m"
read ip
token=$(curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -H "X-Auth-Token: rctoken" -X GET https://$ip:8888/restconf/data/openconfig-system:system/aaa | jq -r .[].'"f5-primary-key:primary-key"'.state.hash)

if [[ ( "$1" ==  "get" ) && ( ( $2 == 'ntp' ) || ( $2 == 'dns' ) || ( $2 == 'clock' ) )  ]]
then
  #ntp/dns/clock
  curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -H "X-Auth-Token: rctoken" -X GET https://$ip:8888/restconf/data/openconfig-system:system/$2 | jq -r .

elif [[ ( "$1" ==  "get" ) && ( $2 == 'vlan' ) ]]
then
  curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -H "X-Auth-Token: rctoken" -X GET https://$ip:8888/restconf/data/openconfig-vlan:vlans | jq -r .

elif [[ ( "$1" ==  "get" ) && ( $2 == 'tenant' ) ]]
then
  curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -H "X-Auth-Token: rctoken" -X GET https://$ip:8888/restconf/data/f5-tenants:tenants | jq -r .[].tenant

elif [[ ( "$1" ==  "create" ) && ( $2 == 'dns' ) ]]
then
  curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -X PATCH -d @dns https://$ip:8888/restconf/data/

elif [[ ( "$1" ==  "create" ) && ( $2 == 'ntp' ) ]]
then
  curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -X PATCH -d @ntp https://$ip:8888/restconf/data/

elif [[ ( "$1" ==  "create" ) && ( $2 == 'vlan' ) ]]
then
  curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -X PATCH -d @vlan https://$ip:8888/restconf/data/

elif [[ ( "$1" ==  "create" ) && ( $2 == 'tenant' ) ]]
then
  curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -X POST -d @tenant https://$ip:8888/restconf/data/f5-tenants:tenants

elif [[ ( "$1" ==  "delete" ) && ( $2 == 'tenant' ) ]]
then
  curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -H "X-Auth-Token: $token" -X DELETE https://$ip:8888/restconf/data/f5-tenants:tenants/tenant=$3

elif [[ ( "$1" ==  "upload" ) && ( $2 == 'system' ) ]]
then
  echo -e "\033[35mType system image name: \033[0m"
  read image
  scp ISO/$image root@$ip:/var/import/staging/

elif [[ ( "$1" ==  "upload" ) && ( $2 == 'tenant' ) ]]
then
  echo -e "\033[35mType tenant image name: \033[0m"
  read image
  scp ISO/$image root@$ip:/var/F5/system/IMAGES

elif [ "$1" ==  "change" ]
then
  host="$2"
  curl -sk -u "$name:$password" -H "Content-Type: application/yang-data+json" -X POST -d @pwd https://$host:8888/restconf/operations/openconfig-system:system/aaa/authentication/users/user=admin/config/change-password
fi

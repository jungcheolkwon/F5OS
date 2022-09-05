#!/bin/bash

#edited by JC
#j.kwon@f5.com
# https://clouddocs.f5.com/api/velos-api/api-workflows.html

#change to your username
name="username"
#change the password for your user
password="your password"


echo -e "\033[35mType your rSeries IPaddress or hostname: \033[0m"
read int
IFS=' ' #setting space as delimiter
read -ra addr <<< "$int" #reading str as an array as tokens separated by IFS
for ip in "${addr[@]}"; #accessing each element of array
do
  #read ip
  token=$(curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -H "X-Auth-Token: rctoken" -X GET https://$ip:8888/restconf/data/openconfig-system:system/aaa | jq -r .[].'"f5-primary-key:primary-key"'.state.hash)

  if [[ ( "$1" ==  "get" ) && ( ( $2 == 'ntp' ) || ( $2 == 'dns' ) || ( $2 == 'clock' ) )  ]]
  then
    #ntp/dns/clock
    curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -H "X-Auth-Token: rctoken" -X GET https://$ip:8888/restconf/data/openconfig-system:system/$2 | jq -r .
    echo -e "\033[35m ^^^^^^^^^^^^^^^^^^^^^^^ \033[0m \045 $ip's $2 information \033[35m ^^^^^^^^^^^^^^^^^^^^^^^^ \033[0m"

  elif [[ ( "$1" ==  "get" ) && ( $2 == 'vlan' ) ]]
  then
    curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -H "X-Auth-Token: rctoken" -X GET https://$ip:8888/restconf/data/openconfig-vlan:vlans | jq -r .
    echo -e "\033[35m ^^^^^^^^^^^^^^^^^^^^^^^ \033[0m \045 $ip's $2 information \033[35m ^^^^^^^^^^^^^^^^^^^^^^^^ \033[0m"

  elif [[ ( "$1" ==  "get" ) && ( $2 == 'tenant' ) ]]
  then
    curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -H "X-Auth-Token: rctoken" -X GET https://$ip:8888/restconf/data/f5-tenants:tenants | jq -r .[].tenant[].name
    echo -e "\033[35m ^^^^^^^^^^^^^^^^^^^^^^^ \033[0m \045 $ip's $2 information \033[35m ^^^^^^^^^^^^^^^^^^^^^^^^ \033[0m"

  elif [[ ( "$1" ==  "create" ) && ( $2 == 'dns' ) ]]
  then
    curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -X PATCH -d @dns https://$ip:8888/restconf/data/
    echo -e "\033[35m ^^^^^^^^^^^^^^^^^^^^^^^ \033[0m \045 DNS is just created to the $ip  \033[35m ^^^^^^^^^^^^^^^^^^^^^^^^ \033[0m"

  elif [[ ( "$1" ==  "create" ) && ( $2 == 'ntp' ) ]]
  then
    curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -X PATCH -d @ntp https://$ip:8888/restconf/data/
    echo -e "\033[35m ^^^^^^^^^^^^^^^^^^^^^^^ \033[0m \045 NTP is just created to the $ip  \033[35m ^^^^^^^^^^^^^^^^^^^^^^^^ \033[0m"

  elif [[ ( "$1" ==  "create" ) && ( $2 == 'vlan' ) ]]
  then
    curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -X PATCH -d @vlan https://$ip:8888/restconf/data/
    echo -e "\033[35m ^^^^^^^^^^^^^^^^^^^^^^^ \033[0m \045 Vlans are just created to the $ip  \033[35m ^^^^^^^^^^^^^^^^^^^^^^^^ \033[0m"

  elif [[ ( "$1" ==  "create" ) && ( $2 == 'tenant' ) ]]
  then
    curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -X POST -d @tenant https://$ip:8888/restconf/data/f5-tenants:tenants
    echo -e "\033[35m ^^^^^^^^^^^^^^^^^^^^^^^ \033[0m \045 Tenant is just created to the $ip \033[35m ^^^^^^^^^^^^^^^^^^^^^^^^ \033[0m"

  elif [[ ( "$1" ==  "delete" ) && ( $2 == 'tenant' ) ]]
  then
    curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -H "X-Auth-Token: $token" -X DELETE https://$ip:8888/restconf/data/f5-tenants:tenants/tenant=$3
    echo -e "\033[35m ^^^^^^^^^^^^^^^^^^^^^^^ \033[0m \045 Tenant $3 is just deleted from the $ip \033[35m ^^^^^^^^^^^^^^^^^^^^^^^^ \033[0m"
  #elif [[ ( "$1" ==  "delete" ) && ( $2 == 'dns' ) ]]
  elif [[ ( "$1" ==  "delete" ) && ( ( $2 == 'ntp' ) || ( $2 == 'dns' ) || ( $2 == 'clock' ) )  ]]
  then
    curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -H "X-Auth-Token: $token" -X DELETE https://$ip:8888/restconf/data/openconfig-system:system/$2
    echo -e "\033[35m ^^^^^^^^^^^^^^^^^^^^^^^ \033[0m \045 $ip's $2 is just deleted \033[35m ^^^^^^^^^^^^^^^^^^^^^^^^ \033[0m"

  elif [[ ( "$1" ==  "delete" ) && ( $2 == 'vlan' ) ]]
  then
    if [ $3 == "all" ]
    then
      curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -H "X-Auth-Token: $token" -X DELETE https://$ip:8888/restconf/data/openconfig-vlan:vlans
      echo -e "\033[35m ^^^^^^^^^^^^^^^^^^^^^^^ \033[0m \045 All vlans are just deleted from $ip \033[35m ^^^^^^^^^^^^^^^^^^^^^^^^ \033[0m"
    else
      curl -sk -u "$name":"$password" -H "Content-Type: application/yang-data+json" -H "X-Auth-Token: $token" -X DELETE https://$ip:8888/restconf/data/openconfig-vlan:vlans/vlan=$3
      echo -e "\033[35m ^^^^^^^^^^^^^^^^^^^^^^^ \033[0m \045 $ip's $2_$3 is just deleted \033[35m ^^^^^^^^^^^^^^^^^^^^^^^^ \033[0m"
    fi

  elif [[ ( "$1" ==  "upload" ) && ( $2 == 'system' ) ]]
  then
    echo -e "\033[35mType system image name: \033[0m"
    read image
    scp ISO/$image root@$ip:/var/import/staging/
    echo -e "\033[35m ^^^^^^^^^^^^^^^^^^^^^^^ \033[0m \045 system image $image is just uploaded to $ip \033[35m ^^^^^^^^^^^^^^^^^^^^^^^^ \033[0m"

  elif [[ ( "$1" ==  "upload" ) && ( $2 == 'tenant' ) ]]
  then
    echo -e "\033[35mType tenant image name: \033[0m"
    read image
    scp ISO/$image root@$ip:/var/F5/system/IMAGES
    echo -e "\033[35m ^^^^^^^^^^^^^^^^^^^^^^^ \033[0m \045 tenant image $image is just uploaded to $ip \033[35m ^^^^^^^^^^^^^^^^^^^^^^^^ \033[0m"

  elif [ "$1" ==  "change" ]
  then
    host="$2"
    curl -sk -u "$name:$password" -H "Content-Type: application/yang-data+json" -X POST -d @pwd https://$host:8888/restconf/operations/openconfig-system:system/aaa/authentication/users/user=admin/config/change-password
  fi
done  

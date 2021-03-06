#!/bin/bash

getIp() {
  local ret
  local nic=$1
  local ipaddr=$(ip addr show $nic);
  echo $ipaddr >&2

  local flg='(global|host lo)'

  ret=$(echo "$ipaddr" | awk '/inet .*'"$flg"'/{match($0,"inet ([0-9.]+)",M); print M[1]}')

  echo "$ret"
  [ -z "$ret" ] && return 1 || return 0
}

getDefaultNic() {
  ip route | awk '/default/{match($0,"dev ([^ ]+)",M); print M[1]; exit}'
}

getDefaultIp() {
  local nic=$(getDefaultNic)
  [ -z "$nic" ] && return 1

  getIp "$nic"
}

chcon -Rt svirt_sandbox_file_t .
echo LOCAL_ADDRESS=$(getDefaultIp) >.env

#install dependency #just for RHEL-7/CentOS-7
which docker-compose &>/dev/null || {
	yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	yum install -y docker-compose
}
docker-compose up "$@"

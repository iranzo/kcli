#!/usr/bin/env bash
export HYPERVISOR_IP=`hostname -I`
export PASSWORD="[[ password ]]"
sed -i "s/username =.*/username = admin@internal/" /root/.ovirtshellrc
sed -i "s/password =.*/password = $PASSWORD/" /root/.ovirtshellrc
sed -i "s/insecure = False/insecure = True/" /root/.ovirtshellrc
echo $PASSWORD | passwd --stdin root
sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
systemctl restart sshd
ovirt-shell -E "add host --address $HYPERVISOR_IP --cluster-name Default --name `hostname -s` --root_password $PASSWORD --override_iptables false"
sleep 240
ovirt-shell -E "add storagedomain --name vms --host-name `hostname -s` --type data --storage-type nfs --storage-address $HYPERVISOR_IP --storage-path /vms"
ovirt-shell -E "add storagedomain --name vms --parent-datacenter-name Default"
ovirt-shell -E "add storagedomain --name isos --host-name `hostname -s` --type iso --storage-type nfs --storage-address $HYPERVISOR_IP --storage-path /isos"
ovirt-shell -E "add storagedomain --name isos --parent-datacenter-name Default"
iptables -F
systemctl disable iptables

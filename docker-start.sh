#!/bin/bash

if [ "$1" = "head-node" ]; then
   /etc/init.d/sshd restart
   echo "Installing SGE on the head node..."
#   sudo -u sgeadmin bash -l -c "\
#	ssh-keygen -t dsa -N '' -f /home/sgeadmin/.ssh/id_dsa && \
#	cat /home/sgeadmin/.ssh/id_dsa.pub >> /home/sgeadmin/.ssh/authorized_keys && \
#	chmod 0600 /home/sgeadmin/.ssh/authorized_keys"
   rm -rf /opt/sge/default 
   cd /opt/sge/ && ./inst_sge -m -auto  `pwd`/inst.conf 
   while true
	do
	sleep 10
	done
fi

if [ "$1" = "compute-node" ]; then
   /etc/init.d/sshd restart
   echo "Installing SGE on the compute node..."
   cat > /etc/ssh/ssh_config << EOF
Host *
    StrictHostKeyChecking  no
EOF

   sleep 5

   sudo -u sgeadmin ssh head "source /opt/sge/default/common/settings.sh && qconf -as `hostname`"
   sudo -u sgeadmin ssh head "source /opt/sge/default/common/settings.sh && qconf -ah `hostname`"
   cd /opt/sge/ && cat ./inst.conf | sed "s/EXEC_HOST_LIST=.*/EXEC_HOST_LIST=`hostname`/" > ./inst_`hostname`.conf
   cd /opt/sge/ && ./inst_sge -x -auto  ./inst_`hostname`.conf
   while true
        do
        sleep 10
        done
fi

if [ "$1" = "rsw" ]; then 
  echo "x" 
   echo "Installing SGE on the compute node..."
   cat > /etc/ssh/ssh_config << EOF
Host *
    StrictHostKeyChecking  no
EOF

   sleep 5

   sudo -u sgeadmin ssh head "source /opt/sge/default/common/settings.sh && qconf -as `hostname`"

   ln -s /opt/rstudio-age /opt/sge/
   /usr/lib/rstudio-server/bin/license-manager activate $RSW_LICENSE
   rstudio-server start
   /usr/lib/rstudio-server/bin/rstudio-launcher & 
   while true
        do
        sleep 10
        done
fi 

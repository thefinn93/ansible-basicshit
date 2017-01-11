#!/bin/bash
# Sometimes the $PATH gets messed up in cron, so lets start by setting the record straight
if [ "$1" == "nodisown" ]; then
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  /usr/local/bin/ansible-pull -U https://github.com/thefinn93/ansible-basicshit -C master > /var/log/ansible.log
  if [[ "$?" != "0" ]]; then
    link=$(cat /var/log/ansible.log | curl -F 'sprunge=<-' http://sprunge.us)
    ansible localhost -m irc -a "channel=#thefinn93 msg=\"[{{ ansible_fqdn }}] Ansible failed! Full log at $link\" server=irc.freenode.net port=6697 use_ssl=yes nick={{ ansible_hostname }}"
  fi
else
  $0 nodisown &!
fi

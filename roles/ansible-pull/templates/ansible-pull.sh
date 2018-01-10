#!/bin/bash
post_to_irc () {
  ansible localhost -m irc -a "channel=#thefinn93 msg=\"[{{ ansible_fqdn }}] $1\" server=irc.freenode.net port=6697 use_ssl=yes nick={{ ansible_machine_id }}"
}

if [ "$1" == "nodisown" ]; then
  # Sometimes the $PATH gets messed up in cron, so lets start by setting the record straight
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  /usr/local/bin/ansible-pull -o -U https://git.callpipe.com/finn/ansible-basicshit.git -s 600 -C master &> /var/log/ansible.log
  rc="$?"
  if [[ "$rc" != "0" ]]; then
    link=$(cat /var/log/ansible.log | curl -F 'sprunge=<-' http://sprunge.us)
    post_to_irc "Ansible failed (rc ${rc})! Full log at $link"
  fi
else
  $0 nodisown & disown
fi

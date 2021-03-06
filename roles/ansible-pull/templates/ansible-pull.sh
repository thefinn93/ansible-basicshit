#!/bin/bash
post_to_irc () {
  ansible localhost -m irc -a "channel=#thefinn93 msg=\"[{{ ansible_fqdn }}] $1\" server=irc.freenode.net port=6697 use_ssl=yes nick={{ ansible_machine_id }}"
}

if [ "$1" == "nodisown" ]; then
  # Sometimes the $PATH gets messed up in cron, so lets start by setting the record straight
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  virtualenv --system-site-packages -p python2 /usr/ansible
  /usr/ansible/bin/pip install ansible==2.6.2.0
  ANSIBLE_PULL="/usr/ansible/bin/ansible-pull"
  if [ ! -x $ANSIBLE_PULL ]; then
    ANSIBLE_PULL=$(which ansible-pull)
  fi
  $ANSIBLE_PULL -o -U {{ ansible_local.pull.repo }} -C {{ ansible_local.pull.branch }} &> /var/log/ansible.log
  rc="$?"
  if [[ "$rc" != "0" ]]; then
    link=$(cat /var/log/ansible.log | nc termbin.com 9999)
    curl -X POST --data-urlencode "payload={\"username\": \"{{ ansible_fqdn }}\", \"text\": \"Ansible Pull exited with status \`${rc}\`. <${link}|Full log>\"}" https://hooks.slack.com/services/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
    post_to_irc "Ansible failed (rc ${rc})! Full log at $link"
  fi
else
  $0 nodisown & disown
fi

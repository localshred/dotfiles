#!/usr/bin/env bash

# Enable the has_audiences_access flag for a company or list of companies.
#
# Can provide the company guid, nuvis id, or a file that contains lines of only
# company guids or nuvis ids.
#
# Usage:
#   $ enable_audiences CMPY-123-456-678
#   $ enable_audiences someNuvisId
#   $ enable_audiences approval_list.txt
#
function enable_audiences() {
  if [[ -f $1 ]]
  then
    local filename=$1
    local count=$(cat $1 | wc -l | awk '{ print $1 }')

    echo "Enabling Audience access for ${count} companies in ${filename}..."
    echo
    for companyId in $(cat $1)
    do
      enable_audiences $companyId
    done

    echo "\t--> Done"
    echo

  else
    local companyId=$1
    echo "Enabling ${companyId}..."

    heroku run SKIP_SIDEKIQ_CRON=1 NEWRELIC_AGENT_ENABLED=false LOG_LEVEL=1 rake "flags:enable[$companyId,has_audiences_access]" --app zuul-prod-nuvi

    echo "\t---> Done"
  fi
}

# Set a company's identity as facebook approved in minaret.
#
# Can provide the company guid or a file that contains lines of only
# company guids.
#
# Usage:
#   $ approve_audiences CMPY-123-456-678
#   $ approve_audiences list_of_guids.txt
#
function approve_audiences() {
  if [[ -f $1 ]]
  then
    local filename=$1
    local count=$(cat $1 | wc -l | awk '{ print $1 }')

    echo "Approved Audience access for ${count} companies in ${filename}..."
    echo
    for companyGuid in $(cat $1)
    do
      approve_audiences $companyGuid
    done

    echo "\t--> Done"
    echo

  else
    local companyGuid=$1
    echo "Enabling ${companyGuid}..."

    heroku run SKIP_SIDEKIQ_CRON=1 NEWRELIC_AGENT_ENABLED=false LOG_LEVEL=1 rake "identities:enable_facebook[$companyGuid]" --app minaret-prod-nuvi

    echo "\t---> Done"
  fi
}

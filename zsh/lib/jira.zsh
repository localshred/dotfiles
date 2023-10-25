#!/usr/bin/env zsh

function jiramine() {
    jira issue list --assignee "BJ Neilsen" --order-by status -q "status not in (Closed)"
}
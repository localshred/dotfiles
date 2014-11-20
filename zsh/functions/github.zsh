#!/usr/bin/env sh

# Create an issue in the specified user's github repository.
createissue ()
{
	user=$1
	repo=$2
	if [[ -z "$user" || -z "$repo" ]]; then
		echo "Usage: issues USER REPO"
		return 1
	fi
	open "https://github.com/${user}/${repo}/issues/new"
}

# Open github for the user:repo.
gh ()
{
	user=$1
	repo=$2
	if [[ -z "$user" || -z "$repo" ]]; then
		echo "Usage: gh USER REPO"
		return 1
	fi
	open "https://github.com/${user}/${repo}"
}

ghlocalhsred ()
{
	gh localshred $1
}

ghnuvi ()
{
	gh nuvi $1
}

issues ()
{
	user=$1
	repo=$2
	issue_number=$3

	if [[ -z "$user" || -z "$repo" ]]; then
		echo "Usage: issues USER REPO [ISSUE NUMBER]"
		return 1
	fi

	if [[ -z "$issue_number" ]]; then
		open "https://github.com/${user}/${repo}/issues"
	else
		open "https://github.com/${user}/${repo}/issue/${issue_number}"
	fi
}

issueslocalshred ()
{
	issues localshred $1 $2
}

issuesnuvi ()
{
	issues nuvi $1 $2
}

# Open pull requests for the specified user's github repository.
pulls ()
{
	user=$1
	repo=$2
	pr_number=$3

	if [[ -z "$user" || -z "$repo" ]]; then
		echo "Usage: pulls USER REPO [PR NUMBER]"
		return 1
	fi

	if [[ -z "$pr_number" ]]; then
		open "https://github.com/${user}/${repo}/pulls"
	else
		open "https://github.com/${user}/${repo}/pull/${pr_number}"
	fi
}

# Open pull requests for a localshred repository.
pullslocalshred ()
{
	pulls localshred $1 $2
}

# Open pull requests for a nuvi repository.
pullsnuvi ()
{
	pulls nuvi $1 $2
}


#!/usr/bin/env bash

# Stollen from https://github.com/maxkratz/github2gitea-mirror
# License: https://github.com/maxkratz/github2gitea-mirror/blob/master/LICENSE

# Script to mirror GitHub repos to a Gitea instance.
#
# Modes:
#   - Mirror a public/private repo
#   - Mirror all public/private repos of a user
#   - Mirror all starred repos by a user
#   - Mirror all public/private repos of an organization
#
# Heavily inspired by:
#   https://github.com/juergenhoetzel/github2gitea-mirror
# 

# ENVs:
#   ACCESS_TOKEN = Gitea token
#   GITERA_URL   = Gitea URL
#   GITHUB_TOKEN = GitHub personal access token

# Displays the given input including "=> " on the console.
log () {
	echo "=> $1"
}

CURL="curl -f -S -s"

# Check for correctly set ENVs
# ACCESS_TOKEN and GITEA_URL are always necessary
if [[ -z "${ACCESS_TOKEN}" || -z "${GITEA_URL}" ]]; then
    echo -e "Please set the Gitea access token and URL in environment:\nexport ACCESS_TOKEN=abc\nexport GITEA_URL=http://gitea:3000\n" >&2
    echo -e "Don't use a trailing slash in URL!"
    exit 1
fi

# Parse input arguments
if [[ -z "$1" ]]; then
	log "No parameter(s) given. Exit."
    exit 1
fi
while [[ "$#" -gt 0 ]]; do
	case $1 in
		-m|--mode) mode="$2"; shift ;;
		-o|--org) gitea_organization="$2"; shift ;;
        -u|--user) github_user="$2"; shift ;;
        -v|--visibility) visibility="$2"; shift ;;
        -r|--repo) repo="$2"; shift ;;
		*) log "Unknown parameter passed: $1"; exit 1 ;;
	esac
	shift
done

# Prints a message on how to use the script with exit 1
fail_print_usage () {
    echo -e "Usage: $0"
    echo -e "   -m, --mode {org,star,repo,user}     Mode to use; either mirror an organization or mirror all starred repositories."
    echo -e "   -o, --org \$organization             GitHub organization to mirror and/or the target organization in Gitea."
    echo -e "   -u, --user \$github_user             GitHub user to gather the starred repositories from."
    echo -e "   -v, --visibility {public,private}   Visibility for the created Gitea organization."
    echo -e "   -r, --repo \$repo_url                GitHub URL of a single repo to create a mirror for."
    echo "" >&2
    exit 1;
}

# Check if mode is set
if [[ -z "${mode}" ]]; then
    fail_print_usage
fi

# Check required parameters per mode
if [ "${mode}" == "org" ]; then
    if [[ -z "${gitea_organization}" ]]; then
        echo -e "Organization not set."
        fail_print_usage
    fi

    if [[ -z "${visibility}" ]]; then
        echo -e "Visibility not set."
        fail_print_usage
    fi
elif [ "${mode}" == "star" ]; then
    if [[ -z "${gitea_organization}" || -z "${github_user}" ]]; then
        echo -e "Organization or GitHub user not set."
        fail_print_usage
    fi
elif [ "${mode}" == "repo" ]; then
    if [[ -z "${repo}" || -z "${github_user}" ]]; then
        echo -e "Repo URL or GitHub user not set."
        fail_print_usage
    fi
elif [ "${mode}" == "user" ]; then
    if [[ -z "${github_user}" ]]; then
        echo -e "GitHub user not set."
        fail_print_usage
    fi  
else
    echo -e "Mode not found."
    fail_print_usage
fi

# TODO:
#set -euo pipefail
set -eu pipefail

header_options=(-H  "Authorization: Bearer ${ACCESS_TOKEN}" -H "accept: application/json" -H "Content-Type: application/json")
jsonoutput=$(mktemp -d -t github-repos-XXXXXXXX)

trap "rm -rf ${jsonoutput}" EXIT

# Sets the uid to the specified Gitea organization
set_uid() {
    uid=$($CURL "${header_options[@]}" $GITEA_URL/api/v1/orgs/${gitea_organization} | jq .id)
}

# Sets the uid to the specified Gitea user
set_uid_user() {
    uid=$($CURL "${header_options[@]}" $GITEA_URL/api/v1/users/${github_user} | jq .id)
}

# Fetches all starred repos of the given user to JSON files
fetch_starred_repos() {
    log "Fetch starred repos."
    i=1
    # GitHub API just returns empty arrays instead of 404
    while $CURL "https://api.github.com/users/${github_user}/starred?page=${i}&per_page=100" >${jsonoutput}/${i}.json \
	    && (( $(jq <${jsonoutput}/${i}.json '. | length') > 0 )) ; do
	    (( i++ ))
    done
}

# Fetches all public/private repos of the given GitHub organization to JSON files
fetch_orga_repos() {
    log "Fetch organization repos."
    i=1
    # GitHub API just returns empty arrays instead of 404
    while $CURL "https://api.github.com/orgs/${gitea_organization}/repos?page=${i}&per_page=100" -u "username:${GITHUB_TOKEN}" >${jsonoutput}/${i}.json \
	    && (( $(jq <${jsonoutput}/${i}.json '. | length') > 0 )) ; do
	    (( i++ ))
    done
}

# Fetches all public/private repos of the given GitHub user to JSON files
fetch_user_repos() {
    log "Fetch user repos."
    i=1
    # GitHub API just returns empty arrays instead of 404
    while $CURL "https://api.github.com/user/repos?affiliation=owner&page=${i}&per_page=100" -u "${github_user}:${GITHUB_TOKEN}" >${jsonoutput}/${i}.json \
	    && (( $(jq <${jsonoutput}/${i}.json '. | length') > 0 )) ; do
	    (( i++ ))
    done
}

# Fetches one public/private GitHub repo to a JSON file
fetch_one_repo() {
    log "Fetch one repo."
    # Remove URL prefix
    repo=$(echo $repo | sed "s/https:\/\/github.com\///g" | sed "s/.git//g")
    $CURL "https://api.github.com/repos/$repo" -u "username:${GITHUB_TOKEN}" >${jsonoutput}/1.json
}

# Creates a specific migration repo on Gitea
create_migration_repo() {
    log "Create migration repo."
    if ! $CURL -w  "%{http_code}\n"  "${header_options[@]}" -d @- -X POST $GITEA_URL/api/v1/repos/migrate > ${jsonoutput}/result.txt 2>${jsonoutput}/stderr.txt; then
        local code=$(<${jsonoutput}/result.txt)
        if (( code != 409 ));then # 409 == repo already exits
            cat ${jsonoutput}/stderr.txt >&2
        fi
    fi
}

# Creates a specific public/private organization on Gitea
create_migration_orga() {
    visibility="${1:-}"
    log "Create migration orga with name: ${gitea_organization}"
    if ! $CURL -X POST $GITEA_URL/api/v1/orgs "${header_options[@]}" --data '{"username": "'"${gitea_organization}"'", "visibility": "'"${visibility}"'"}' > ${jsonoutput}/result.txt 2>${jsonoutput}/stderr.txt; then
        local code=$(<${jsonoutput}/result.txt)
        if (( code != 422 ));then # 422 == orga already exits
            cat ${jsonoutput}/stderr.txt >&2
        fi
    fi
}

# Creates a migration repo on Gitea for each GitHub repo in the JSON files
repos_to_migration() {
    log "Repos to migration started."
    for f in ${jsonoutput}/*.json; do
        n=$(jq '. | length'<$f)
        if [[ "${n}" -gt "0" ]]; then
            (( n-- )) # last element
        else
            continue;
        fi
        for i in $(seq 0 $n); do
            mig_data=$(jq ".[$i] | .uid=${uid} | \
                if(.visibility==\"private\") then .private=true else .private=false end |\
                if(.visibility==\"private\") then .auth_username=\"${github_user}\" else . end | \
                if(.visibility==\"private\") then .auth_password=\"${GITHUB_TOKEN}\" else . end | \
                .mirror=true | \
                .clone_addr=.clone_url | \
                .description=.description[0:255] | \
                .repo_name=.name | \
                {uid,repo_name,clone_addr,description,mirror,private,auth_username,auth_password}" <$f)
            echo "Migrating repo" $(jq ".[$i] | .uid=${uid} | .name" <$f)
            echo $mig_data | create_migration_repo
        done
    done
}

# Creates one migration repo on Gitea for the one GitHub repo in '1.json'
one_repo_to_migration() {
    log "One repo to migration started."
    # There should only be one JSON file
    for f in ${jsonoutput}/*.json; do
        mig_data=$(jq ".repo_owner=\"${github_user}\" | \
            if(.visibility==\"private\") then .private=true else .private=false end |\
            if(.visibility==\"private\") then .auth_username=\"${github_user}\" else . end | \
            if(.visibility==\"private\") then .auth_password=\"${GITHUB_TOKEN}\" else . end | \
            .mirror=true | \
            .clone_addr=.clone_url | \
            .description=.description[0:255] | \
            .repo_name=.name | \
            {repo_owner,repo_name,clone_addr,description,mirror,private,auth_username,auth_password}" <$f)
        echo "Migrating repo" $(jq ".name" <$f)
        echo $mig_data | create_migration_repo
    done
}

# Actual run the script
if [ "${mode}" == "org" ]; then
    log "Mode = organization"
    fetch_orga_repos
    create_migration_orga ${visibility}
    set_uid
    repos_to_migration
elif [ "${mode}" == "repo" ]; then
    log "Mode = single repo"
    fetch_one_repo
    one_repo_to_migration
elif [ "${mode}" == "star" ]; then
    log "Mode = starred repos"
    set_uid
    fetch_starred_repos
    repos_to_migration
elif [ "${mode}" == "user" ]; then
    log "Mode = user"
    set_uid_user
    fetch_user_repos
    repos_to_migration
fi

log "Finished."


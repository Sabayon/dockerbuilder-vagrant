#!/bin/bash
# written by mudler@sabayon.org

DOCKER_GIT_REPOSITORY="${DOCKER_GIT_REPOSITORY:-https://github.com/Sabayon/docker-armhfp}"
DOCKER_GIT_REPOSITORY_NAME="${DOCKER_GIT_REPOSITORY_NAME:-docker-armhfp}"
DOCKER_GIT_REPOSITORY_BRANCH="${DOCKER_GIT_REPOSITORY_BRANCH:-origin/master}"
DOCKER_NAMESPACE="${DOCKER_NAMESPACE:-sabayon}"
DOCKER_NAMESPACE_PREFIX="${DOCKER_NAMESPACE_PREFIX}"
DOCKER_IMAGES_DIRS=(
	"armhfp"
	"builder"
	"distccd"
	"generic"
	"odroid-x2-u-u2"
	"raspberrypi2"
	"udooneo"
)
VAGRANT_BRANCH="${VAGRANT_BRANCH:-$DOCKER_GIT_REPOSITORY_BRANCH}"
EMAIL_NOTIFICATIONS="${EMAIL_NOTIFICATIONS:-mudler@sabayon.org}"
MAILGUN_API_KEY="${MAILGUN_API_KEY}"
MAILGUN_DOMAIN_NAME="${MAILGUN_DOMAIN_NAME}"
MAILGUN_FROM="${MAILGUN_FROM:-Excited User <mailgun\@$MAILGUN_DOMAIN_NAME\>}"

die() { echo "$@" 1>&2 ; exit 1; }
send_email() {
local SUBJECT="${1:-Report}"
local TEXT="${2:-Something went wrong}"

[ -z "$MAILGUN_API_KEY" ] && die "You have to set MAILGUN for error reporting"
[ -z "$MAILGUN_DOMAIN_NAME" ] && die "You have to set MAILGUN for error reporting"
[ -z "$MAILGUN_FROM" ] && die "You have to set MAILGUN for error reporting"

curl -s --user "api:${MAILGUN_API_KEY}" \
    https://api.mailgun.net/v3/"$MAILGUN_DOMAIN_NAME"/messages \
     -F from="$MAILGUN_FROM" \
    -F to="$EMAIL_NOTIFICATIONS" \
    -F subject="$SUBJECT" \
    -F text="$TEXT"

}


echo "Starting the show."

[ -d /vagrant/repositories ] || mkdir -p /vagrant/repositories

cd /vagrant/repositories

[ -d /vagrant/repositories/$DOCKER_GIT_REPOSITORY_NAME ] || git clone $DOCKER_GIT_REPOSITORY

pushd /vagrant

	send_email "Syncing builder scripts to the git repository" "Hey, building process just started, just a friendly advice. If you won't see any message from me about an error, everything went OK"
        git fetch --all
        git reset --hard $VAGRANT_BRANCH

popd

pushd /vagrant/repositories/$DOCKER_GIT_REPOSITORY_NAME

	git fetch --all
	git reset --hard ${DOCKER_GIT_REPOSITORY_BRANCH}

	for i in "${DOCKER_IMAGES_DIRS[@]}"
	do
		pushd /vagrant/repositories/$DOCKER_GIT_REPOSITORY_NAME/$i
			docker build --rm -t "$DOCKER_NAMESPACE_PREFIX"$DOCKER_NAMESPACE/$i . || send_email "Building error" "Failed when building $DOCKER_NAMESPACE/$i"
			docker push "$DOCKER_NAMESPACE_PREFIX"$DOCKER_NAMESPACE/$i || send_email "Pushing error" "Failed while pushing $DOCKER_NAMESPACE/$i"
		popd
	done

popd




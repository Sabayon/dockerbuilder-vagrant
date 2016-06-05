#!/bin/bash
# written by mudler@sabayon.org

DOCKER_GIT_REPOSITORY="${DOCKER_GIT_REPOSITORY:-https://github.com/Sabayon/docker-armhfp}"
DOCKER_GIT_REPOSITORY_NAME="${DOCKER_GIT_REPOSITORY_NAME:-docker-armhfp}"
DOCKER_GIT_REPOSITORY_BRANCH="${DOCKER_GIT_REPOSITORY_BRANCH:-origin/master}"
DOCKER_NAMESPACE="${DOCKER_NAMESPACE:-sabayon}"
DOCKER_NAMESPACE_PREFIX="${DOCKER_NAMESPACE_PREFIX}"
DOCKER_IMAGES_DIRS=(
	"builder"
	"distccd"
	"generic"
	"odroid-x2-u2"
	"odroid-c2"
	"rpi"
	"rpi-mc"
	"udooneo"
)
VAGRANT_BRANCH="${VAGRANT_BRANCH:-$DOCKER_GIT_REPOSITORY_BRANCH}"
EMAIL_NOTIFICATIONS="${EMAIL_NOTIFICATIONS:-mudler@sabayon.org}"
MAILGUN_API_KEY="${MAILGUN_API_KEY}"
MAILGUN_DOMAIN_NAME="${MAILGUN_DOMAIN_NAME}"
MAILGUN_FROM="${MAILGUN_FROM:-Excited User <mailgun\@$MAILGUN_DOMAIN_NAME\>}"
IRC_IDENT="${IRC_IDENT:-bot sabayon builder}"
IRC_NICK="${IRC_NICK:-SabDockerBuild}"
IRC_CHANNEL="${IRC_CHANNEL:-#sabayon-infra}"

die() { echo "$@" 1>&2 ; exit 1; }
irc_msg() {

local IRC_MESSAGE="${1}"

[ -z "$IRC_MESSAGE" ] && return 1
[ -z "$IRC_CHANNEL" ] && return 1

echo -e "USER ${IRC_IDENT}\nNICK ${IRC_NICK}${RANDOM}\nJOIN ${IRC_CHANNEL}\nPRIVMSG ${IRC_CHANNEL} :${IRC_MESSAGE}\nQUIT\n" \
| nc irc.freenode.net 6667 > /dev/null || true

}

echo "Starting the show."

[ -d /vagrant/repositories ] || mkdir -p /vagrant/repositories

cd /vagrant/repositories

[ -d /vagrant/repositories/$DOCKER_GIT_REPOSITORY_NAME ] || git clone $DOCKER_GIT_REPOSITORY

pushd /vagrant

        git fetch --all
        git reset --hard $VAGRANT_BRANCH

popd

pushd /vagrant/repositories/$DOCKER_GIT_REPOSITORY_NAME

	git fetch --all
	git reset --hard ${DOCKER_GIT_REPOSITORY_BRANCH}

	for i in "${DOCKER_IMAGES_DIRS[@]}"
	do
		pushd /vagrant/repositories/$DOCKER_GIT_REPOSITORY_NAME/$i
			docker build --rm -t "$DOCKER_NAMESPACE_PREFIX"$DOCKER_NAMESPACE/$i-armhfp . || irc_msg "Docker images Building error: Failed when building $DOCKER_NAMESPACE/$i"
			docker push "$DOCKER_NAMESPACE_PREFIX"$DOCKER_NAMESPACE/$i-armhfp || irc_msg "Docker images Pushing error: Failed while pushing $DOCKER_NAMESPACE/$i"
		popd
	done

popd

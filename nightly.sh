#!/bin/bash
# written by mudler@sabayon.org

DOCKER_GIT_REPOSITORY="${DOCKER_GIT_REPOSITORY:-https://github.com/Sabayon/docker-armhfp}"
DOCKER_GIT_REPOSITORY_NAME="${DOCKER_GIT_REPOSITORY_NAME:-docker-armhfp}"
DOCKER_GIT_REPOSITORY_BRANCH="${DOCKER_GIT_REPOSITORY_BRANCH:-origin/master}"
DOCKER_NAMESPACE="${DOCKER_NAMESPACE:-sabayon}"
DOCKER_NAMESPACE_PREFIX="${DOCKER_NAMESPACE_PREFIX}"
DOCKER_IMAGE_ARCH="${DOCKER_IMAGE_ARCH:-armhfp}"
MOLECULES_REPO="${MOLECULES_REPO:-https://github.com/Sabayon/molecules-arm.git}"
MOLECULES_REPO_NAME="${MOLECULES_REPO_NAME:-molecules-arm}"
REPOSITORIES_DIR="${REPOSITORIES_DIR:-/vagrant/repositories}"
BUILD_DATE="$(date +%Y%m%d)"
LOGS_DIR="$REPOSITORIES_DIR/$MOLECULES_REPO_NAME/images/logs/$BUILD_DATE"
BASE_URL"${BASE_URL:-https://dockerbuilder.sabayon.org/}"

DOCKER_IMAGES_DIRS=(
	"armhfp"
	"odroid-c2"
	"rpi"
	"rpi-mc"
	"bananapi"
	"builder"
	"distccd"
	"odroid-x2-u2"
	"udooneo"
	"generic"
)
VAGRANT_BRANCH="${VAGRANT_BRANCH:-$DOCKER_GIT_REPOSITORY_BRANCH}"
IRC_IDENT="${IRC_IDENT:-Bot Sabayon Docker Builder}"
IRC_NICK="${IRC_NICK:-Sab}"
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

[ -d "$REPOSITORIES_DIR" ] || mkdir -p $REPOSITORIES_DIR

[ -d "$LOGS_DIR" ] || mkdir -p $LOGS_DIR

[ -d $REPOSITORIES_DIR/$DOCKER_GIT_REPOSITORY_NAME ] || pushd $REPOSITORIES_DIR && git clone $DOCKER_GIT_REPOSITORY && popd

[ -d $REPOSITORIES_DIR/$MOLECULES_REPO_NAME ] || git clone $MOLECULES_REPO $REPOSITORIES_DIR/$MOLECULES_REPO_NAME

pushd /vagrant

        git fetch --all
        git reset --hard $VAGRANT_BRANCH

popd

pushd $REPOSITORIES_DIR/$DOCKER_GIT_REPOSITORY_NAME

	git fetch --all
	git reset --hard ${DOCKER_GIT_REPOSITORY_BRANCH}
	git pull

	for i in "${DOCKER_IMAGES_DIRS[@]}"
	do
		pushd $REPOSITORIES_DIR/$DOCKER_GIT_REPOSITORY_NAME/$i
			irc_msg "Docker image building started for $i (${DOCKER_IMAGE_ARCH})"
			[ "${DOCKER_IMAGE_ARCH}" == "$i" ] \
			&& {	docker build --rm -t "$DOCKER_NAMESPACE_PREFIX"$DOCKER_NAMESPACE/$i . 1>&2 > $LOGS_DIR/${DOCKER_NAMESPACE_PREFIX}${DOCKER_NAMESPACE}-${i}.log || irc_msg "Docker images Building error: Failed when building $DOCKER_NAMESPACE/$i";
				docker push "$DOCKER_NAMESPACE_PREFIX"$DOCKER_NAMESPACE/$i 1>&2 >> $LOGS_DIR/${DOCKER_NAMESPACE_PREFIX}${DOCKER_NAMESPACE}-${i}.log
			} \
			|| {	docker build --rm -t "$DOCKER_NAMESPACE_PREFIX"$DOCKER_NAMESPACE/$i-${DOCKER_IMAGE_ARCH} . 1>&2 > $LOGS_DIR/${DOCKER_NAMESPACE_PREFIX}${DOCKER_NAMESPACE}-${i}.log || irc_msg "Docker images Building error: Failed when building $DOCKER_NAMESPACE/$i";
				docker push "$DOCKER_NAMESPACE_PREFIX"$DOCKER_NAMESPACE/$i-${DOCKER_IMAGE_ARCH} 1>&2 >> $LOGS_DIR/${DOCKER_NAMESPACE_PREFIX}${DOCKER_NAMESPACE}-${i}.log
			}
			irc_msg "Docker image building finished for $i (${DOCKER_IMAGE_ARCH}) - ${BASE_URL}/logs/${BUILD_DATE}/${DOCKER_NAMESPACE_PREFIX}${DOCKER_NAMESPACE}-${i}.log"

		popd
	done

popd

pushd $REPOSITORIES_DIR/$MOLECULES_REPO_NAME
	irc_msg "Building images"
	git fetch --all
	git reset --hard origin/master
	git pull
	./build.sh 1>&2 > $LOGS_DIR/$MOLECULES_REPO_NAME.log
	irc_msg "Images building complete. ${BASE_URL}/logs/${BUILD_DATE}/$MOLECULES_REPO_NAME.log"
popd

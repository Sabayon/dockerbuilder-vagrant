#!/bin/bash
# written by mudler@sabayon.org

DOCKER_GIT_REPOSITORY="${DOCKER_GIT_REPOSITORY:-https://github.com/Sabayon/docker-armhfp}"
DOCKER_GIT_REPOSITORY_NAME="${DOCKER_GIT_REPOSITORY_NAME:-docker-armhfp}"
DOCKER_GIT_REPOSITORY_BRANCH="${DOCKER_GIT_REPOSITORY_BRANCH:-origin/master}"
DOCKER_NAMESPACE="${DOCKER_NAMESPACE:-sabayon}"
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

echo "Starting the show."

[ -d /vagrant/repositories ] || mkdir -p /vagrant/repositories

[ -d /vagrant/repositories/$DOCKER_GIT_REPOSITORY_NAME ] || git clone $DOCKER_GIT_REPOSITORY

pushd /vagrant/repositories/$DOCKER_GIT_REPOSITORY_NAME

	git fetch --all
	git reset --hard ${DOCKER_GIT_REPOSITORY_BRANCH}

	for i in "${DOCKER_IMAGES_DIRS[@]}"
	do
		pushd /vagrant/repositories/$DOCKER_GIT_REPOSITORY_NAME/$i
			docker build --rm --no-cache . $DOCKER_NAMESPACE/$i || mutt -s "Failed when building $DOCKER_NAMESPACE/$i" $MAIL_NOTIFICATIONS
			docker push $DOCKER_NAMESPACE/$i || mutt -s "Failed while pushing $DOCKER_NAMESPACE/$i" $EMAIL_NOTIFICATIONS
		popd
	done

popd

pushd /vagrant

        git fetch --all                                                                                                                                                                                                                                                         
        git reset --hard $VAGRANT_BRANCH

popd

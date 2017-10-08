#!/bin/sh

## Copyright ##################################################################
#
# Copyright © 2015, 2016, 2017 Chris Lamb <lamby@debian.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Functions ##################################################################

set -eu

Info () {
	echo "I: ${*}" >&2
}

Error () {
	echo "E: ${*}" >&2
}

## Configuration ##############################################################

if [ -f debian/changelog ]
then
	SOURCE="$(dpkg-parsechangelog | awk '/^Source:/ { print $2 }')"
	VERSION="$(dpkg-parsechangelog | awk '/^Version:/ { print $2 }')"
else
	# Fallback to parsing debian/control if debian/changelog does not exist
	SOURCE="$(awk '/^Source:/ { print $2 }' debian/control)"
	VERSION="0"
fi

if [ "${SOURCE}" = "" ] || [ "${VERSION}" = "" ]
then
	Error "Could not determine source and version from packaging"
	exit 2
fi

REPO='https://github.com/elementary/houston/blob/master'
LIFTOFF_URL="${REPO}/src/flightcheck/pipes/Liftoff/docker/liftoff_0.1_amd64.deb?raw=true"
DOCKERFILE_URL="${REPO}/src/flightcheck/pipes/Liftoff/docker/Dockerfile?raw=true"
TAG="${SOURCE}/v${VERSION}"
PROJECT_PARENT="$(dirname $(pwd))"
PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename $(pwd))"

Info "Starting build of ${TAG}"

## Build ######################################################################
Info "At Directory ${PROJECT_PARENT} with Project ${PROJECT_NAME}"

Info "Retrieving current liftoff"
wget "$LIFTOFF_URL" -O liftoff_0.1_amd64.deb

Info "Retrieving current dockerfile"
wget "$DOCKERFILE_URL" -O Dockerfile

Info "Using Dockerfile:"
sed -e 's@^@  @g' Dockerfile

Info "Building Docker image ${TAG}"
docker build --tag="${TAG}" .

Info "Removing Dockerfile"
rm -f Dockerfile

Info "Removing Liftoff"
rm -rf liftoff_0.1_amd64.deb

Info "Running build with TAG:$TAG at ${PROJECT_DIR}/pushy:/tmp/flightcheck"
docker run --privileged -v  "${PROJECT_DIR}":/tmp/flightcheck:rw "${TAG}" -a amd64 -d xenial -o /tmp/flightcheck


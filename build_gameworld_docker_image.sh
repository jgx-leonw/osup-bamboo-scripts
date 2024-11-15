#!/bin/bash

function latest_commit_at_path {
    path=$1
    pushd $path &>/dev/null
    echo $(git log -1 --pretty=format:%H -- .)
    popd &>/dev/null
}

DOCKER_REPO=318836920195.dkr.ecr.eu-west-1.amazonaws.com/bothscape
GIT_HASH=$(latest_commit_at_path .)  # get latest commit in gameworld subdir
echo " git hash for the gameoworld folder : $GIT_HASH"
REPO_WIDE_GIT_HASH=$(latest_commit_at_path ..)  # get latest commit across repo
GIT_BRANCH=${bamboo.planRepository.branch}
OUTPUT_DIR="${bamboo.build.working.directory}/output"
BUILD_DIR="${bamboo.build.working.directory}/gameworld/gitignored"

# Make sure key value is defined
if [[ -z "${GIT_HASH}" ]]; then
  echo "GIT_HASH is expected to be defined" &>2
  exit 1
elif [[ -z "${GIT_BRANCH}" ]]; then
  echo "GIT_BRANCH is expected to be defined" &>2
  exit 1
fi

# Create the gitignored folder if not exist
mkdir -p "$BUILD_DIR"

# Copy all the folders and files from output to gitignored
cp -r "$OUTPUT_DIR"/* "$BUILD_DIR"

cd "$BUILD_DIR"
ls -la
cd ..
set -e


echo "Writing build_info.txt..."
echo git_hash=${GIT_HASH} > build_info.txt
echo git_branch=${GIT_BRANCH} >> build_info.txt
echo build_job=${bamboo.buildResultKey} >> build_info.txt
echo build_time=`date -u -Is` >> build_info.txt

echo "Building image: ${GIT_HASH}"
docker build . -t ${DOCKER_REPO}:${GIT_HASH}
docker push ${DOCKER_REPO}:${GIT_HASH}

# Use Repo's git hash if current git hash is different from the repo's git hash
if [[ ${GIT_HASH} != "${REPO_WIDE_GIT_HASH}" ]]; then
  docker tag ${DOCKER_REPO}:${GIT_HASH} ${DOCKER_REPO}:${REPO_WIDE_GIT_HASH}
  docker push ${DOCKER_REPO}:${REPO_WIDE_GIT_HASH}
fi

# If built from main create main tag
if [[ ${GIT_BRANCH} == "main" ]]; then
  docker tag ${DOCKER_REPO}:${GIT_HASH} ${DOCKER_REPO}:main
  docker push ${DOCKER_REPO}:main
fi
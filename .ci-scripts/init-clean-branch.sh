#!/bin/sh
# envs
REPO_BRANCH="${REPO_BRANCH:?REPO_BRANCH not defined}"
LOCAL_GIT_TARGET_DIR="${LOCAL_GIT_TARGET_DIR:-.}"

unset GIT_DIR


# change to git dir
cd "$LOCAL_GIT_TARGET_DIR" || exit 1

# switch to gh-pages
git switch "${REPO_BRANCH}" || git switch --orphan="${REPO_BRANCH}" || exit 1

# clean all contents
git rm -rf .
git clean -fxd

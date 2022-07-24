#!/bin/sh
# envs
REPO_PROTOCOL="${REPO_PROTOCOL:?REPO_PROTOCOL not defined}"
REPO_HOST="${REPO_HOST:?REPO_HOST not defined}"
REPO="${REPO:?REPO not defined}"
REPO_BRANCH="${REPO_BRANCH:?REPO_BRANCH not defined}"
REPO_ID="${REPO_ID:?REPO_ID not defined}"
REPO_PW="${REPO_PW:+:$REPO_PW}"
REPO_KEY="${REPO_KEY:-}"
LOCAL_GIT_TARGET_DIR="${LOCAL_GIT_TARGET_DIR:-.}"
LOCAL_GIT_NEW_COMMIT_MSG="${LOCAL_GIT_NEW_COMMIT_MSG:?LOCAL_GIT_NEW_COMMIT_MSG not defined}"

unset GIT_DIR


# change to git dir
cd "$LOCAL_GIT_TARGET_DIR" || exit 1

# add unstaged changes and commit
git add .
git commit --allow-empty -m "${LOCAL_GIT_NEW_COMMIT_MSG}" || exit 1

# prepare key
unset TMP_SSH_KEYFILE
if [ -n "$REPO_KEY" ]
then
  TMP_SSH_KEYFILE="$(mktemp)"
  printf "%s" "$REPO_KEY" | \
    tee "${TMP_SSH_KEYFILE:?Error on setting TMP_SSH_KEYFILE}" > /dev/null
fi

# push
[ -n "${TMP_SSH_KEYFILE}" ] && \
  export GIT_SSH_COMMAND="ssh '${TMP_SSH_KEYFILE:+-i}' '$TMP_SSH_KEYFILE' -o IdentitiesOnly=yes -o StrictHostKeyChecking=no"
git push -u -f "${REPO_PROTOCOL}://${REPO_ID}${REPO_PW}@${REPO_HOST}/${REPO}" HEAD:"${REPO_BRANCH}" || \
  { rm -f "$TMP_SSH_KEYFILE"; exit 1; }
rm -f "$TMP_SSH_KEYFILE"

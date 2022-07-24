#!/bin/sh
# envs
REPO_PROTOCOL="${REPO_PROTOCOL:?REPO_PROTOCOL not defined}"
REPO_HOST="${REPO_HOST:?REPO_HOST not defined}"
REPO="${REPO:?REPO not defined}"
REPO_ID="${REPO_ID:?REPO_ID not defined}"
REPO_PW="${REPO_PW:+:$REPO_PW}"
REPO_KEY="${REPO_KEY:-}"
LOCAL_GIT_TARGET_DIR="${LOCAL_GIT_TARGET_DIR:-.}"

unset GIT_DIR


# change to git dir
cd "$LOCAL_GIT_TARGET_DIR" || exit 1

# prepare key
unset TMP_SSH_KEYFILE
if [ -n "$REPO_KEY" ]
then
  TMP_SSH_KEYFILE="$(mktemp)"
  printf "%s" "$REPO_KEY" | \
    tee "${TMP_SSH_KEYFILE:?Error on setting TMP_SSH_KEYFILE}" > /dev/null
fi

# clone
[ -n "${TMP_SSH_KEYFILE}" ] && \
  export GIT_SSH_COMMAND="ssh '${TMP_SSH_KEYFILE:+-i}' '$TMP_SSH_KEYFILE' -o IdentitiesOnly=yes -o StrictHostKeyChecking=no"
git clone "${REPO_PROTOCOL}://${REPO_ID}${REPO_PW}@${REPO_HOST}/${REPO}" . || \
  { rm -f "$TMP_SSH_KEYFILE"; exit 1; }
git fetch --all
rm -f "$TMP_SSH_KEYFILE"

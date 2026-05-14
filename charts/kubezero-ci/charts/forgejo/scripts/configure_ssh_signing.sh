#!/usr/bin/env bash
set -eu

install -m 600 /raw/ssh-signing-key /data/git/.ssh-signing/key
ssh-keygen -y -f /data/git/.ssh-signing/key > /data/git/.ssh-signing/key.pub
chmod 644 /data/git/.ssh-signing/key.pub

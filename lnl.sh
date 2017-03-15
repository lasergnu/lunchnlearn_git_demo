#!/bin/bash
set -x
set -e
cd /tmp
    rm -rf /tmp/lnl
    mkdir /tmp/lnl
cd /tmp/lnl
    [ $(ls | wc -l) -eq 0 ] || exit 1
    git init
    touch file
    git add file
    git commit -am "first commit"
    for c in {a..f}; do echo $c >> file; git commit -am $c; done
cd /tmp
    rm -rf lunchnlearn.git
    git clone --bare lnl lunchnlearn.git
    rm -rf /tmp/lnl
    git clone lunchnlearn.git lnl
cd /tmp/lnl
    git checkout -b dev
    echo my changes >> file 
    git commit -am "wip"
    git checkout master
    for c in {g..r}; do echo $c >> file; git commit -am $c; done
    git push
    git checkout -b homophone
    sed -i '/c/s/.*/c, sea and see are homophones/g' file
    git commit -am "homophone"
    git checkout master
    for c in {s..z}; do echo $c >> file; git commit -am $c; done
    git push
    git reset --hard master~8



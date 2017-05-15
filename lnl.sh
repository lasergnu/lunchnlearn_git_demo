#!/bin/bash
set -x
set -e

dir=/nett/uniq/git/lnl.git
u=$dir/hooks/update

ssh qxgit@build "cd $dir; \
    git config --replace-all receive.denynonfastforwards false; \
    git config --replace-all receive.denydeletecurrent false; \
    mv $u ${u}.moved" || true

cd /tmp
    rm -rf /tmp/lnl
    git clone qxgit@build:/nett/uniq/git/lnl.git
cd /tmp/lnl
    for b in $(git branch --all | awk -F / '!/HEAD/ && /remotes/ {print $NF}'); do echo git push origin :${b}; git push origin :${b}; done
cd /tmp
    rm -rf /tmp/lnl
    git clone qxgit@build:/nett/uniq/git/lnl.git
cd /tmp/lnl
    for t in $(git tag -l); do git push origin :refs/tags/${t}; git tag -d $t; done
    [ $(ls | wc -l) -eq 0 ] || exit 1
    touch file
    git add file
    git commit -am "first commit"
    for c in {a..f}; do echo $c >> file; git commit -am $c; done
    git checkout -b experiment
    echo my changes >> file 
    git commit -am "wip"
    git checkout master
    for c in {g..r}; do echo $c >> file; git commit -am $c; done
    git push -u origin master
    git checkout -b h
    sed -i '/c/s/.*/c, see and see are homophones/g' file
    git commit -am "homophone"
    sed -i '/c/s/.*/c, sea and see are homophones/g' file
    git commit -am "fix typo"
    git checkout master
    for c in {s..z}; do echo $c >> file; git commit -am $c; done
    git push
    git reset --hard master~8

ssh qxgit@build "cd $dir; \
    git config --replace-all receive.denynonfastforwards true; \
    git config --replace-all receive.denydeletecurrent true; \
    mv ${u}.moved $u" || true




    


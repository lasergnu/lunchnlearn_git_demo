#!/bin/bash
set -x
set -e

dir=/nett/uniq/git/lnl.git
u=$dir/hooks/update

ssh qxgit@build "cd $dir; \
    git config --replace-all receive.denynonfastforwards false; \
    git config --replace-all receive.denydeletecurrent false; \
    mv $u ${u}.moved" || true

# set up the links to origin
cd /tmp 
    rm -rf /tmp/lnl
    git clone qxgit@build:/nett/uniq/git/lnl.git
# clean out origin
cd /tmp/lnl 
    for b in $(git branch --all | awk -F / '!/HEAD/ && /remotes/ {print $NF}'); do echo git push origin :${b}; git push origin :${b}; done
# clean out local
cd /tmp 
    rm -rf /tmp/lnl
    git clone qxgit@build:/nett/uniq/git/lnl.git
# rebuild local from scratch
cd /tmp/lnl 
    for t in $(git tag -l); do git push origin :refs/tags/${t}; git tag -d $t; done
    [ $(ls | wc -l) -eq 0 ] || exit 1
    touch file
    git add file
    # begin tests
    i=0
    echo 'set -x; git push origin experiment' > test$((++i)).sh
    echo 'set -x; git push origin h:ready' > test$((++i)).sh
    echo 'set -x; git co maser; git pull; git co h; git rebase master; git push origin h:ready' > test$((++i)).sh
    echo 'set -x; git pull; git co h; git reset HEAD^; git amend; git rebase master; git push origin h:ready' > test$((++i)).sh
    echo 'set -x; git co h; git pull --no-ff --commit --no-edit origin master; git push origin h:ready' > test$((++i)).sh
    chmod +x test*.sh
    git add test*.sh
    # end tests
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




    


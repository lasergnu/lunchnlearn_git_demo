#!/bin/bash
set -x
set -e

# Lunch n Learn demo
# Components
#  - Development git repo
#  - Simulated Origin
#  - Simulated workspace

dir=/tmp/lnl.git
u=$dir/hooks/update

git clone --bare $HOME/lunchnlearn_git_demo $dir
pushd $dir; \
    git config --replace-all receive.denynonfastforwards false; \
    git config --replace-all receive.denydeletecurrent false; \
    mv $u ${u}.moved
popd

# set up a clean workspace every run
cd /tmp 
    rm -rf /tmp/lnl
    git clone file://$dir lnl

# remove commits from simulated origin
cd /tmp/lnl
    for b in $(git branch --all | awk -F / '!/HEAD/ && /remotes/ {print $NF}'); do
        echo git push origin :${b}
        git push origin :${b}
    done

# clean out simulated workspace
cd /tmp 
    rm -rf /tmp/lnl
    git clone file://$dir lnl

# rebuild local from scratch
cd /tmp/lnl
    for t in $(git tag -l); do 
        git push origin :refs/tags/${t}
        git tag -d $t
    done
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

git clone --bare $HOME/lunchnlearn_git_demo $dir
pushd $dir; \
    git config --replace-all receive.denynonfastforwards false; \
    git config --replace-all receive.denydeletecurrent false; \
    mv ${u}.moved $u
popd





    


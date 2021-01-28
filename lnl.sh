#!/bin/bash
set -x
set -e

# setup clean simulated origin
dir=/tmp/lnl.git
rm -rf $dir
git clone --bare $HOME/lunchnlearn_git_demo $dir
pushd $dir; \
    git config --replace-all receive.denynonfastforwards false; \
    git config --replace-all receive.denydeletecurrent false; \
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
    echo 'git fetch --all' > test$((++i)).sh
    
    echo 'git push origin experiment' > test$((++i)).sh
    
    echo 'git push origin h:master' > test$((++i)).sh
    
    echo 'git checkout master
          git pull
          git checkout h
          git rebase master
          git push origin h:master' > test$((++i)).sh
    
    echo 'git pull
          git checkout h
          git reset HEAD^
          git amend
          git rebase master
          git push origin h:master' > test$((++i)).sh
    
    echo 'git checkout h
          git pull --no-ff --commit --no-edit origin master
          git push origin h:master' > test$((++i)).sh

    sed -i 's/^\s*//' test*.sh
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
    # unsync with origin
    cp .git/refs/heads/master .git/refs/remotes/origin/master

#git clone --bare $HOME/lunchnlearn_git_demo $dir
#pushd $dir; \
#    git config --replace-all receive.denynonfastforwards false; \
#    git config --replace-all receive.denydeletecurrent false; \
#popd





    


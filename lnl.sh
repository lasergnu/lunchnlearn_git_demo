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
    #for t in $(git tag -l); do
	#git push origin :refs/tags/${t}
	#git tag -d $t
    #done
    [ $(ls | wc -l) -eq 0 ] || exit 1
    touch file
    git add file

    # begin tests
    i=0

    echo 'echo do some work in master
          cp .git/feature .git/refs/heads/master
          git reset --hard HEAD' > $((++i))demorun.sh

    echo '# let us not pollute history with the typo
          #git rebase -i HEAD~3
          #git rebase -i HEAD~10'  > $((++i))demoshow.sh

    echo '# I just want to edit the commit msg. Several options:
          #git rebase -i HEAD~2
	  #git commit --amend"' > $((++i))demoshow.sh

    echo '# Lovely commit.  Now let us try to push this...
         git push' > $((++i))demoshow.sh

    echo '# Natural reaction is to git pull
          # Git now creates a commit that seems to indicate that two branches are merging
          # The only issue here is that you were out of sync
          # Many such merges creates unecessary mess in the history
          git pull' > $((++i))demoshow.sh

    echo 'echo tidy up
          cp .git/master .git/refs/remotes/origin/master
          git reset --hard HEAD^' > $((++i))demorun.sh
    
    echo '# The nice way is to first sync with origin
          git fetch --all' > $((++i))demoshow.sh

    echo '# And now we rebase the commit
          git rebase origin/master' > $((++i))demoshow.sh

    echo '# And now we are ready to push
          git push' > $((++i))demoshow.sh

    echo 'echo let us start all over again
          cp .git/master .git/refs/remotes/origin/master
          cp .git/master .git/refs/heads/master
          git reset --hard HEAD' > $((++i))demorun.sh

    echo 'echo let us work in a feature branch instead
          git checkout -b feature
          for i in {1..5}; do
            echo commmit$i >> file
            git commit -am commit$i
            sed -i s/mmm/mm/ file
            git commit -am typo$i
          done' > $((++i))demorun.sh

    echo '# tidy up the commit
          # git rebase -i HEAD~10' > $((++i))demoshow.sh

    echo '# we try to push local feature branch to origin/feature
          git push origin feature' > $((++i))demoshow.sh

    echo '# we try to push local feature branch to origin/master
         git push origin feature:master' > $((++i))demoshow.sh

    echo '# fetch all
          git fetch --all'  > $((++i))demoshow.sh

    echo '# rebase with conflict and git mergetool
          git rebase origin/master' > $((++i))demoshow.sh

    echo '# clean up remote branch
          git push origin :feature' > $((++i))demoshow.sh

    echo '# safe to pull master now
          git checkout master
          git pull' > $((++i))demoshow.sh

#    echo 'echo let us make a conflict
#          cp .git/feature .git/refs/heads/
#          git checkout feature' > $((++i))demorun.sh

#    echo '# we try to push local feature branch to origin/feature
#          git push origin feature' > $((++i))demoshow.sh    

#    echo '# we try to push this feature to master
#          git push origin feature:master' > $((++i))demoshow.sh

#    echo '# same issue as before
#          git checkout master
#	  git pull # safe since we worked on feature branch
#	  git checkout feature
#	  git rebase master
#	  git push origin feature:master' > $((++i))demoshow.sh

#    echo 'git pull
#	  git checkout feature
#	  git reset HEAD^
#	  git amend
#	  git rebase master
#	  git push origin feature:master' > $((++i))demoshow.sh

#    echo 'git checkout feature
#	  git pull --no-ff --commit --no-edit origin master
#	  git push origin h:master' > $((++i))demoshow.sh

#    echo '# realised I want to do an experiment with an old version
#          cp .git/experiment .git/refs/heads/' > $((++i))demorun.sh
    
#    echo '# let us push this to origin
#          git push origin experiment' > $((++i))demoshow.sh

    sed -i 's/^\s*//' *demo*.sh
    chmod +x *demo*.sh
    git add *demo*.sh

    for ((j = 1 ; j <= $i ; j++)); do
	echo ========= $j ======== >> all.txt
	cat ${j}demo* >> all.txt
    done
    git add all.txt
    # end tests

    git commit -am "first commit"
    for c in {a..f}; do echo $c >> file; git commit -am $c; done
    git checkout -b experiment
    echo my changes >> file
    git commit -am "wip"
    git checkout master
    for c in {g..r}; do echo $c >> file; git commit -am $c; done
    git push -u origin master
    git checkout -b feature
    sed -i '/c/s/.*/c, see and see are homophones/g' file
    git commit -am "homophone"
    sed -i '/c/s/.*/c, sea and see are homophones/g' file
    git commit -am "fix typo"
    git checkout master
    for c in {s..z}; do echo $c >> file; git commit -am $c; done
    git push
    git reset --hard master~8

    # hide master, feature and experiment
    cp .git/refs/heads/master     .git/
    mv .git/refs/heads/feature    .git/
    mv .git/refs/heads/experiment .git/

    # unsync with origin
    cp .git/refs/heads/master .git/refs/remotes/origin/master


    # set tracking
#    git branch --set-upstream-to=origin/h h
#    git branch --set-upstream-to=origin/master master


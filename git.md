 ## Git
 
```bash
git init #initializing git in a directory

git status

git add <file> / git reset <file> / git add -A . / git add '*.txt'

git commit -m "What we have changed"

git log --summary

git remote add origin https://remote_repository

git push -u origin master #push local changes to origin repo in the server, -u: remember the paramenters

git stash ->pull..-> git stash apply #instead of commit you can stag before pulling

git pull origin master

git diff HEAD / git diff --staged

git checkout--<file>  #get rid of all the changes since the last commit for that file

git branch <branch> / git checkout <branch> / git checkout -b <branch>

git rm '*.txt' / git rm  -r <folder>

git merge <branch>

git branch -d <branch> / git branch -d -f <branch> #when no merging you need to force in order to delete a branch (-d-f = -D)

git push



#Pull request:

git checkout -b <pull_request>

git push origin <pull_request>
```


================================


### Git global setup

git config --global user.name "Maria Feria"
git config --global user.email "maria.feria@zpg.co.uk"

##### Create a new repository

git clone git@gitlab.zoopla.co.uk:mferia/explorer.git
cd explorer
touch README.md
git add README.md
git commit -m "add README"
git push -u origin master

##### Existing folder

cd existing_folder
git init
git remote add origin git@gitlab.zoopla.co.uk:mferia/explorer.git
git add .
git commit
git push -u origin master

##### Existing Git repository

cd existing_repo
git remote add origin git@gitlab.zoopla.co.uk:mferia/explorer.git
git push -u origin --all
git push -u origin --tags

========================

### Check out, review, and merge locally

Step 1. Fetch and check out the branch for this merge request
```bash
git fetch origin
git checkout -b PTD389_aws_unload origin/PTD389_aws_unload
```

Step 2. Review the changes locally

Step 3. Merge the branch and fix any conflicts that come up
```bash
git checkout master
git merge --no-ff PTD389_aws_unload
```


Step 4. Push the result of the merge to GitLab
```bash
git push origin master

git diff --name-status master..branchName
```

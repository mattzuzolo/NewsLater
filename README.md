Handy Quick Git reference (These should work no matter how you personally have Git setup):
In case you need it for when the github app fails to do what you want it to.

Typical Workflow:
git pull origin master
git add -A
git commit -am"I changed a bunch O' stuff" git pull origin master git push origin master

Clone
git clone https://github.com/SakoGuru/PIPSQUEAK.git
Add
git add 
git add -A //(ADDS ALL THE FILES)
Commit
git commit -am"Message about the commit" Pull
git pull origin master
git pull origin 
Push
git push origin master
git push origin 
Merge (sequence for safe merge)
git checkout master
git pull origin master
git merge 
git push origin master
Rebase (got a merge conflict)
git rebase --continue
git add -A
git status //Check if you have anything else to commit git push origin master

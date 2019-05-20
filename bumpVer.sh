cd ../$1
oldDep=$(grep $2 configure/CONFIG_MODULE)
oldVer=$3
newVer=$4

newDep=${oldDep/$oldVer/$newVer}
sed -i "s/$oldDep/$newDep/" configure/CONFIG_MODULE

git add configure/CONFIG_MODULE
git commit -m "Bump version of module dependency $2 from $3 to $4"

git diff HEAD^

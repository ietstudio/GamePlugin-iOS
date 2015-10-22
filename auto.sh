#!/bin/bash
function pringMsg()
{
	echo "press enter to continue"
	read haha
}

version=$1
echo "-->update to $version"
pringMsg

echo "-->update example proj"
cd Example
pod update --no-repo-update
cd ..
pringMsg

echo "-->pod lib lint"
pod lib lint --sources='https://github.com/ietstudio/Specs.git,https://github.com/CocoaPods/Specs.git'
pringMsg

echo "-->commit"
git add .
git commit -m "update to $version"
pringMsg

echo "-->set tag"
git tag $version
pringMsg

echo "-->push"
git push
pringMsg

echo "-->push tag"
git push --tag
pringMsg

echo "-->pod spec lint"
pod spec lint --sources='https://github.com/ietstudio/Specs.git,https://github.com/CocoaPods/Specs.git'
pringMsg

echo "-->pod repo push"
pod repo push ietstudio *.podspec
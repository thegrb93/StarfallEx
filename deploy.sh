#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"

git config user.name "$(git log -1 $TRAVIS_COMMIT --pretty="%aN")"
git config user.email "$(git log -1 $TRAVIS_COMMIT --pretty="%cE")"

# Save some useful information
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "This is a pull request, won't deply to gh-pages"
	if echo $TRAVIS_COMMIT_MESSAGE | grep -q "\[preview\]"; then
		echo "Preview requested."
		tar -cf doc-preview.tar doc/
		echo "Uploading to transfer.sh"
		curl -s --upload-file doc-preview.tar "https://transfer.sh/sf-doc-${SHA}.tar" > preview-link.txt
		echo "Deploy finished, link: $(<preview-link.txt)"
	fi
    exit 0
fi

echo "Decrypting SSH key"
openssl aes-256-cbc -K $encrypted_0bb1b763922b_key -iv $encrypted_0bb1b763922b_iv -in deploy_key.enc -out deploy_key -d
echo "Adding the key"
eval `ssh-agent -s`
chmod 600 deploy_key
ssh-add deploy_key
echo "Key added"

# Clone the existing gh-pages for this repo into out/
# Create a new empty branch if gh-pages doesn't exist yet (should only happen on first deply)
git clone $REPO out
cd out
git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH
cd ..

# Get files that have to be pushed to gh-pages
echo "Moving doc files"
cp -f docgen/sf_doc.json out/

cd out

# If there are no changes to docs then just skip
if git diff --quiet --ignore-space-at-eol -b -w --ignore-blank-lines; then
    echo "No changes to the output on this push; Skipping."
else
	echo "Commiting"
	git add -A .
	git commit -m "Updating documentation: ${SHA}"


	echo "Pushing gh-pages"
	git push $SSH_REPO $TARGET_BRANCH

fi
cd ..


echo "Done!"

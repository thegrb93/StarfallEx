#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"


# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "This is a pull request, skipping deploy."
    exit 0
fi

echo "Decrypting SSH key"
openssl aes-256-cbc -K $encrypted_0bb1b763922b_key -iv $encrypted_0bb1b763922b_iv -in deploy_key.enc -out deploy_key -d
echo "Adding the key"
eval `ssh-agent -s`
chmod 600 deploy_key
ssh-add deploy_key
echo "Key added"

# Save some useful information
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

# Clone the existing gh-pages for this repo into out/
# Create a new empty branch if gh-pages doesn't exist yet (should only happen on first deply)
git clone $REPO out
cd out
git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH
cd ..

# Get files that have to be pushed to gh-pages
echo "Moving doc files"
cp -rf doc/* out/

cd out
git config user.name "Travis CI"
git config user.email "$COMMIT_AUTHOR_EMAIL"

# If there are no changes to docs then just skip
if git diff --quiet; then
    echo "No changes to the output on this push; Skipping."
else
	echo "Commiting"
	git add -A .
	git commit -m "Updating documentation: ${SHA}"


	echo "Pushing gh-pages"
	git push $SSH_REPO $TARGET_BRANCH

fi
cd ..

#Let's also check for doc.lua
local head_ref branch_ref
head_ref=$(git rev-parse HEAD)
if [[ $? -ne 0 || ! $head_ref ]]; then
	echo "failed to get HEAD reference"
	exit 1
fi
branch_ref=$(git rev-parse "$TRAVIS_BRANCH")
if [[ $? -ne 0 || ! $branch_ref ]]; then
	echo "failed to get $TRAVIS_BRANCH reference"
	exit 1
fi
if [[ $head_ref != $branch_ref ]]; then
	echo "HEAD ref ($head_ref) does not match $TRAVIS_BRANCH ref ($branch_ref)"
	echo "someone may have pushed new commits before this build cloned the repo"
	exit 1
fi
if ! git checkout "$TRAVIS_BRANCH"; then
	echo "failed to checkout $TRAVIS_BRANCH"
	exit 1
fi

#Add only docs.lua
git add "lua/starfall/editor/docs.lua"
if git diff --quiet --staged; then #checking if there is a diff for staged changes (so only doc)
    echo "No changes to docs.lua, skipping."
else
	echo "Commiting.."
	git commit -m "Updating documentation: ${SHA} [ci skip]"
	echo "Pushing.."
	git push --quiet $SSH_REPO $TRAVIS_BRANCH
fi

echo "Done!"

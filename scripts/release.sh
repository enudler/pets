# Increase versio
VERSION=$(npm version $RELEASE_TYPE -m "Release new version")
# Tag the current build image
docker login -u gitlab-ci-token -p $CI_BUILD_TOKEN $CI_REGISTRY
tagImage.sh $APP_IMAGE $VERSION
# Push the commit tag to gitlab
git push --follow-tags origin master
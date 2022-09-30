TAG="${TAG:-latest}"
REPO=zeetdev/build-init
IMAGE=$REPO:$TAG

echo "Building image $IMAGE"

# multi arch release
docker buildx build \
    --tag $IMAGE \
    --platform linux/amd64,linux/arm64 \
    --file build.Dockerfile \
    --push \
    .

set -x
set -e

# Start daemon
/usr/local/bin/dockerd --data-root /var/lib/docker --storage-driver=overlay2 &

sleep 10

DOCKER_HOST=unix:///var/run/docker.sock /usr/local/bin/docker version

set +x

# Load npm script
echo "registry=$NPM_REGISTRY" > /root/.npmrc
echo "always-auth=true" >> /root/.npmrc
echo $NPMRC >> /root/.npmrc

# Set default platform if not specified
PLATFORM=${PLATFORM:-"linux/amd64"}

# Set Docker host to use Unix socket
export DOCKER_HOST=unix:///var/run/docker.sock

# ECR login to all registries (two accounts)
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REGISTRY.dkr.ecr.$AWS_REGION.amazonaws.com

if [ -n "${SECONDARY_REGISTRY}" ]; then
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $SECONDARY_REGISTRY.dkr.ecr.$AWS_REGION.amazonaws.com
fi

set -x

# Build and push
DOCKER_BUILDKIT=1 docker buildx build \
    --platform ${PLATFORM} \
    --security-revert=CVE-2023-46809 \
    -t $REPOSITORY:$TAG \
    -f $DOCKERFILE \
    --secret id=npm,src=/root/.npmrc \
    --load \
    $CONTEXT

# Push to primary registry
docker tag $REPOSITORY:$TAG $REGISTRY.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY:$TAG
docker push $REGISTRY.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY:$TAG

# Push to secondary registry if defined
if [ -n "${SECONDARY_REGISTRY}" ]; then
    docker tag $REPOSITORY:$TAG $SECONDARY_REGISTRY.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY:$TAG
    docker push $SECONDARY_REGISTRY.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY:$TAG
fi

# Clean up
docker rmi $REPOSITORY:$TAG
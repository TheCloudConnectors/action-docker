set -x
set -e

# Start daemon
/usr/local/bin/dockerd --data-root /var/lib/docker -s aufs --experimental &

sleep 10

/usr/local/bin/docker version

set +x

# Load npm script
echo "registry=$NPM_REGISTRY" > /root/.npmrc
echo "always-auth=true" >> /root/.npmrc
echo $NPMRC >> /root/.npmrc

# ECR login to all registries (two accounts)
$(aws ecr get-login --no-include-email --region=$AWS_REGION --registry-ids $REGISTRY)

if [ -n "${SECONDARY_REGISTRY}" ]; then
    $(aws ecr get-login --no-include-email --region=$AWS_REGION --registry-ids $SECONDARY_REGISTRY)
fi

set -x

# Build image
DOCKER_BUILDKIT=1 /usr/local/bin/docker build --rm=true --pull=true -t $GITHUB_SHA -f $DOCKERFILE --secret id=npm,src=/root/.npmrc $CONTEXT

/usr/local/bin/docker tag $GITHUB_SHA $REGISTRY.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY:$TAG
/usr/local/bin/docker push $REGISTRY.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY:$TAG

if [ -n "${SECONDARY_REGISTRY}" ]; then
    /usr/local/bin/docker tag $GITHUB_SHA $SECONDARY_REGISTRY.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY:$TAG
    /usr/local/bin/docker push $SECONDARY_REGISTRY.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY:$TAG
fi

/usr/local/bin/docker rmi $GITHUB_SHA
/usr/local/bin/docker system prune -f
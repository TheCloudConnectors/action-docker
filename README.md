# Docker to ECR

This action builds a docker image using docker-in-docker then publishes it to ECR registries (primary and secondary). It supports build arguments and private npm registries.

## Example usage 

```yml
name: Build docker image

on:
  push:
    branches:
        - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Get tag name
      id: tag
      run: echo ::set-output name=SOURCE_TAG::${GITHUB_REF#refs/tags/}
    - uses: TheCloudConnectors/action-docker@master
      env:
        NPM_REGISTRY: ${{ secrets.NPM_REGISTRY }}
        NPMRC: ${{ secrets.NPMRC }}
        AWS_REGION: us-east-2
        REGISTRY: 123456789
        SECONDARY_REGISTRY: 987654321
        REPOSITORY: example
        DOCKERFILE: Dockerfile
        CONTEXT: ./
        TAG: ${{ steps.tag.outputs.SOURCE_TAG }}
        PLATFORM: linux/arm64
        BUILD_ARGS: |
          AUTH_SECRET=${{ secrets.AUTH_SECRET }}
          NEXT_PUBLIC_API_URL=https://api.staging.example.com
          NEXT_PUBLIC_VERSION=${{ github.sha }}
```

## Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `AWS_REGION` | AWS region where ECR repositories are located | Yes | - |
| `REGISTRY` | Primary ECR registry ID | Yes | - |
| `SECONDARY_REGISTRY` | Secondary ECR registry ID | No | - |
| `REPOSITORY` | ECR repository name | Yes | - |
| `NPM_REGISTRY` | NPM registry URL | No | - |
| `NPMRC` | NPM authentication token | No | - |
| `DOCKERFILE` | Path to Dockerfile | Yes | - |
| `CONTEXT` | Docker build context | Yes | - |
| `TAG` | Image tag | Yes | - |
| `PLATFORM` | Target platform for the image | No | linux/amd64 |
| `BUILD_ARGS` | Build arguments to pass to docker build command. Each line will be passed as a separate `--build-arg` | No | - |

## Build Arguments

You can pass build arguments to your Dockerfile using the `BUILD_ARGS` environment variable. Each line in this variable will be passed as a separate `--build-arg` to the docker build command.

Example:
```
BUILD_ARGS: |
  ARG1=value1
  ARG2=value2
  ARG3=value3
```

This will be transformed into: `--build-arg ARG1=value1 --build-arg ARG2=value2 --build-arg ARG3=value3`

## Publish

Tag new version and publish release
```bash
git ci -am "v1"
git tag -a -m "Release notes" v1
git push --follow-tags
```
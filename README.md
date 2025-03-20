# Docker to ECR

This action build a docker image using docker in docker then publish to ECR registries (primary and secondary).

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
          ARG1=value1
          ARG2=${{ secrets.SECRET_VALUE }}
          ARG3=${{ vars.ENVIRONMENT_VALUE }}
```

## Publish

Tag new version and publish release
```bash
git ci -am "v1"
git tag -a -m "Release notes" v1
git push --follow-tags
```
#!/usr/bin/env python3

import argparse
import re
import boto3


def parse_registry(registry):
    """Return (boto3_service_name, region) for the given ECR registry URL."""
    if registry.startswith('public.ecr.aws'):
        return ('ecr-public', 'us-east-1')
    m = re.match(r'^(\d+)\.dkr\.ecr\.([^.]+)\.amazonaws\.com', registry)
    if m:
        return ('ecr', m.group(2))
    raise ValueError(f"Unrecognized ECR registry: {registry}")


parser = argparse.ArgumentParser(
    description='Implement basic ECR (public or private) image lifecycle policy')
parser.add_argument('--repo', dest='repositoryName', action='store', required=True,
                    help='Name of the ECR repository')
parser.add_argument('--registry', dest='registry', action='store', required=True,
                    help='Registry URL; determines public vs private ECR and region')
parser.add_argument('--keep', dest='keep', action='store', default=10, type=int,
                    help='number of tagged images to keep, default 10')
parser.add_argument('--dev', dest='delete_dev', action='store_true',
                    help='also delete in-development images only having tags like v0.1.1-commitNr-githash')

args = parser.parse_args()

service, region = parse_registry(args.registry)
client = boto3.client(service, region_name=region)

images = client.describe_images(repositoryName=args.repositoryName)[
    "imageDetails"]

untagged = []
kept = 0

# actual Image
# imageManifestMediaType: 'application/vnd.oci.image.manifest.v1+json'
# image Index
# imageManifestMediaType: 'application/vnd.oci.image.index.v1+json'

# Sort by date uploaded
for image in sorted(images, key=lambda d: d['imagePushedAt'], reverse=True):
    # Remove all untagged
    # if registry uses image index all actual images will be untagged anyways
    if 'imageTags' not in image:
        untagged.append({"imageDigest": image['imageDigest']})
        continue

    # check for dev tags
    if args.delete_dev:
        _delete = True
        for tag in image["imageTags"]:
            # Look for at least one tag NOT being a SemVer dev tag
            # untagged dev builds get tagged as <tag>-g<commit>
            if "-g" not in tag and "dirty" not in tag:
                _delete = False
        if _delete:
            print("Deleting development image {}".format(image["imageTags"]))
            untagged.append({"imageDigest": image['imageDigest']})
            continue

    if kept < args.keep:
        kept = kept+1
        print("Keeping tagged image {}".format(image["imageTags"]))
        continue
    else:
        print("Deleting tagged image {}".format(image["imageTags"]))
        untagged.append({"imageDigest": image['imageDigest']})

if untagged:
    deleted_images = client.batch_delete_image(
        repositoryName=args.repositoryName, imageIds=untagged)

    if deleted_images["imageIds"]:
        print("Deleted images: {}".format(deleted_images["imageIds"]))

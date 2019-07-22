# run-py-reload

## Introduction

This is an experiment on fast developer iteration for Python running on [Cloud Run][]. This is a followup to some [failed experiments](https://github.com/ptone/run-go-plugin) (success!) in golang.


## Try it

Configure your cloud project:

        gcloud config set [your-project]
        PROJECT=$(gcloud config list --format 'value(core.project)')

Build the python "harness" run container:

        docker build -t gcr.io/$PROJECT/py-dev-harness .
        docker push gcr.io/$PROJECT/py-dev-harness .

        gcloud alpha run deploy py-dev-harness \
        --image gcr.io/$PROJECT/py-dev-harness:latest \
        --allow-unauthenticated \
        --platform managed \
        --region us-central1

Grab the URL of the harness:

        export HARNESS_URL=$(gcloud alpha run services describe py-dev-harness --region us-central1 --format='value(status.address.url)')

In a terminal, start the update watcher:

        bash update.sh

## How it works

 - uses inotifywait (on linux) or fswatch (on macos) to watch for changes
 - then, zips the current python
 - uploads the zipfile to a special handler which over-writes the CWD
 - uses the flask debug server, which auto-reloads

## Caveats/TODO/improvements

  - Note: you need to rebuild the harness if you change the requirements.txt
  - Clarify how the Dockerfile should be modified between dev and prod, e.g. should the entry point be a script which looks at an env var?

This is not a Google Product

[Cloud Run]: https://cloud.google.com/run

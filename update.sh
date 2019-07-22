#!/usr/bin/env bash

# Copyright 2019 Google Inc. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to writing, software distributed
# under the License is distributed on a "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.

# See the License for the specific language governing permissions and
# limitations under the License.

## Author: ptone@google.com (Preston Holmes)
## Author: glasnt@google.com (Katie McLaughlin)


usage() { 
   local name
   name=$(basename "$0")
   echo "${name} -- harness the power of reloadable content"
   echo "see README.md" 
}

update_code(){
    start=`date +%s`
    sleep 0.5
    tmpfile=$(mktemp /tmp/build-XXXXXX)
    zip -R $tmpfile '*.py' -x './.venv/**'
    curl --header "Content-Type:application/octet-stream" --data-binary @$tmpfile.zip $HARNESS_URL/_upload
    rm $tmpfile
    end=`date +%s`
    runtime=$((end-start))
    src_changed=0
    echo
    echo "------------ Done in $runtime seconds"
    echo "------------ Waiting for src changes"
    echo
}

main(){

    if [[ -z "$HARNESS_URL" ]] ; then
        usage
        echo -e "\nHARNESS_URL not specified."
        echo "You probably want to run the following: "
        echo -e "\nexport HARNESS_URL=\$(gcloud alpha run services describe py-dev-harness --region us-central1 --platform managed --format='value(status.address.url)')\n"
        exit 1
    fi

    echo "------------ Waiting for src changes"

    fswatch -0 `pwd` | while read -d "" event;
    do
        what=""; changed=0
        for line in $event; do
            if [[ "$line" =~ .*py$ ]]; then
                changed=1
                what=$line
            fi
        done

        if [[ $changed == 1 ]]; then
            echo "I detected a useful event!"
            update_code
        fi
    done

}

main "$@"

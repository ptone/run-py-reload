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

import os
import shutil

from tempfile import mkstemp

from flask import Flask, request

app = Flask(__name__)



@app.route('/')
def hello_world():
    target = os.environ.get('TARGET', 'World')
    return 'Hello   prime -demo yoi{}!\n'.format(target)







@app.route('/_upload', methods=['GET', 'POST'])
def upload_file():

    if request.headers['Content-Type'] == "application/octet-stream":
        tmp_file, fpath = mkstemp(suffix=".zip")
        with os.fdopen(tmp_file, 'w+b') as fp:
            fp.write(request.data)
        app_dir = os.path.dirname(os.path.realpath(__file__))
        shutil.unpack_archive(fpath, app_dir)
        os.unlink(fpath)

        return "Binary message written!"


if __name__ == "__main__":
    # debug server
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))

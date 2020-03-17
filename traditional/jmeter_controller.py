#!/usr/bin/env python
"""
        Author - Gabriel Starczewski
        https://www.linkedin.com/in/gabriel-star-tester
"""

import os, sys,subprocess
from flask import Flask, request

app = Flask(__name__)

@app.route('/restart/<version>/<xms>/<xmx>')
def restart(version,xms,xmx,methods=['GET']):
    if sys.platform == "linux" or sys.platform == "linux2":
        subprocess.call(["./startServer.sh",version,"-Xms%s -Xmx%s" %(xms,xmx)])
        return "Node restarted"

@app.route('/stop')
def stop(methods=['GET']):
    if sys.platform == "linux" or sys.platform == "linux2":
        subprocess.call(["./stopServer.sh"])
        return "Node stopped"



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

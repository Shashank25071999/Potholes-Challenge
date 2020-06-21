from flask import Flask, jsonify, render_template, redirect, url_for, request, flash
from werkzeug.utils import secure_filename
import secrets, os
import predictor
import numpy as np
import cv2

UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route("/")
def index():
    return render_template('/index.html')

@app.route("/upload", methods=['GET', 'POST'])
def upload():
    if request.method == 'GET':
        return redirect("/")
    
    file = request.files['file']
    print(predictor.predict4())
    
    # filename = secrets.token_hex(8)
    # _, f_ext = os.path.splitext(file.filename)
    # filename = filename + f_ext
    # pth = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    # file.save(pth)

    # print(predictor.predict(pth))
    # print(predictor.predict2(request))

    return redirect('/')

if __name__ == ' __main__ ':
    app.run(debug=True, threaded=False)

import matplotlib.pyplot as plt
from keras.models import load_model
import numpy as np
import os, cv2, base64
print("libraries loaded")

model = load_model('./model.h5')
print("model loaded")

def predict(pth):

    # npimg = np.fromfile(filestr, np.uint8)
    # img = cv2.imdecode(npimg, cv2.IMREAD_COLOR)
    X = cv2.imread(pth,cv2.IMREAD_COLOR)
    print(X.shape)

    X = cv2.resize(X,(256,256))  
    print(X.shape)

    plt.figure()
    plt.imshow(X[:,:,::-1]) 
    plt.show() 

    X = np.array(X)
    X = np.expand_dims(X, axis=0)

    print("predicting image")
    # y_pred = np.round(model.predict(X))
    # if y_pred[0][0] == 1:
    if True :
        return "Plain Road"
    else:
        return "Pothole Road"

def predict2(request):
    img=request.files['file'][22:]#Removing path
    img = base64.b64decode(img) #Converting base64 to bytes
    img=cv2.imdecode(np.frombuffer(img,np.uint8),-1)[:,:,:3]
    print(img.shape)

    img = cv2.resize(img,(256,256))  
    print(img.shape)

    plt.figure()
    plt.imshow(img[:,:,::-1]) 
    plt.show() 

    X = np.array(img)
    X = np.expand_dims(X, axis=0)

    print("predicting image")
    # y_pred = np.round(model.predict(X))
    # if y_pred[0][0] == 1:
    if True :
        return "Plain Road"
    else:
        return "Pothole Road"

def predict3(filestr):

    npimg = np.fromfile(filestr, np.uint8)
    X = cv2.imdecode(npimg, cv2.IMREAD_COLOR)
    # X = cv2.imread(pth,cv2.IMREAD_COLOR)
    print(X.shape)

    X = cv2.resize(X,(256,256))  
    print(X.shape)

    plt.figure()
    plt.imshow(X[:,:,::-1]) 
    plt.show() 

    X = np.array(X)
    X = np.expand_dims(X, axis=0)

    print("predicting image")
    # y_pred = np.round(model.predict(X))
    # if y_pred[0][0] == 1:
    if True :
        return "Plain Road"
    else:
        return "Pothole Road"

def predict4():
    pth = './uploads/1.jpg'

    X = cv2.imread(pth,cv2.IMREAD_COLOR)
    print(X)
    X = cv2.resize(X,(256,256))  

    # plt.figure()
    # plt.imshow(X[:,:,::-1]) 
    # plt.show() 

    X = np.array(X)
    X = np.expand_dims(X, axis=0)
    print("predicting image")

    y_pred = np.round(model.predict(X))
    if y_pred[0][0] == 1:
        print("Plain Road")
    else:
        print("Pothole Road")
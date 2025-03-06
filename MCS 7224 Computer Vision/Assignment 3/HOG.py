import os
import numpy as np
import pandas as pd
import cv2 as cv
from pathlib import Path
import warnings
from skimage.feature import hog
import tqdm
from sklearn.neighbors import KNeighborsClassifier
from sklearn import metrics
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler
from sklearn.neighbors import NearestNeighbors
warnings.filterwarnings("ignore")
pd.options.display.max_columns = None

image_folder = "images/Leafspot Scale 1";
all_images = []
#labels = []
def load_image(ids,path=image_folder):
    img = cv.imread(image_folder+ids+'.jpg',cv.IMREAD_GRAYSCALE) #load at gray scale
    #img = cv.cvtColor(img, cv.COLOR_BGR2GRAY) #convert to gray scale
    return img,ids
#20k samples were taken for modeling
# for ids in tqdm(list(styles.id)[:20000]):
#     img,ids = load_image(str(ids))
#     if img is not None:
#         all_images.append([img,int(ids)])
#     #labels.append(ids)
len(all_images)


def resize_image(img, ids):
    return cv.resize(img, (60, 80), interpolation=cv.INTER_LINEAR)


all_images_resized = [[resize_image(x, y), y] for x, y in all_images]
len(all_images_resized)

train_images = np.stack(df_labels.image.values,axis=0)
n_samples = len(train_images)
data_images = train_images.reshape((n_samples, -1))

##HOG Descriptor
#Returns a 1D vector for an image
ppcr = 8
ppcc = 8
hog_images = []
hog_features = []
for image in tqdm(train_images):
    blur = cv.GaussianBlur(image,(5,5),0) #Gaussian Filtering
    fd,hog_image = hog(blur, orientations=8, pixels_per_cell=(ppcr,ppcc),cells_per_block=(2,2),block_norm= 'L2',visualize=True)
    hog_images.append(hog_image)
    hog_features.append(fd)

hog_features = np.array(hog_features)
hog_features.shape


edges = [cv.Canny(image,50,150,apertureSize = 3) for image in train_images]
edges = np.array(edges)
n_samples_edges = len(edges)
edge_images = edges.reshape((n_samples, -1))
edge_images.shape


train_images.shape, hog_features.shape, edge_images.shape

edge_hog = np.hstack([hog_features,edge_images])
edge_hog.shape
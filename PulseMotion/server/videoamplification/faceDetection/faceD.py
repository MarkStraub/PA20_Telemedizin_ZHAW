import cv2
import os
import sys
import natsort
import math
import numpy as np
from PIL import Image
import urllib.request as urlreq


class FaceD:
    def __init__(self):
        # create an instance of the Facial landmark Detector with the model
        self.LBFmodel = os.path.dirname(os.path.realpath(__file__)) + "/LFBmodel.yaml"
        try:
            self.landmark_detector = cv2.face.createFacemarkLBF()
        except Exception as e:
            print(e)
        self.landmark_detector.loadModel(self.LBFmodel)

    def start(self, path, filename):
        self.filename = filename
        self.imagePath = self.createFolders(path, filename)
        filepath = path + '/' + filename
        self.videoToFrame(filepath)

        try:
            self.image, self.gray = self.loadImageAndTurnGray(self.imagePath)
            self.xF, self.yF, self.wF, self.hF = self.get_face(self.detect_face(self.image))
        except Exception as e:
            print(e)

        try:
            self.rL, self.rR = self.getRatio()
            self.crop_images()
        except Exception as e:
            print(e)

        self.resizeImages()
        self.generate_video(filename)
        print('initialized class')

    def createFolders(self, path, filename):
        # Read the video from specified path
        filePath = os.path.join(path, filename)
        cam = cv2.VideoCapture(filePath)
        facePath = os.path.join(path, 'faceDetection')

        try:
            # creating a folder named data
            if not os.path.exists(facePath):
                os.makedirs(facePath)
                # if not created then raise error
        except OSError:
            print('Error: Creating directory of faceDetection')
            # frame

        datapath = path + '/faceDetection/' + filename[0:-4]

        try:
            # creating a folder named data
            if not os.path.exists(datapath):
                os.makedirs(datapath)
                # if not created then raise error
        except OSError:
            print('Error: Creating directory of faceDetection')
            # frame
        return datapath

    def videoToFrame(self, filePath):
        # Read the video from specified path
        cam = cv2.VideoCapture(filePath)

        currentframe = 0

        while (True):

            # reading from frame
            ret, frame = cam.read()

            if ret:
                # if video is still left continue creating images
                name = self.imagePath + '/frame' + str(currentframe) + '.jpg'
                # print('Creating...' + name)

                # writing the extracted images
                cv2.imwrite(name, frame)

                # increasing counter so that it will
                # show how many frames are created
                currentframe += 1
            else:
                break

    ###################################################################
    # videoToFrame(videoPath)
    ###################################################################

    def detect_face(self, img):
        haarcascade = "haarcascade_frontalface_alt2.xml"

        # create an instance of the Face Detection Cascade Classifier
        # faceCascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")
        faceCascade = cv2.CascadeClassifier(cv2.data.haarcascades + haarcascade)
        # detect Faces
        faces = faceCascade.detectMultiScale(
            img,
            scaleFactor=1.3,
            minNeighbors=3,
            minSize=(30, 30)
        )
        # print("Faces:\n", faces)
        return faces

    def get_face(self, faces):
        xF = faces[0][0]
        yF = faces[0][1]
        wF = faces[0][2]
        hF = faces[0][3]
        cv2.rectangle(self.image, (xF, yF), (xF + wF, yF + hF), (255, 255, 255), 2)
        return xF, yF, wF, hF

    def detect_landmarks(self, image, face, landmark_detector):
        # Detect landmarks on "image_gray"
        _, landmarks = landmark_detector.fit(image, face)

        # print coordinates of detected landmarks
        # print("landmarks LBF\n", landmarks)

        return landmarks

    def get_eyes(self, landmarks):
        for landmark in landmarks:
            eyeLeft = landmark[0][36]
            eyeRight = landmark[0][45]

        return eyeLeft, eyeRight

    def calculateRatioLeft(self, eyeLeft):
        width = eyeLeft[0] - self.xF
        height = eyeLeft[1] - self.yF

        ratio = []

        ratio.append(width)
        ratio.append(height)

        return ratio

    def calculateRatioRight(self, eyeRight):
        width = (self.xF + self.wF) - eyeRight[0]
        height = (self.yF + self.hF) - eyeRight[1]

        ratio = []

        ratio.append(width)
        ratio.append(height)

        return ratio

    ##################################################################
    # load image & turn it into gray
    def loadImageAndTurnGray(self, datapath):
        image = cv2.imread(datapath + '/frame1.jpg')
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        return image, gray

    def getRatio(self):
        faces = self.detect_face(self.gray)
        # xF, yF, wF, hF = self.get_face()
        eyeLeft, eyeRight = self.get_eyes(self.detect_landmarks(self.image, faces, self.landmark_detector))
        ratioLeft = self.calculateRatioLeft(eyeLeft)
        ratioRight = self.calculateRatioRight(eyeRight)
        return ratioLeft, ratioRight

    def crop_images(self):
        unsorted_images = [img for img in os.listdir(self.imagePath) if img.endswith(".jpg")]
        images = natsort.natsorted(unsorted_images, reverse=False)

        counter = 0
        cropPath = self.imagePath + '/cropped_faces'
        try:
            # creating a folder named data
            if not os.path.exists(cropPath):
                os.makedirs(cropPath)

                # if not created then raise error
        except OSError:
            print('Error: Creating directory of data')

        for img in images:
            image = cv2.imread(os.path.join(self.imagePath, img))
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

            faces = self.detect_face(gray)

            eyeLeft, eyeRight = self.get_eyes(self.detect_landmarks(image, faces, self.landmark_detector))

            top = (eyeLeft[1] - self.rL[1])
            bottom = (float(top) + (4*(self.rL[0])))
            left = (eyeLeft[0] - self.rL[0])
            right = (float(left) + (4*(self.rL[0])))

            i = Image.open(os.path.join(self.imagePath, img))
            img_res = i.crop((float(left), float(top), float(right), float(bottom)))
            img_res = img_res.save(cropPath + '/frame_' + str(counter) + '.jpg')

            counter += 1

    def resizeImages(self):
        imageFolder = self.imagePath + '/cropped_faces'

        # os.chdir(imageFolder)
        mean_height = 0
        mean_width = 0

        num_of_images = len(os.listdir(imageFolder))
        # print(num_of_images)

        for file in os.listdir(imageFolder):
            im = Image.open(os.path.join(imageFolder, file))
            width, height = im.size
            mean_width += width
            mean_height += height

        mean_width = int(mean_width / num_of_images)
        mean_height = int(mean_height / num_of_images)

        for file in os.listdir(imageFolder):
            if file.endswith(".jpg") or file.endswith(".jpeg") or file.endswith("png"):
                # opening image using PIL Image
                im = Image.open(os.path.join(imageFolder, file))

                # im.size includes the height and width of image
                width, height = im.size

                # resizing
                imResize = im.resize((mean_width, mean_height), Image.ANTIALIAS)
                imResize.save( imageFolder + '/' + file, 'JPEG', quality = 95) # setting quality
                # printing each resized image name
                # print(im.filename.split('\\')[-1], " is resized")
    
    def generate_video(self, video_name):
        imageFolder = self.imagePath + '/cropped_faces'
        # os.chdir(imageFolder)
    
        images = [img for img in os.listdir(imageFolder)
                  if img.endswith(".jpg") or
                     img.endswith(".jpeg") or
                     img.endswith("png")] 
    
        sorted_images = natsort.natsorted(images,reverse=False)
    
        frame = cv2.imread(os.path.join(imageFolder, sorted_images[0]))
    
        # setting the frame width, height width 
        # the width, height of first image 
        height, width, layers = frame.shape
        fourcc = cv2.VideoWriter_fourcc(*'MP4V')
        video = cv2.VideoWriter(imageFolder + '/' + video_name, fourcc, 30.0, (width, height))
    
        # Appending the images to the video one by one 
        for image in sorted_images:  
            video.write(cv2.imread(os.path.join(imageFolder, image)))
    
        # Deallocating memories taken for window creation 
        cv2.destroyAllWindows()  
        video.release()  # releasing the video generated
        # print(video_name + ' created')

    def get_video_adress(self):
        return self.imagePath + '/cropped_faces/' + self.filename

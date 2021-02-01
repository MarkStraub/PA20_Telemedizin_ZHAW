import falcon.asgi as falcon
import wrist
import face
import call_matlab as cm
import os
import database.connect as dbCon


db = dbCon.connect()
dir_path = os.path.dirname(os.path.realpath(__file__))
app = falcon.App()
matlab = cm.Matlab()
app.add_static_route('/face/result', dir_path+'/tmp/face/results/', False)
app.add_route('/face', face.FaceResource(matlab, db))
app.add_route('/wrist', wrist.WristResource())

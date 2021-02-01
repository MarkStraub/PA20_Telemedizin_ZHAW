import json
import falcon
import os
import uuid
import time
import database.face as faceDb


class FaceResource(object):
    dir_path = os.path.dirname(os.path.realpath(__file__))
    path = os.path.join(dir_path, "tmp/face")

    def __init__(self, matlab, db):
        self.matlab = matlab
        self.faceDb = faceDb.FaceDb(db)

    '''
    def run_get_pulse(self, req, resp):
        filepath = os.path.join(self.path, resp.id)
        self.matlab.pulse_of_face(self.path, filepath + '.mp4')
    '''

    async def on_get(self, req, resp):
        resp.status = falcon.HTTP_200
        resp.content_type = 'appropriate/content-type'
        filename = self.path + '/results/' + 'output.mp4'
        with open(filename, 'r') as f:
            resp.body = f.read()

    # @falcon.after(run_get_pulse)
    async def on_post(self, req, resp):
        start = time.time()
        form = await req.get_media()
        async for part in form:
            if part.name == 'datafile':
                if not os.path.exists(self.path):
                    try:
                        os.makedirs(self.path)
                    except OSError:
                        print("Creation of the directory %s failed" % self.path)
                    else:
                        print("Successfully created the directory %s " % self.path)
                id = uuid.uuid4()
                filename = str(id) + part.secure_filename[-4:]
                print(filename)
                async for chunk in part.stream:
                    # create file with data
                    filepath = os.path.join(self.path, filename)
                    try:
                        f = open(filepath, "xb")
                    except:
                        # is called when file exists
                        f = open(filepath, "ab")
                    finally:
                        f.write(chunk)
                        f.close()
                values, hist, pulse = self.matlab.pulse_of_face(self.path, filename)
                status = falcon.HTTP_201
                body = json.dumps({"id": str(id), "time": time.time() - start, "pulse": pulse, "hist": hist, "values": values, "success": True})
            else:
                # Do something else
                body = json.dumps({"success": False})
                status = falcon.HTTP_401
        resp.body = body
        resp.status = status


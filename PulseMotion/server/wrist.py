import json
import falcon
import os
import uuid


class WristResource:
    wrist = [{"id": 1, "name": "Company One"}, {"id": 2, "name": "Company Two"}]

    dir_path = os.path.dirname(os.path.realpath(__file__))
    path = os.path.join(dir_path, "tmp/wrist")

    async def on_get(self, req, resp):
        resp.body = json.dumps(self.wrist)

    async def on_post(self, req, resp):
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
                filename = str(id) + part.secure_filename

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

                status = falcon.HTTP_201
                body = json.dumps({"id": str(id), "success": True})
            else:
                # Do something else
                body = json.dumps({"success": False})
                status = falcon.HTTP_400
        resp.body = body
        resp.status = status
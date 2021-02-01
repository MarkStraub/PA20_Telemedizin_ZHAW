import matlab.engine
import os
import videoamplification.face_amplification as fa
import videoamplification.faceDetection.faceD as faD

class Matlab:
    def __init__(self):
        self.eng = self.initialize_matlab()
        self.fd = faD.FaceD()

    def pulse_of_face(self, path, filename):
        print('pulse of face')
        return fa.face_amplification(self.eng, self.fd, path, filename)
        # self.eng.reproduceResultsSiggraph13(nargout=0)

    def initialize_matlab(self):
        print('start engine...')
        eng = matlab.engine.start_matlab()
        print('started engine')
        path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "matlabcode")
        eng.cd(path)
        eng.setPath(nargout=0)
        return eng

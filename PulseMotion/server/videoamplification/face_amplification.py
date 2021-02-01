import os
import cv2
import ffmpy
import videoamplification.phaseBased.pulse as pulse
import videoamplification.phaseBased.phaseAmplify as pA
import videoamplification.phaseBased.phaseMagnification as pM


def face_amplification_old(eng, path, filename):
    print('face amplification started')
    loCutoff = 0.04
    hiCutoff = 0.4
    # temporalFilter = eng.@differenceOfIIR
    alpha = 20.0
    sigma = 5.0
    pyrType = 'quarterOctave'
    resultsDir = os.path.join(path, "results")
    fileDir = os.path.join(path, filename)
    print('everything ready')
    eng.phaseAmplify(fileDir, alpha, loCutoff, hiCutoff, 1.0, resultsDir, 'sigma', sigma, 'pyrType', pyrType, 'scaleVideo', 0.8)


def face_amplification(eng, fd, path, filename):

    status = 20
    fileChangeDir = '../../tmp/face/' + filename
    resultsDir = os.path.join(path, "results")

    motionDir = os.path.join(path, "motionAttenuateFixedPhase")
    motAttFile = os.path.join(motionDir, filename[0:-4])
    motAttFile = motAttFile + '.avi'
    # avi to mp4
    print('im here')
    fd.start(path, filename)
    face_detected_video = fd.get_video_adress()

    '''
    try:
        pA.start_amplification(face_detected_video, resultsDir + '/' + filename)
    except Exception as e:
        print(e)
    
    try:
        pM.run_amplification(face_detected_video, resultsDir + '/' + filename)
    except Exception as e:
        print(e)
    '''
    status = 40
    eng.motionAttenuateFixedPhase(face_detected_video, motAttFile, nargout=0)
    status = 80
    resultFile = resultsDir + '/' + filename
    eng.amplify_spatial_Gdown_temporal_ideal(motAttFile, resultsDir + '/' + filename[0:-4], 100.0, 4.0, 50.0/60.0, 60.0/60.0, 30.0, 1.0, nargout=0)

    try:
        cap = cv2.VideoCapture(resultFile[0:-4] + '.avi')
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        fps = int(cap.get(cv2.CAP_PROP_FPS))
        fh = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fw = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        print(resultFile)
        out = cv2.VideoWriter(resultFile, fourcc, fps, (fh, fw))
        while cap.isOpened():
            ret, frame = cap.read()
            if ret:
                # write the flipped frame
                out.write(frame)
            else:
                break

            # Release everything if job is finished
        cap.release()
        out.release()
    except Exception as e:
        print(e)

    # print(pulse.pulse_of_video(resultsDir + '/4a0ede6d-a2b9-489f-93f9-5c8032433100.mp4'))
    return pulse.pulse_of_video(resultFile)
    status = 100



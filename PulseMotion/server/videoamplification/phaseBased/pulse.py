import cv2
import statistics


def pulse_of_video(video_name):
    vidReader = cv2.VideoCapture(video_name)
    framesCount = int(vidReader.get(cv2.CAP_PROP_FRAME_COUNT))
    fps = int(vidReader.get(cv2.CAP_PROP_FPS))
    values = histogram(vidReader)
    pulse = get_pulse(values, framesCount, fps)
    hist = transform_data(values)
    return values, hist, pulse


def histogram(vid_reader):
    vidReader = vid_reader
    values = []
    while vidReader.isOpened():
        ret, frame = vidReader.read()
        if ret:
            average = frame.mean(axis=0).mean(axis=0)
            # print(average)
            values.append(average[0])
        else:
            break
    return values


def get_pulse(data, fc, fps):
    # find first pik
    count = 0
    searchTop = True
    median = statistics.mean(data)
    start = -1
    for i in range(0, len(data) - 3):
        if searchTop:
            if is_pik_top(data[i], data[i+1], data[i+2]) and data[i+1] > median:
                if start < 0:
                    start = i
                searchTop = False
                count = count + 1
        else:
            if is_pik_bottom(data[i], data[i + 1], data[i + 2]) and data[i+1] < median:
                searchTop = True
                end = i
    fc = end - start
    seconds = fc / fps
    print(median)
    if not searchTop:
        count = count - 1
    print(seconds)
    return count * (60 / seconds)


def is_pik_top(a, b, c):
    if a < b and b > c:
        return True
    else:
        return False


def is_pik_bottom(a, b, c):
    if a > b and b < c:
        return True
    else:
        return False


def transform_data(data):
    # find highest and lowest value
    lowest = min(data)
    highest = max(data) - lowest
    values = []
    for element in data:
        values.append((element - lowest) / highest * 50)
    return values

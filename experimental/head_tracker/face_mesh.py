import cv2
import mediapipe as mp
import socket
import threading
import queue
import json
import operator 
import numpy as np 


def vec_from_points(A, B):
  v = list(map(operator.sub, A, B))
  return v
def get_head_orientation():
    coordinates = face_landmarks.landmark
    x = []
    y = []
    z = []
    row = []
    pitch = []
    yaw = []
    points = [50, 110, 220]
    for k in points:
      x.append(coordinates[k].x)
      y.append(coordinates[k].y)
      z.append(coordinates[k].z)  

    return [x, y, z]


def send_to_server():
   coords = json.dumps(get_head_orientation(), ensure_ascii=False).encode()
   conn.send(coords) #send message back


# TPC waiting for message
def receive_from_server():
  global conn, thread_is_empty, initialization_flag
  
  if initialization_flag is True:
      conn = q.get()
      initialization_flag = False
  message = conn.recv(1024) # this stops and waits for message
  # print(message) 
  send_to_server() # the recv() triggers the calculation of current head orientation
  thread_is_empty = True

# TCP SERVER
def initialize_server():
  global conn
  HOST = ''                 # Symbolic name meaning all available interfaces
  PORT = 50050              # Arbitrary non-privileged port
  s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  s.bind((HOST, PORT))
  s.listen(1)
  conn, addr = s.accept()
  print('Connected!')  
  q.put(conn)


# MediaPipe FaceMesh
def processing():
  # Initialize TCP server
  global q, thread_is_empty, initialization_flag, face_landmarks
  q = queue.Queue()
  t1 = threading.Thread(target=initialize_server)
  t1.daemon = True
  t1.start()

  #  general flags
  thread_is_empty = True # flag for receiving messages
  initialization_flag = True # first run


  # MediaPipe itself
  mp_face_mesh = mp.solutions.face_mesh
  mp_drawing = mp.solutions.drawing_utils
  with mp_face_mesh.FaceMesh(
              min_detection_confidence=0.5,
              min_tracking_confidence=0.5) as face_mesh:
    cap =  cv2.VideoCapture(0)      
    while cap.isOpened():
      success, image = cap.read()
      if not success:
        print("Ignoring empty camera frame.")
        # If loading a video, use 'break' instead of 'continue'.
        continue
    
      # For webcam input:
      drawing_spec = mp_drawing.DrawingSpec(thickness=1, circle_radius=1)

      # Flip the image horizontally for a later selfie-view display, and convert
      # the BGR image to RGB.
      image = cv2.cvtColor(cv2.flip(image, 1), cv2.COLOR_BGR2RGB)
      # To improve performance, optionally mark the image as not writeable to
      # pass by reference.
      image.flags.writeable = False
      results = face_mesh.process(image)

      # Draw the face mesh annotations on the image.
      image.flags.writeable = True
      image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
      if results.multi_face_landmarks:
        for face_landmarks in results.multi_face_landmarks:
          mp_drawing.draw_landmarks(
              image=image,
              landmark_list=face_landmarks,
              connections=mp_face_mesh.FACE_CONNECTIONS,
              landmark_drawing_spec=drawing_spec,
              connection_drawing_spec=drawing_spec)

      # Open window: show image
      cv2.imshow('MediaPipe FaceMesh', image)

      if cv2.waitKey(5) & 0xFF == 27:
          break

      # Kill it when you press quit window
      if cv2.getWindowProperty('MediaPipe FaceMesh',cv2.WND_PROP_VISIBLE) < 1: 
          print('Goodbye!')      
          # kill tcp connection
          # conn.close() 
          cv2.destroyAllWindows()
          cap.release() 
          

      # Listening to ports
      if thread_is_empty:
        t2 = threading.Thread(target=receive_from_server)
        t2.daemon = True
        t2.start()
        thread_is_empty = False
  



if __name__ == "__main__":
    # Create the event loop.
    processing()
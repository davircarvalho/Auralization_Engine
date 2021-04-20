
import cv2
import mediapipe as mp
import socket
import threading
import queue
import os

def initialize_server():
  HOST = ''                 # Symbolic name meaning all available interfaces
  PORT = 50007              # Arbitrary non-privileged port
  s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  s.bind((HOST, PORT))
  s.listen(1)
  conn, addr = s.accept()
  print('Connected!')  
  q.put(conn)

def receive_from_server():
  global conn, initialization_flag
  if initialization_flag:
      conn = q.get()
      initialization_flag = False
  message = conn.recv(1024)
  conn.sendall(message)
  print(str(message))

def processing():
  global q
  # Initialize server program
  q = queue.Queue()
  t1 = threading.Thread(target=initialize_server)
  t1.start()

  global initialization_flag
  initialization_flag = True

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


      # Open window
      cv2.imshow('MediaPipe FaceMesh', image)

      if cv2.waitKey(5) & 0xFF == 27:
          break

      # Kill it when you press quit window
      if cv2.getWindowProperty('MediaPipe FaceMesh',cv2.WND_PROP_VISIBLE) < 1: 
          print('Goodbye!')       
          cv2.destroyAllWindows()
          cap.release() 
          conn.close()
          # kill threads
          t1.terminate()
          t2.terminate()

      # Listening to ports
      t2 = threading.Thread(target=receive_from_server)
      t2.start()
      # send data to the server
      # if conn.recv(1024):
      #    print(conn.recv(1024))
      # if matlab_request:
      #    conn.sendall(matlab_request)
      # else:
      #   continue
  conn.close()



if __name__ == "__main__":
    # Create the event loop.
    processing()
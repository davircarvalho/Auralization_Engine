"""

Thanks to https://github.com/Rassibassi/mediapipeFacegeometryPython 
for solving the head orientation from face_mesh landmarks! 

"""

import cv2
import mediapipe as mp
import numpy as np 
from face_geometry import get_metric_landmarks, PCF, canonical_metric_landmarks, procrustes_landmark_basis


def get_head_orientation(rvec, tvec):
    rmat = cv2.Rodrigues(rvec)[0]
    # projection matrix
    P = np.hstack((rmat,tvec))

    # find euler angles 
    euler_angles =  cv2.decomposeProjectionMatrix(P)[6]
    pitch = -euler_angles.item(0) # roll
    yaw = -euler_angles.item(1) # azimuth
    row = -euler_angles.item(2) # azimuth
    print('yaw: ', yaw)
    return yaw





points_idx = [33,263,61,291,199]
points_idx = points_idx + [key for (key,val) in procrustes_landmark_basis]
points_idx = list(set(points_idx))
points_idx.sort()


frame_height, frame_width, channels = (480, 640, 3)

# pseudo camera internals
focal_length = frame_width
center = (frame_width/2, frame_height/2)
camera_matrix = np.array(
                         [[focal_length, 0, center[0]],
                         [0, focal_length, center[1]],
                         [0, 0, 1]], dtype = "double"
                         )

dist_coeff = np.zeros((4, 1))

pcf = PCF(near=1,far=10000,frame_height=frame_height,frame_width=frame_width,fy=camera_matrix[1,1])


# MediaPipe itself
mp_face_mesh = mp.solutions.face_mesh
mp_drawing = mp.solutions.drawing_utils
with mp_face_mesh.FaceMesh(
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5) as face_mesh:
  cap =  cv2.VideoCapture(0) 
  cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
  cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
  cap.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter_fourcc(*'MJPG'))
  cap.set(cv2.CAP_PROP_FPS, 30)

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
      face_landmarks = results.multi_face_landmarks[0]
      landmarks = np.array([(lm.x,lm.y,lm.z) for lm in face_landmarks.landmark])
      landmarks = landmarks.T

      metric_landmarks, pose_transform_mat = get_metric_landmarks(landmarks.copy(), pcf)
      model_points = metric_landmarks[0:3, points_idx].T
      image_points = landmarks[0:2, points_idx].T * np.array([frame_width, frame_height])[None,:]

      success, rotation_vector, translation_vector = cv2.solvePnP(model_points, image_points, camera_matrix, dist_coeff, flags=cv2.cv2.SOLVEPNP_ITERATIVE) 
      # ROLL, PITCH and YAW
      yaw = get_head_orientation(rotation_vector, translation_vector)

      (nose_end_point2D, jacobian) = cv2.projectPoints(np.array([(0.0, 0.0, 25.0)]), rotation_vector, translation_vector, camera_matrix, dist_coeff)
      

      for ii in points_idx: # range(landmarks.shape[1]):
          pos = np.array((frame_width*landmarks[0, ii], frame_height*landmarks[1, ii])).astype(np.int32)
          image = cv2.circle(image, tuple(pos), 1, (0, 255, 0), -1)

          p1 = ( int(image_points[0][0]), int(image_points[0][1]))
          p2 = ( int(nose_end_point2D[0][0][0]), int(nose_end_point2D[0][0][1]))

          image = cv2.line(image, p1, p2, (0,0,155), 2)


    # Open window: show image
    cv2.imshow('Head tracker', image)

    if cv2.waitKey(5) & 0xFF == 27:
        break

    # Kill it when you press quit window
    if cv2.getWindowProperty('Head tracker',cv2.WND_PROP_VISIBLE) < 1: 
        print('Goodbye!')      
        cv2.destroyAllWindows()
        cap.release() 
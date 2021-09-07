# Auralization Engine

<p align="left">
  <a href="https://github.com/davircarvalho/Auralization_Engine/commits/master" target="_blank">
    <img src="https://img.shields.io/github/last-commit/davircarvalho/Auralization_Engine?style=flat-square" alt="GitHub last commit">
  </a>

  <a href="https://github.com/davircarvalho/Auralization_Engine/issues" target="_blank">
    <img src="https://img.shields.io/github/issues/davircarvalho/Auralization_Engine?style=flat-square&color=red" alt="GitHub issues">
  </a>

</p>
<hr>


Matlab app designed to create virtual auditory scenes using SOFA HRTFs and *n*-channels wav signals.

>**Built with Matlab r2021a**, if you're using earlier versions, some functionalities might be missing or it might not work as desired.

## Install
At the **APP** tab in MATLAB, select *install app*, then pick the file <**Auralization_Engine.mlappinstall**> and click *install*!

That's it, the app will show on your installed apps list now! Have fun!


## Main features

- **Arbitrary sound source position variation in real time**;

- **Support to SOFA [SimpleFreeFieldHRIR](https://www.sofaconventions.org/mediawiki/index.php/SimpleFreeFieldHRIR) and [MultiSpeakerBRIR](https://www.sofaconventions.org/mediawiki/index.php/MultiSpeakerBRIR) SOFA conventions;** ;

- **Headphone transfer functions** (HpTF) filter correction (2 channels .wav file) or selection from the built-in [AutoEQ](https://github.com/jaakkopasanen/AutoEq) database;

- **Source distance variation** according to the cross-ear parallax effect, energy decay with source distance and air attenuation as a function of frequency (according to ISO 9613-1), pressure decay via the inverse law or via HRTF equalization (spherical head model);

- **Head Tracker via webcam face tracking**: Model presented at the [2021 Internoise](https://github.com/eac-ufsm/internoise2021-headtracker) conference;

- **Multi-perspective view**, (Azimuth x Elevation) or (Azimuth x Radius).


## Folder structure

- ```src/``` : Contains the source files required to build the app from scratch;

- ```experimental/``` : Contains features under development there are not necessarily already implemented to the app itself. Currently you can find an implementation of webcam head tracker based on the google's mediapipe face mesh in python, but ready to connect to matlab via local UDP/IP protocol, as indicated in the test scripts. For more information about the Head Tracker go [here](https://github.com/eac-ufsm/internoise2021-headtracker).


## Planned features

- *Offline* high resolution interpolation using spherical harmonics;

- Real time interpolation;

- Assembly of the *n*-channels audio file from *n* individual wav files inside the app.

  *Feel free to leave your suggestions!* 



## Interface 

<p align="center">
<img width="800px" src="https://github.com/davircarvalho/Auralization_Engine/blob/master/Images/2.PNG"/>
</p>

<p align="center">
<img width="800px" src="https://github.com/davircarvalho/Auralization_Engine/blob/master/Images/1.PNG"/>
</p>

<p align="center">
<img width="800px" src="https://github.com/davircarvalho/Auralization_Engine/blob/master/Images/3.PNG"/>
</p>

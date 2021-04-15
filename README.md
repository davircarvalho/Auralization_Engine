# Auralization Engine

<p align="left">
  <a href="https://github.com/davircarvalho/Auralization_Engine/releases/" target="_blank">
    <img alt="GitHub release" src="https://img.shields.io/github/v/release/davircarvalho/Auralization_Engine?include_prereleases&style=flat-square">
  </a>

  <a href="https://github.com/davircarvalho/Auralization_Engine/commits/master" target="_blank">
    <img src="https://img.shields.io/github/last-commit/davircarvalho/Auralization_Engine?style=flat-square" alt="GitHub last commit">
  </a>

  <a href="https://github.com/davircarvalho/Auralization_Engine/issues" target="_blank">
    <img src="https://img.shields.io/github/issues/davircarvalho/Auralization_Engine?style=flat-square&color=red" alt="GitHub issues">
  </a>

  <a href="https://github.com/davircarvalho/Auralization_Engine/blob/master/LICENSE" target="_blank">
    <img alt="LICENSE" src="https://img.shields.io/github/license/davircarvalho/Auralization_Engine?style=flat-square&color=yellow">
  <a/>

</p>
<hr>


Matlab app designed to create virtual auditory scenes using SOFA HRTFs and *n*-channels wav signals.

>**Built with Matlab r2020b**

## Install
At the **APP** tab in MATLAB, select *install app*, then pick the file <**Auralization_Engine.mlappinstall**> and click *install*!

That's it, the app will show on your installed apps list now! Have fun!


## Main features

- **Source position variation in real time** (according to the azimuths and elevations measured in the HRTF file);

- **Support to SOFA HRTFs** (check the SimpleFreeFieldHRIR SOFA conventions);

- **Headphone transfer functions** (HpTF) filter correction (2 channels .wav file);

- **Source distance variation** according to the parallax effect (adapted from the SUpDEq toolbox), energy decay with source distance and air attenuation as a function of frequency (according to ISO 9613-1).

## Planned features

- Head tracking via webcam and generic head tracker support;

- *Offline* high resolution interpolation using spherical harmonics ;

- Real time Vector Based Amplitude Panning (VBAP) interpolation;

- Assembly of the *n*-channels audio file from *n* individual wav files.

  *Feel free to leave your suggestions!* 

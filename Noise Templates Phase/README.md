# Photo Response Non-Uniformity based Smartphone Sensor De-identification 

This is a MATLAB R2018a implementation of Photo Response Non-Uniformity (PRNU) based sensor de-identification while preserving biometric utility, as described in our paper:
 
Banerjee and Ross, "Smartphone Camera De-identification while Preserving Biometric Utility," BTAS 2019 (https://arxiv.org/pdf/2009.08511.pdf)

Take a look at our video for a short demo: (http://iprobe.cse.msu.edu/videos.php) 

## Requirements
* MATLAB R2018a
* Deep Learning Toolbox (for periocular recognition, if DL toolbox is not available please comment lines 75-94 in
Demo\_Anonymization.m and lines 101-120 in Demo_Spoofing.m) 

## Folder organization

* `Example_TestImages` contains 3 example test images from MICHE-I dataset. Please contact the authors
for permission if using MICHE-I images. 

010\_IP5\_OU\_F\_RI\_01\_2.jpg -  Subject Id: 10 Device ID: IP5 (iPhone 5 Device 1) Acquisition settings: OU (Outdoor)
Camera used: F (Front camera) Laterality: RI (Right eye) Session: 01 Sample number: 2

066\_IP5\_IN\_F\_RI\_01\_3.jpg - Subject Id: 66 Device ID: IP5 (iPhone 5 Device 2) Acquisition settings: IN (Indoor)
Camera used: F (Front camera) Laterality: RI (Right eye) Session: 01 Sample number: 1

072\_GS4\_OU\_F\_RI\_01\_3.jpg - Subject Id: 72 Device ID: GS4 (Samsung Galaxy S4) Acquisition settings: OU (Outdoor)
Camera used: F (Front camera) Laterality: RI (Right eye) Session: 01 Sample number: 3


* `Filter` and `Functions` contains C++ compiled files for Sensor Pattern Noise (SPN)- PRNU computation from images
(http://dde.binghamton.edu/download/camera_fingerprint/)

* `Noise Templates Enhanced`, `Noise Templates MLE` and `Noise Templates Phase` contain some of the sensor reference patterns used in this work (Rear sensors
have larger sized reference patterns you can add them for evaluation, change the following scripts if you insert/delete reference patterns: `NCC_Computation_MLE.m`, `NCC_Computation_Enhanced.m`, `NCC_Computation_Phase.m` and `DispSensor.m`)

## Run the demo

* For PRNU Anonymization
```bash
Demo_Anonymization.m
```
* For PRNU Spoofing
```bash
Demo_Spoofing.m
```
For Spoofing use the same sensor for both test
image (**F**.jpg) and candidate image (**F**.jpg) (Front-Front spoofing,
Rear-Rear spoofing but no cross spoofing such as Front-Rear OR
Rear-Front).

## Helper functions (Read the comments included in individual helper functions for better understanding)

* DispSensor.m : Displays the sensor name as evaluated usign the SPN
classifier 

* getFingerprint\_monochrome.m : Used for computing sensor
reference patterns. Please refer to
http://dde.binghamton.edu/download/camera_fingerprint/ for more details

* NCC\_Computation\_Enhanced.m : Correlates sensor reference patterns
with test noise residuals for Enhanced SPN 

* NCC\_Computation\_MLE.m :
Correlates sensor reference patterns with test noise residuals for MLE
SPN 

* NCC\_Computation\_Phase.m : Correlates sensor reference patterns
with test noise residuals for Phase SPN 

* NoiseExtract\_Basic.m :
Sensor pattern noise extraction used in computing Sensor Reference
pattern for Enhanced SPN and test noise residual for Phase SPN

* NoiseExtractFromImage\_Enhanced, NoiseExtract\_Enhanced.m : Sensor
pattern noise extraction used in computing test noise residual for
Enhanced SPN 

* NoiseExtractFromImage\_MLE, NoiseExtract\_MLE.m : Sensor
pattern noise extraction used in computing Sensor Reference pattern for
MLE SPN and test noise residual for MLE SPN

* NoiseExtractFromImage\_Phase, NoiseExtract\_Phase.m : Sensor pattern
noise extraction used in computing Sensor Reference pattern for Phase
SPN 

* normcor.m : Computes the normalized cross correlation

## Notes

* Examples illustrated using images located in
Example\_TestImages folder. Please substitute with other images as
needed

* Hyperparameter alpha tuned using validation images on MICHE-I
dataset. Please fine tune the hyperparameter as needed

* The scripts provide the computation time, the sensor classification result before
and after sensor de-identification as evaluated using 3 algorithms -
Phase SPN, Enhanced SPN and MLE SPN, and the images before and after
sensor de-identification 

* Periocular matching is done using
off-the-shelf features from ResNet 101. ROC curves should be computed
using the scores


## Cite

Please cite our paper if you use this code in your own work:

```
@inproceedings{BTAS2019_PRNUDeid,
  title={Smartphone Camera De-identification while Preserving Biometric Utility},
  author={Banerjee, Sudipta and Ross, Arun},
  booktitle={IEEE 10th International Conference on Biometrics Theory, Applications and Systems (BTAS)},
  year={2019}
}
```


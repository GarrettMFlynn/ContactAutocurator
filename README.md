# ContactAutocurator
Code to train and deploy neural network models to curate whisker touch data

[![Hires Lab](https://github.com/jonathansy/whisker-autocurator/blob/master/Resources/Images/HiresLab-logoM.png)](http://68.181.113.239:8080//hireslabwiki/index.php?title=Main_Page)

[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)

## Introduction
ContactAutocurator is a pipeline for curating contact data using a convolutional neural network (CNN). It was originally designed to work on videos of mice touching a pole, however it can likely be generalized to other kinds of contacts. It was developed in conjunction with the Janelia Farm whisker tracker, however, the whisker tracking is used strictly for preprocessing and not necessary for autocuration to occur. The code base contains several pre-trained CNN models as well as a pipeline to easily implement autocuration in MATLAB. For best results on different types of video data, it is preferable to train a new model from manually curated data. As such, a training pipeline is included to create custom CNN models from labeled images. 

Currently the pipeline only supports MATLAB, however intermediary steps call Python code utilizing numpy arrays. A Python-only pipeline is thus possible, but would require rewriting the preprocessing and post-processing steps. One can also feed the numpy arrays generated by the autocurator into a custom Python dataset. 

The convolutional neural networks are designed to be trained and deployed on the cloud. While nothing about the model training and deployment code are platform-limiting, the pipeline was written to use Google Cloud Platform (CloudML) and the installation instructions will contain a brief guide to setting up a Google Cloud Platform account. If you have access to a CUDA-enabled GPU, local versions of the neural network code are included but it is highly recommended that they are not used without a GPU. 


## Installation 
The cloud training and curation scripts in this account have all been written for Google Cloud Platform's cloud ML API. While training and curation can be done on a local drive it is highly recommended not to attempt this without a CUDA-enabled GPU. Before running a program on ContactAutocurator, please ensure all of the dependencies from the [list](#dependencies) below are installed (with the exception of Google cloud items if you do not intend to train on the cloud). See [Cloud ML Setup](#cloud-ml-setup) for specific instructions on creating a Google Cloud Platform account. 

After downloading ContactAutocurator, one should first run [install_from_matlab.m](https://github.com/jonathansy/ContactAutocurator/blob/master/install_from_matlab.m). This will automatically add ContactAutocurator's code to the MATLAB path as well as run an installation check for Python and the cloud SDK package. Once this is done, the installer will open cloud_config.m. You should fill in the information on cloud_config.m based on the directory structure you set up on your cloud storage bucket (Refer to Cloud ML Setup) as well as general cloud settings. The settings on cloud_config.m generally do not need to be changed regardless of the type of job you submit to the cloud. If you do not intend to use Cloud ML for curation or training new models, you can ignore this file. 

ContactAutocurator was originally written to be used with the [Janelia Farm Whisker Tracker](https://wiki.janelia.org/wiki/display/MyersLab/Whisker+Tracking+Downloads). More specifically, it uses whisker tracking information for preprocessing data and speeding up curation by skipping frames where the answer is "obvious". This preprocessing is not necessary to use ContactAutocurator, but it is an effective way of speeding up curation of contacts when they involve a mouse whisker. 

Once all dependencies have been installed and all code is on the MATLAB path, the only settings left to set are those on the autocurator and model training pipelines. See the [usage](#usage) section for more information on each individual pipeline. 

### Dependencies
* [Python 3.5 or higher](https://www.python.org/downloads/) (compatibility not tested with 2.7)  
  - Numpy package  
  - Pickle package  
  - Scipy package
* [Google Cloud SDK package](https://cloud.google.com/sdk/)
* MATLAB r2013b or later
  - [npy-matlab](https://github.com/kwikteam/npy-matlab)
* Google Cloud Platform Account



### Recommended
* [Janelia Farm Whisker Tracker](https://wiki.janelia.org/wiki/display/MyersLab/Whisker+Tracking+Downloads) (all distance-to-pole preprocessing assumes you have it)

* MATLAB Packages (for Hires Lab members)
  - [HLab_MatlabTools](https://github.com/hireslab/HLab_MatlabTools)  
  - [HLab_Whiskers](https://github.com/hireslab/HLab_Whiskers)



## Google Cloud Platform and Cloud ML Setup
### Account Setup
To run model training and curation jobs on the cloud, you will need a Google Cloud Platform account. You can associate this account with any existing Google account/Google email address although some university accounts may limit access to these tools. As of the time this documentation was written, creation of a new Google Cloud Platform account will comes with $300 of free credit, enough for approximately 111 hours of GPU time on an Nvidia Tesla P100. A major of benefit of the cloud ML API is that you will only be billed while a training or curation job is running, where-as you would be billed for virtual machine setup for using neural networks the entire time it is operational, even if no operations are running. Other than the billing for cloud ML, you will be charged for use of a Google Cloud storage bucket, however these charges should be negligible unless your data enters the range of hundreds of terabytes.

The Cloud ML API will not be enabled by default, you will need to enable it for your particular project. The Cloud ML menu is found under the "Artificial Intelligence" header in the navigation menu on the left. When enabled, the interface will allow you to see any training/curation jobs that have been run (under "jobs") and any models hosted on Cloud ML (ContactAutocurator does not currently make use of this feature). 

### Storage Bucket Setup
If you intend to use the cloud curation scripts in this package, you will first need to setup a consistent directory structure within a Google Cloud Bucket. Buckets are a form of cloud data storage. Information about creating and using them can be found [here](https://cloud.google.com/storage/docs/creating-buckets). After creating a cloud storage bucket for your training jobs, you should create the following directories:
/Jobs for storing output logs from curation
/Data for importing uncurated image data 
/Curated_Data for placing curated labels for export 
/Model_Saves for placing the model(s) you wish to use for curation.

Cloud storage buckets begin with the prefix gs://, for example gs://my_bucket/Data. Make sure all relevant cloud paths are set within [autocurator_master_function.m](https://github.com/jonathansy/whisker-autocurator/blob/master/Autocurator_Beta/autocurator_master_function.m). Cloud storage buckets do not have the same functionality as local drives and thus will not display their properties or index files. They also require the File_IO package to index on Python (included with Tensorflow). 

Submitting training jobs to CloudML do not require manually setting up virtual machines on Google's cloud console. You will have to specify certain settings for the curation environment when you submit a job to the cloud. These are handled via  the 'gcloud ml-engine jobs submit' command as well as a .yaml file included in the local directory. Important variables to specify are the type of GPU (if any) to use, the runtime environment, and the [region](https://cloud.google.com/compute/docs/regions-zones/) (note that only certain regions support GPU use). 

### Interface Setup
Your local computer interfaces with Google Cloud Platform via the Cloud SDK package. While it has its own shell, you can run the commands on a normal command window. To login to your account, type
```
gcloud auth login
``` 
which should open a page on Chrome asking you to select which Google Account to login in to on Cloud SDK. Note that the login persists even if the command window is closed and operates independently of which account you are actually logged into on Chrome. After loggin in, you will also need to set a project on Cloud SDK. to do this type
```
gcloud config set project name-of-your-project-here
```
Note that you will need to type your project ID, which can be different from the actual name of your project (typically all lowercase with dashes replacing any spaces between words). The ID name for your project is shown to the right of the actual name under the "Select a project" dropdown on the Google Cloud Platform console. Like with account logins, this will persist even after the command window is closed. 

## Local Drive Setup 
Autocurator_Beta, HLab_MatlabTools, HLab_Whiskers, and npy-matlab should all be cloned to the local Github location and added to the MATLAB path. Python should be installed. Once Python is installed, use pip to install the other packages on the command line (exact syntax for using pip may vary with your version of Python). Install Google Cloud SDK and make sure its commands can be run from the command line prompt. 

Within Autocurator_Beta, make sure you have a subdirectory called 'trainer' (you can rename it but you will need to change the pathing in 'autocurator_master_function.m'. Within this subdirectory you should have cnn_curator_cloud.py, the .yaml file you are using as a configuration file (default/example included in this package), and \_\_init\_\_.py (which is an empty Python file but required for operation). 

You should designate a directory on your local drive to save .npy files as well as a location to save the final curated datasets. 

## Usage

ContactAutocurator is a pipeline and neural network model designed to read a session of videos and determine the contact times in those videos. It was designed to determine when a mouse whisker is touching a pole, but the pipeline itself should be generalizable for other types of tactile contacts. With that in mind (and because video data can vary dramatically based on the experiment), the ContactAutocurator code contains two main pipelines. One is to train a new convolutional neural network model with pre-curated training data. The other pipeline will curate new data based on a selected model. 

Because the pipelines were developed with whisker curation in mind, they assume that you have the Janelia Farm Whisker tracker or a similar method of pre-tracking as well as a method of cropping videos to the regions where contacts are occuring (while not strictly necessary, this dramatically lowers the size of the processed images, thus increasing speed and simplifying the necessary model). If you do not have the Janelia Farm Whisker tracker, you will either need to recode the pipeline for preprocessing (based on the contacts you want to detect) or disable preprocessing entirely. 

For more in depth reading on each pipeline see:
* [Model Training Pipeline](https://github.com/jonathansy/ContactAutocurator/blob/master/docs/Training_Pipeline_Documentation.md)
* [Autocurator Pipeline](https://github.com/jonathansy/ContactAutocurator/blob/master/docs/Autocurator_Documentation.md) 

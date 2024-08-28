# OldUnreal 227 Testing
This is the Unreal-testing repo for the 227 patch

## 1. Quick "How To GitHub" Guide:

### To Download the patch, click "Code", then **"Download ZIP"**:
 ![image](https://github.com/OldUnreal/Unreal-testing/assets/70912455/b9de6537-dcc0-44d8-80fd-28a6aeca7d47)

### To check for updates, click "commits", you will see a list of every update the repo has received, this list is updated automatically:
 ![image](https://github.com/OldUnreal/Unreal-testing/assets/70912455/abe61d59-b6a8-4242-98f8-12c4a90fd141)

### To access a previous version of the repo (to download an older version for bug testing or any other reason), click "commits", then this button on the version of the repo you wish to visit to access it:
![image](https://github.com/OldUnreal/Unreal-testing/assets/70912455/e67bbeb7-25ff-4f36-b079-8a4c41462b66)

## 2. Installing the Patch

 To install the patch, have an Unreal install ready

 Then, simply extract the contents of the ZIP you downloaded into your Unreal install folder and run the game

### If you're not using a clean install for the patch:
 **Delete or rename your Unreal.ini and User.ini files in System (Note: You will have to adjust your settings again)**

 **While not required, it is also recommended to delete all the old official localization files in System so that the new ones in SystemLocalized work**


## 3. Installing custom content

 If you plan on using the 64 bit client, any .u file goes into the default System folder, there's no need to put those in System64
 (Details about how this setup works are found in the Unreal.ini file in System64, look for "Paths")

 Localization files (such as .int files) can be put in System, but it is recommended to be put in the SystemLocalized folder instead to keep the System folder cleaner

 Settings files (such as .ini files) however, are required to be in the corresponding System or System64 folder to the client you're using

## 4. Reporting Issues

To report issues, it is recommended to do so on the github itself, by going to issues and clicking "New Issue":

![image](https://github.com/OldUnreal/Unreal-testing/assets/70912455/94046c6f-20aa-487f-a058-305691791110)

### Public source code can be found from this repo:
https://github.com/OldUnreal/Unreal-PubSrc

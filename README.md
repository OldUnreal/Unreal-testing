# OldUnreal 227 Testing
This is the Unreal-testing repo for the 227 patch

## 1. Quick "How To GitHub" Guide:

### Click on "Tags" under "Releases":
 <img width="338" height="149" alt="kuva" src="https://github.com/user-attachments/assets/35f59d6c-b147-4e15-8a59-58ba808df724" />

### Select the version you want to download, newest one is on the top:
 <img width="519" height="421" alt="kuva" src="https://github.com/user-attachments/assets/1c0aff74-f60a-4d92-b97a-ad73b1856880" />

### Scroll to bottom of page and select the OS you want to install on:
 <img width="378" height="255" alt="kuva" src="https://github.com/user-attachments/assets/00b7653e-e842-4507-80a8-fc328affd64e" />


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

### Localization files has been moved to this repo:
Use this one to commit updates to translation: https://github.com/OldUnreal/Unreal-Locale

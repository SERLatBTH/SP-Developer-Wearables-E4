Installation manual

Prerequisites: MacOS machine with Xcode installed, Empatica developer API key.

Clone or download the project from github.

Open the project with Xcode.

Go into the viewController file in the project and enter your API key.

Download the empatica e4link framework from their website.

Copy the framework into the project.

Connect your iphone to your computer with a USB cable.

Where you choose where to build the project choose your connected iphone.

Press the build button.

When the project has finished building the app will be installed on your iphone.

Known issues: For the app to properly detect the device the app must be launched through Xcode.
The device delegate methods do not get called, in other words the app cannot properly collect the
transmitted data, my hypothesis is that the empatica e4link sdk is a bit outdated and does not
properly support newer IOS versions.
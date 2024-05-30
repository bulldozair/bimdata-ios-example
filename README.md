# bimdata-ios-example
Sample Code on running the BIMData.io viewer in an iOS app

## Feature
iOS Sample for for view IFC files using the BIMData library.
- [x] Read IFC online
- [x] Read IFC offline

## Prerequesite
- Install Xcode.app
- Launch Xcode once and install required additional tools, with iOS Simulator
- Open `BIMDataViewer.xcodeproj`

## Testing
- Select a simulator in the middle area at the top, run with `Cmd+R` or `Product/Run` via menu, or the "Play button".

## Debugging
- If console is not visible once the app is running, you can show it with `View/Debug Area/Activate Console` and it should appear at the bottom.
- You can also debug with Safari.app. First activate Developer module in `Settings/Advanced/Activate developer mode`, then in the menu, `Development` and select the simulator.

## Usage
- You need, in your code to copy the viewer files (`html` & `js`) into the same folder of your IFC files to allow it access the files. You can use [`FileManager.copyItem(at:to:)`](https://developer.apple.com/documentation/foundation/filemanager/1412957-copyitem) to do so.
- If not, you need to use the Base64 version: Read IFC file with `Data` and convert it into Base64 string.

## Miscellaneous
Android Sample code with BIMData is available at [BIMData/Android-Example](https://github.com/bimdata/android-example/)

## License
BIMDataViewer is released under the MIT license. [See LICENSE](https://github.com/bulldozair/bimdata-ios-example/blob/master/LICENSE) for details.
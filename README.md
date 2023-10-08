# Customized Areal Screen Saver
<div style="width: 100%; text-align: center;">
  <img src="./docs/banner.png" />
</div>

## Overview
Since [macOS 14.0 Sonoma](https://www.apple.com/macos/sonoma/), Apple has brought Areal Screen Savers from tvOS to macOS, which provides stunning live screen savers when the device is locked.

However, it does not provide the ability to customize, so, here's a solution to that! With Customized Areal Screen Saver, you can add whatever the video you want for Areal Screen Saver!

## Usage
You'll need
- A .mov video
- A .jpg image for video preview

Upon launch the app, you must enter your password in order to modify system resources.
![](./docs/launch.png)

And click "Add Custom Areal Screen Saver", enter a name for the screen saver, then drag your video and preview image, click "Add" to add the customized screen saver
![](./docs/adding.png)

You can view and delete existing Areal Screen Savers in the app.
![](./docs/management.png)

A section "Customized Area" should appear in Screen Saver in System Settings.
![](./docs/settings.png)

Select it and enjoy!
![](./docs/preview.png)


## How does it work?

Given a password prompt exists in the app, regardless the app is open-sourced, a full disclosure is better than anything that you can do to earn everyone's trust, right?

The work behind the app is simple
All the areal screen saver assets are stored under `/Library/Application Support/com.apple.idleassetsd/`

Where videos are under `/Library/Application Support/com.apple.idleassetsd/Customer/4KSDR240FPS`

and preview images are under `/Library/Application Support/com.apple.idleassetsd/snapshots`

And there goes a JSON 
`/Library/Application Support/com.apple.idleassetsd/Customer/entries.json` which stores all areal screen saver's info

By modifying the JSON, you can add whatever you want as an Areal Screen saver, that's why you'll need to provide your password in order to modify these files.

## Known issues
- It may take some time for the screen saver to appear in the System Settings, since it will take some time for macOS to update Areal Screen Saver's data under `/Library/Application Support/com.apple.idleassetsd/Aerial.sqlite*`
  - I am working on how to trigger the update of the database, however I have no clue at the moment.

## Community is everything!
If you find this project useful and would like to support its development, you can
  - Create an issue https://github.com/FalconLee1011/Customized-Areal-Screen-Saver/issues 
  - Create an pull request https://github.com/FalconLee1011/Customized-Areal-Screen-Saver/pulls
  - Star this project
  - Spread happiness! Share the app!

If you really love this app or me, you can consider

<a href="https://www.buymeacoffee.com/xtli" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
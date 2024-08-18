# Isometrik Chat Flutter SDK

## iOS

### Make these changes to your `info.plist`

Path: `ios` > `Runner` > `info.plist`

```plist
<key>NSAppleMusicUsageDescription</key>
<string>This app needs access to your media</string>
<key>NSCameraUsageDescription</key>
<string>This app needs access to you camera</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to your location permisison</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to your location permisison</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location permisison</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access for microphone to record the audio</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photos usage</string>
<key>NSCameraUsageDescription</key>
<string>Used to demonstrate image picker plugin</string>
<key>NSMicrophoneUsageDescription</key>
<string>Used to capture audio for image picker plugin</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to demonstrate image picker plugin</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Used to demonstrate gal plugin</string>
<key>NSContactsUsageDescription</key>
<string>This app requires contacts access to function properly.</string>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
<key>UIFileSharingEnabled</key>
<true/>
<key>UIApplicationSupportsIndirectInputEvents</key>
  <true/>
  <key>UIBackgroundModes</key>
  <array>
   <string>fetch</string>
   <string>processing</string>
   <string>remote-notification</string>
  </array>
<key>LSApplicationQueriesSchemes</key>
  <array>
   <string>sms</string>
   <string>tel</string>
  </array>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
      <key>NSAllowsArbitraryLoadsForMedia</key>
    <true/>
</dict>
```

---

### Make these changes in `podfile`

Path: `ios` > `Podfile`

```podfile
installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
   # <!-- ADD THE NEXT SECTION -->
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'AUDIO_SESSION_MICROPHONE=0',
        ## dart: PermissionGroup.calendar
            # 'PERMISSION_EVENTS=1',

            ## dart: PermissionGroup.reminders
            # 'PERMISSION_REMINDERS=1',

            ## dart: PermissionGroup.contacts
            'PERMISSION_CONTACTS=1',

            ## dart: PermissionGroup.camera
            'PERMISSION_CAMERA=1',

            ## dart: PermissionGroup.microphone
            # 'PERMISSION_MICROPHONE=1',

            ## dart: PermissionGroup.speech
            # 'PERMISSION_SPEECH_RECOGNIZER=1',

            ## dart: PermissionGroup.photos
             'PERMISSION_PHOTOS=1',

            ## dart: [PermissionGroup.location,PermissionGroup.locationAlways, PermissionGrouplocationWhenInUse]
            # 'PERMISSION_LOCATION=1',

            ## dart: PermissionGroup.notification
            # 'PERMISSION_NOTIFICATIONS=1',

            ## dart: PermissionGroup.mediaLibrary
            'PERMISSION_MEDIA_LIBRARY=1',

            ## dart: PermissionGroup.sensors
            # 'PERMISSION_SENSORS=1',

            ## dart: PermissionGroup.bluetooth
            # 'PERMISSION_BLUETOOTH=1',

            ## dart: PermissionGroup.appTrackingTransparency
            # 'PERMISSION_APP_TRACKING_TRANSPARENCY=1',

            ## dart: PermissionGroup.criticalAlerts
            # 'PERMISSION_CRITICAL_ALERTS=1'
      ]
    end

  end
```

iOS Setup is done

Setup other platforms

- [Android](./README_android.md)
- [Web](./README_web.md)

[Go back to main](./README.md)

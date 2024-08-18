# Isometrik Chat Flutter SDK

## Android

### Make these changes to your `AndroidMenifest.xml`

Path: `android` > `app` > `main` > `AndroidMenifest.xml`

1. Permissions

   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="29" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
   <uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION"/>
   <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
   <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
   <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.READ_CONTACTS"/>
   <uses-permission android:name="android.permission.WRITE_CONTACTS"/>
   <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"/>
   ```

2. Queries / Intents

   ```xml
   <queries>
       <!-- If your app opens http/https URLs -->
       <intent>
           <action android:name="android.intent.action.VIEW" />
           <data android:scheme="https" />
       </intent>
       <intent>
           <action android:name="android.intent.action.VIEW" />
           <data android:scheme="http" />
       </intent>
       <!-- If your app makes calls -->
       <intent>
           <action android:name="android.intent.action.DIAL" />
           <data android:scheme="tel" />
       </intent>
       <!-- If your sends SMS messages -->
       <intent>
           <action android:name="android.intent.action.SENDTO" />
           <data android:scheme="smsto" />
       </intent>
       <!-- If your app sends emails -->
       <intent>
           <action android:name="android.intent.action.SEND" />
           <data android:mimeType="*/*" />
       </intent>
       <!-- If your app checks for SMS support -->
       <intent>
           <action android:name="android.intent.action.VIEW" />
           <data android:scheme="sms" />
       </intent>
       <!-- If your app checks for call support -->
       <intent>
           <action android:name="android.intent.action.VIEW" />
           <data android:scheme="tel" />
       </intent>

   </queries>
   ```

3. Google Map Api Key & File Provider

   Add the following lines

   ```xml
   <application
       android:label="APPLICATION_NAME"
       android:requestLegacyExternalStorage="true">

       <!--For Google map API key-->
       <meta-data android:name="com.google.android.geo.API_KEY"
          android:value="YOUR_MAPS_API_KEY"/>

       <!--For Image cropping provider-->
       <activity
           android:name="com.yalantis.ucrop.UCropActivity"
           android:screenOrientation="portrait"
           android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>
       <meta-data
           android:name="flutterEmbedding"
           android:value="2" />
       <provider
               android:name="androidx.core.content.FileProvider"
               android:authorities="${applicationId}.fileProvider"
               android:exported="false"
               android:grantUriPermissions="true"
               tools:replace="android:authorities">
           <meta-data
                   android:name="android.support.FILE_PROVIDER_PATHS"
                   android:resource="@xml/filepaths"
                   tools:replace="android:resource" />
       </provider>
   </application>
   ```

---

### Make these changes to your project level `filepaths.xml`

### First you need make a one folder with xml and make one file with `filepaths.xml` file name

Path: `android` > `app` > `src` > `main` > `res` > `xml` > `filepaths.xml`

1. Add versions inside android

   ```xml
   <!-- <?xml version="1.0" encoding="utf-8"?>

   <resources>
       <external-path name="external_storage_directory" path="." />
   </resources> -->
   <paths>
   <external-path name="external-path" path="."/>
   <external-cache-path name="external-cache-path" path="."/>
   <external-files-path name="external-files-path" path="."/>
   <files-path name="files_path" path="."/>
   <cache-path name="cache-path" path="."/>
   <root-path name="root" path="."/>
   </paths>

   ```

---

### Make these changes to your app level `build.gradle`

Path: `android` > `app` > `build.gradle`

1. Add versions inside android

   ```gradle
   android {
       compileSdkVersion 33

       defaultConfig {
           multiDexEnabled true
           minSdkVersion 24
       }
   }
   ```

2. Add multidex inside dependencies

   ```gradle
   dependencies {
       implementation 'com.android.support:multidex:1.0.3'
   }
   ```

---

### Make these changes to your android level `build.gradle`

Path: `android` > `build.gradle`

### Make these changes in `gradle.properties`

```subprojects {
    project.configurations.all {
        resolutionStrategy.eachDependency { details ->
            if (details.requested.group == 'com.android.support'
                    && !details.requested.name.contains('multidex') ) {
                details.useVersion "27.1.1"
            }
        }
    }
}
```

---

Android Setup is done

Setup other platforms

- [iOS](./README_ios.md)
- [Web](./README_web.md)

[Go back to main](./README.md)

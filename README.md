# mediatag_b

### Supported
+ Linux
+ Android
+ Window

### For Android

```kts

### android/app/build.gradle.kts

android {
    // ရှိပြီးသား configuration တွေကို မဖျက်ပါနဲ့။

    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}
```

# Isometrik Chat Flutter SDK

## web

### Make these changes to your `index.thml`

Path: `web` > `index.html`

```html
<!-- This script adds the flutter initialization in head tag -->
<script src="flutter.js" defer></script>
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_MAPS_API_KEY"></script>
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_MAPS_API_KEY&libraries=drawing"></script>
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_MAPS_API_KEY&libraries=drawing,visualization,places"></script>
<!-- Croppie -->
<link
  rel="stylesheet"
  href="https://cdnjs.cloudflare.com/ajax/libs/croppie/2.6.5/croppie.css"
/>
<script
  defer
  src="https://cdnjs.cloudflare.com/ajax/libs/exif-js/2.3.0/exif.js"
></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/croppie/2.6.5/croppie.min.js"></script>
<!-- cropperjs -->
<link
  rel="stylesheet"
  href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.css"
/>
<script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.js"></script>
```

---

web Setup is done

Setup other platforms

- [Android](./README_android.md)
- [iOS](./README_ios.md)

[Go back to main](./README.md)

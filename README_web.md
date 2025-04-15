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

```html
<!-- This script adds the flutter initialization in body tag -->
<!-- IMPORTANT: load pdfjs files -->
<script
  src="https://cdn.jsdelivr.net/npm/pdfjs-dist@3.4.120/build/pdf.min.js"
  type="text/javascript"
></script>
<script type="text/javascript">
  pdfjsLib.GlobalWorkerOptions.workerSrc =
    "https://cdn.jsdelivr.net/npm/pdfjs-dist@3.4.120/build/pdf.worker.min.js";
  pdfRenderOptions = {
    // where cmaps are downloaded from
    cMapUrl: "https://cdn.jsdelivr.net/npm/pdfjs-dist@3.4.120/cmaps/",
    // The cmaps are compressed in the case
    cMapPacked: true,
    // any other options for pdfjsLib.getDocument.
    // params: {}
  };
</script>
```

---

web Setup is done

Setup other platforms

- [Android](./README_android.md)
- [iOS](./README_ios.md)

[Go back to main](./README.md)

```

```

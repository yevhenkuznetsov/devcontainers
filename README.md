# Devcontainers

Repository for maintaining the images of the VS Code devcontainers for other projects.

## Qt WebEngine codecs

The Linux Qt image builds Qt 6.11.1 WebEngine with proprietary codecs enabled,
including H.264 and H.265/HEVC. H.264 decodes in software through Chromium's
bundled FFmpeg. Chromium has no software HEVC decoder on Linux, so the image is
built with VA-API (`libva-dev`, `-DFEATURE_webengine_vaapi=ON`) and H.265 decodes
on the GPU. The build fails if any of these codec or VA-API flags is missing.

HEVC playback at runtime additionally needs, on the machine or container running
the application:

- `libva2` and a VA-API driver that can decode HEVC for the GPU, such as
  `intel-media-va-driver` or `mesa-va-drivers`; check with `vainfo`;
- access to `/dev/dri` (for a devcontainer, `--device /dev/dri`);
- the decoder enabled in Chromium, e.g.
  `QTWEBENGINE_CHROMIUM_FLAGS="--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks"`.
  The exact feature names depend on the Chromium version and GPU.

Without a working VA-API HEVC decoder, `MediaSource.isTypeSupported` reports
HEVC as unsupported and H.264 still works. WSL2 and most virtual machines have
no VA-API decoder. Distribution of proprietary codecs can require patent or other licenses;
ensure the resulting application and image are distributed in compliance with
those requirements.

# Devcontainers

Repository for maintaining the images of the VS Code devcontainers for other projects.

## Qt WebEngine codecs

The Linux Qt image builds Qt 6.11.1 WebEngine with proprietary codecs enabled,
including H.264 and platform-assisted H.265/HEVC. HEVC playback at runtime
requires a decoder supported by the target Linux host and its hardware/driver
stack. Distribution of proprietary codecs can require patent or other licenses;
ensure the resulting application and image are distributed in compliance with
those requirements.

#!/usr/bin/env bash

set -euo pipefail

buildflag_headers=()
while IFS= read -r -d '' buildflag_header
do
  buildflag_headers+=("$buildflag_header")
done < <(find . -type f -path '*/gen/media/media_buildflags.h' -print0)

if [ "${#buildflag_headers[@]}" -eq 0 ]
then
  echo "Qt WebEngine Chromium media build flags were not generated."
  exit 1
fi

required_flags=(
  USE_PROPRIETARY_CODECS
  ENABLE_PLATFORM_HEVC
  ENABLE_HEVC_PARSER_AND_HW_DECODER
)

for required_flag in "${required_flags[@]}"
do
  if ! grep -Eq -- "BUILDFLAG_INTERNAL_${required_flag}\\(\\)[[:space:]]+\\((1|true)\\)" "${buildflag_headers[@]}"
  then
    echo "Qt WebEngine codec build flag is missing or disabled: $required_flag"
    exit 1
  fi
done

echo 'Verified Qt WebEngine codec build flags: H.264 and H.265/HEVC enabled.'

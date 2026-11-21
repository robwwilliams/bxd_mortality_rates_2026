#!/bin/bash
#
# actuarial_scan.sh
#
# copyright (c) 2026 - Rob Williams
#
# GN4AI-beta: Danny Arends's actuarial strain-means maps (Fig. 2, top two rows) through GeneNetwork's R/qtl2, one scan
# per diet and T-age (20 to 800 days in 30-day steps), with LOCO kinship and without kinship. Rob, 21 November 2026:
# "You are not doing the full actuarial scan in 30 day truncation steps right? That is what we want to do emulating
# Danny's figures." Exploratory.
#   - Strain means are sent inline (samples), not as baskets, so the run leaves nothing stored on the server.
#   - A scan already in data/local/GN4AI/actuarial/ is not sent again.
#
# Run from the repository root, after GN4AI/actuarial_means.R:  GN4AI_TOKEN_FILE=/path/to/token bash GN4AI/actuarial_scan.sh
# Adds to output/GN4AI/timings.txt; replies and one LOD column per scan in data/local/GN4AI/actuarial/
#

set -u
API=https://vesuvio.pu.ac.ke/gn4
TOKEN=$(tr -d '\n' < "$GN4AI_TOKEN_FILE")
OUT=output/GN4AI; RAW=data/local/GN4AI/actuarial

for diet in CD HF; do
  for T in $(seq 20 30 800); do
    for k in loco none; do
      f=$RAW/${diet}_T${T}_qtl2_$k.json
      [ "$(jq -r '.meta.state // ""' $f 2>/dev/null)" = complete ] && continue
      jq --arg k $k '. + {kinship: $k}' $RAW/${diet}_T${T}_body.json > $RAW/${diet}_T${T}_qtl2_${k}_body.json
      w=$(curl -s -m 900 -X POST -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' --data @$RAW/${diet}_T${T}_qtl2_${k}_body.json \
           -D $f.h -o $f -w '%{http_code}\t%{time_total}\t%{size_download}' "$API/compute/qtl2?id=${diet}_T${T}_qtl2_$k")
      echo -e "$(date -u +%FT%TZ)\tactuarial_${diet}_T$T\tqtl2_$k\t$w\t$(jq -r '.meta.took_ms // ""' $f)\t$(grep -i '^x-request-id' $f.h | tr -d '\r' | cut -d' ' -f2)" >> $OUT/timings.txt
      echo "$diet T$T qtl2_$k: $w; $(jq -r '.notes[]? | select(test("values used")) | sub(".*\\); "; "")' $f)" >&2
      [ "${w%%$'\t'*}" = 200 ] && jq -r '(.meta.columns | @tsv), (.data[] | @tsv)' $f | gzip -n > $RAW/${diet}_T${T}_qtl2_$k.tsv.gz
    done
  done
done

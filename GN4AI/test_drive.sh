#!/bin/bash
#
# test_drive.sh
#
# copyright (c) 2026 - Rob Williams
#
# Test drive of GN4AI-beta (https://vesuvio.pu.ac.ke/gn4), GeneNetwork's interface for AI agents. Exploratory.
# Stores the strain means of GN4AI/strain_means.R as baskets, maps each with R/qtl (with and without permutations) and
# with both GEMMA runners, plots each scan, and records every call's status, wall-clock time and size.
#
# The token is never written here: put it in a file outside the repository and pass its path.
# Run from the repository root:  GN4AI_TOKEN_FILE=/path/to/token bash GN4AI/test_drive.sh [basket names]
# Writes output/GN4AI/timings.txt, <basket>_<engine>.tsv.gz and <basket>_<engine>.svg; full replies in data/local/GN4AI/
#

set -u
API=https://vesuvio.pu.ac.ke/gn4
TOKEN=$(tr -d '\n' < "$GN4AI_TOKEN_FILE")
OUT=output/GN4AI; RAW=data/local/GN4AI; mkdir -p $OUT $RAW
BASKETS=${*:-lifespan_CD_T20 lifespan_HF_T20 lifespan_NAM_T20_Beni lifespan_NAM_T20_Danny}
[ -f $OUT/timings.txt ] || echo -e "when\tbasket\tstep\thttp\tseconds\tbytes\tserver_ms\trequest_id" > $OUT/timings.txt
[ -f $OUT/rqtl_perm1000_thresholds.txt ] || echo -e "basket\tsignificant\tsuggestive" > $OUT/rqtl_perm1000_thresholds.txt

call() {   # call STEP BASKET METHOD PATH OUTFILE [BODYFILE]; prints the HTTP status
  local body=(); [ $# -ge 6 ] && body=(-H 'Content-Type: application/json' --data @"$6")
  local w=$(curl -s -m 900 -X "$3" -H "Authorization: Bearer $TOKEN" "${body[@]}" -D "$RAW/$(basename "$5").h" -o "$5" \
            -w '%{http_code}\t%{time_total}\t%{size_download}' "$API$4")
  local ms=$(jq -r '.meta.took_ms // ""' "$5" 2>/dev/null); local id=$(grep -i '^x-request-id' "$RAW/$(basename "$5").h" | tr -d '\r' | cut -d' ' -f2)
  echo -e "$(date -u +%FT%TZ)\t$2\t$1\t$w\t$ms\t$id" >> $OUT/timings.txt
  echo -e "  $2 $1: $w ${ms:+(server ${ms} ms)}" >&2
  echo "${w%%$'\t'*}"
}

curl -s $API/version | jq -c .data > $RAW/version.json; echo "GN4AI build: $(jq -r .git $RAW/version.json)" >&2
for b in $BASKETS; do
  s=$(call basket_create $b POST /baskets $RAW/${b}_basket.json $OUT/basket_$b.json)
  if [ "$s" != 201 ]; then                                                   # already stored: replace it, as a new revision
    jq '{values}' $OUT/basket_$b.json > $RAW/${b}_revise_body.json
    call basket_revise $b PATCH /baskets/$b $RAW/${b}_basket.json $RAW/${b}_revise_body.json > /dev/null
  fi
  for e in rqtl rqtl_perm1000 gemma_ravanan gemma_wrapper; do
    case $e in
      rqtl)          path=/compute/rqtl;          plot=rqtl;  extra='{}';;
      rqtl_perm1000) path=/compute/rqtl;          plot=rqtl;  extra='{"nperm":1000}';;
      gemma_ravanan) path=/compute/gemma/ravanan; plot=gemma; extra='{}';;
      gemma_wrapper) path=/compute/gemma;         plot=gemma; extra='{}';;
    esac
    jq -n --arg b $b --argjson x "$extra" '{group: "BXD", basket: $b, trait_name: ("BXD::" + $b)} + $x' > $RAW/${b}_${e}_body.json
    s=$(call $e $b POST "$path?id=${b}_$e" $RAW/${b}_$e.json $RAW/${b}_${e}_body.json)
    [ "$s" = 200 ] || continue
    jq -r '(.meta.columns | @tsv), ((if (.data | type) == "object" then .data.markers else .data end)[] | @tsv)' $RAW/${b}_$e.json | gzip -n > $OUT/${b}_$e.tsv.gz   # R/qtl replies wrap the rows
    [ $e = rqtl_perm1000 ] && jq -r --arg b $b '[$b, .data.permutation.significant, .data.permutation.suggestive] | @tsv' $RAW/${b}_$e.json >> $OUT/rqtl_perm1000_thresholds.txt
    call plot_$e $b POST "/plot/$plot?trait=BXD::$b" $OUT/${b}_$e.svg $RAW/${b}_$e.json > /dev/null
    grep -i '^x-plot-summary' $RAW/${b}_$e.svg.h | tr -d '\r' >&2
  done
done

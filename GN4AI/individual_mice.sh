#!/bin/bash
#
# individual_mice.sh
#
# copyright (c) 2026 - Rob Williams
#
# GN4AI-beta: does /compute/qtl2 take one value per mouse? Rob, 21 November 2026: "R/qtl2 maps with kinship, or can.
# Is this a limitation of the GN implementation?" R/qtl2 itself maps replicate mice of a strain with kinship and
# cofactors; this sends GN4AI the high-fat mice of Beni Mozhui's file one by one, so that each strain's name repeats,
# and reads how many values the scan used. To see which value GN4AI keeps for a strain, the same mice also go in as
# one value per strain: the strain mean, the first mouse in the file and the last. Exploratory.
#
# Run from the repository root:  GN4AI_TOKEN_FILE=/path/to/token bash GN4AI/individual_mice.sh
# Adds to output/GN4AI/timings.txt; full replies in data/local/GN4AI/
#

set -u
API=https://vesuvio.pu.ac.ke/gn4
TOKEN=$(tr -d '\n' < "$GN4AI_TOKEN_FILE")
OUT=output/GN4AI; RAW=data/local/GN4AI; mkdir -p $OUT $RAW

LC_ALL=C.UTF-8 Rscript -e '
  d <- read.csv("data/original/BXD_Lifespan_AllDiets_Dataset_Mapping_Arends.csv", skip = 15, check.names = FALSE, fileEncoding = "UTF-8-BOM")[, 1:7]
  colnames(d) <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
  d <- d[!is.na(d[, "EarTag"]) & d[, "Diet"] == "HF" & !d[, "Strain"] %in% c("C57BL/6J", "DBA/2J", "B6D2F1", "D2B6F1"), ]
  bodies <- list(individual = data.frame(name = d[, "Strain"], value = d[, "Age"]),
                 mean  = data.frame(name = sort(unique(d[, "Strain"])), value = round(tapply(d[, "Age"], d[, "Strain"], mean), 2)),
                 first = d[!duplicated(d[, "Strain"]), c("Strain", "Age")], last = d[!duplicated(d[, "Strain"], fromLast = TRUE), c("Strain", "Age")])
  for (b in names(bodies)) {
    s <- setNames(bodies[[b]], c("name", "value")); rownames(s) <- NULL
    body <- list(group = "BXD", trait_name = paste0("BXD::lifespan_HF_", b), kinship = "loco", samples = s)
    writeLines(jsonlite::toJSON(body, auto_unbox = TRUE, digits = NA), paste0("data/local/GN4AI/HF_", b, "_qtl2_loco_body.json"))
    cat(b, ":", nrow(s), "values,", length(unique(s[, "name"])), "strains\n", file = stderr())
  }'

for b in individual mean first last; do
  f=$RAW/HF_${b}_qtl2_loco.json
  w=$(curl -s -m 900 -X POST -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' --data @$RAW/HF_${b}_qtl2_loco_body.json \
       -D $f.h -o $f -w '%{http_code}\t%{time_total}\t%{size_download}' "$API/compute/qtl2?id=HF_${b}_qtl2_loco")
  echo -e "$(date -u +%FT%TZ)\tHF_$b\tqtl2_loco\t$w\t$(jq -r '.meta.took_ms // ""' $f)\t$(grep -i '^x-request-id' $f.h | tr -d '\r' | cut -d' ' -f2)" >> $OUT/timings.txt
  echo "HF $b, qtl2_loco: $w" >&2
  jq -r '.error? // empty, (.notes[]? | select(test("values used|duplicate|repeat|averag"; "i")))' $f | cut -c1-400 >&2
  [ "${w%%$'\t'*}" = 200 ] && jq -r '(.meta.columns | @tsv), (.data[] | @tsv)' $f | gzip -n > $OUT/HF_${b}_qtl2_loco.tsv.gz
done

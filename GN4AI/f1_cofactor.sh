#!/bin/bash
#
# f1_cofactor.sh
#
# copyright (c) 2026 - Rob Williams
#
# GN4AI-beta: GeneNetwork's own lifespan traits 18441 (chow) and 18435 (high fat), mapped with the BXD x BXD F1s left out
# (the default), put back in, and put back in with F1 type as a cofactor. Rob, 21 November 2026: "the two types of F1
# were by design, so just add the "type" as a cofactor", and, of R/qtl2's F2 genotype model: "Not for the BXD-by-BXD
# F1s. They are genetically just like an F2 cross." Exploratory.
#   GEMMA: F1s out and in (no route takes covariates on this build: /compute/gemma answers that ravanan cannot).
#   R/qtl2, LOCO kinship: F1s out (riself); F1s in with heterozygous calls kept (genotype_model f2); and the same with
#   F1 type as a categorical cofactor.
#   Types: inbred BXD 0; short x short F1 1 (parents BXD9, 170, 172, 197); long x long F1 2 (BXD65, 73b, 77, 102);
#   B6D2F1 and D2B6F1 3. GEMMA keeps heterozygous calls as dosage 0.5, so each F1 counts at every marker.
#
# Run from the repository root:  GN4AI_TOKEN_FILE=/path/to/token bash GN4AI/f1_cofactor.sh
# Writes output/GN4AI/trait<id>_<model>.tsv.gz and adds to output/GN4AI/timings.txt; full replies in data/local/GN4AI/
#

set -u
API=https://vesuvio.pu.ac.ke/gn4
TOKEN=$(tr -d '\n' < "$GN4AI_TOKEN_FILE")
OUT=output/GN4AI; RAW=data/local/GN4AI; mkdir -p $OUT $RAW
type='if (.name | test("^BXD0?(09|170|172|197)xBXD0?(09|170|172|197)F1$")) then 1
      elif (.name | test("^BXD0?(65|73b?|77|102)b?xBXD0?(65|73b?|77|102)F1$")) then 2
      elif (.name == "B6D2F1" or .name == "D2B6F1") then 3 else 0 end'

for t in 18441 18435; do
  curl -s -H "Authorization: Bearer $TOKEN" -o $RAW/trait${t}_values.json "$API/groups/BXD/traits/$t/values"
  jq '.actions[] | select(.href | endswith("/compute/gemma")) | .body' $RAW/trait${t}_values.json > $RAW/trait${t}_gemma_noF1_body.json
  jq '. + {include_parents_f1: true}' $RAW/trait${t}_gemma_noF1_body.json > $RAW/trait${t}_gemma_F1_body.json
  q='{group, trait_name, samples, kinship: "loco"}'
  jq "$q" $RAW/trait${t}_gemma_noF1_body.json > $RAW/trait${t}_qtl2_noF1_body.json
  jq "$q + {include_parents_f1: true, genotype_model: \"f2\"}" $RAW/trait${t}_gemma_noF1_body.json > $RAW/trait${t}_qtl2_f2_F1_body.json
  jq "{name: \"F1_type\", kind: \"categorical\", values: [.samples[] | {name, value: ($type)}]} as \$c | $q + {include_parents_f1: true, genotype_model: \"f2\", covariates: [\$c]}" \
     $RAW/trait${t}_gemma_noF1_body.json > $RAW/trait${t}_qtl2_f2_F1_type_body.json
  echo "trait $t, F1 types: $(jq -r '.covariates[0].values | group_by(.value) | map("\(.[0].value)=\(length)") | join(" ")' $RAW/trait${t}_qtl2_f2_F1_type_body.json)" >&2
  for model in gemma_noF1 gemma_F1 qtl2_noF1 qtl2_f2_F1 qtl2_f2_F1_type; do
    f=$RAW/trait${t}_$model.json; path=/compute/gemma; [ ${model%%_*} = qtl2 ] && path=/compute/qtl2
    w=$(curl -s -m 900 -X POST -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' --data @$RAW/trait${t}_${model}_body.json \
         -D $f.h -o $f -w '%{http_code}\t%{time_total}\t%{size_download}' "$API$path?id=t${t}_$model")
    echo -e "$(date -u +%FT%TZ)\ttrait$t\t$model\t$w\t$(jq -r '.meta.took_ms // ""' $f)\t$(grep -i '^x-request-id' $f.h | tr -d '\r' | cut -d' ' -f2)" >> $OUT/timings.txt
    echo "  trait $t $model: $w" >&2
    [ "${w%%$'\t'*}" = 200 ] && jq -r '(.meta.columns | @tsv), (.data[] | @tsv)' $f | gzip -n > $OUT/trait${t}_$model.tsv.gz
    jq -r '.notes[]? | select(test("individuals|ovariate|values used|Cross|heterozygous"; "i"))' $f | cut -c1-260 >&2
  done
done

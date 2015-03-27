#!/bin/bash

MONGO_PORT=27017
export MONGO_HOST=mongo
echo "Waiting on MongoDB to initialize..."
while ! nc -zw2 $MONGO_HOST $MONGO_PORT; do sleep 11; done
echo "done."

# for loading the MAGI STAD
# todo: stuff in another script
cd ~melchior/magi/db
node loadGenome.js --genome_file=../data/genome/hg19_genes_list.tsv
node loadCancers.js --cancers_file=../data/icgc-tcga-cancers.tsv
node loadKnownGeneSets.js --gene_set_file=../data/pathways/pindb/pindb-complexes.tsv --dataset=PINdb
node loadKnownGeneSets.js --gene_set_file=../data/pathways/kegg/kegg-pathways.tsv --dataset=KEGG
node loadDomains.js --domain_file=../data/domains/ensembl_transcript_domains.tsv
node loadDomains.js --domain_file=../data/domains/refseq_transcript_domains.tsv
node loadPPIs.js --ppi_file=../data/ppis/hint-annotated.tsv
node loadPPIs.js --ppi_file=../data/ppis/hprd-annotated.tsv
node loadPPIs.js --ppi_file=../data/ppis/multinet.tsv # may fail due to memory
node loadPPIs.js --ppi_file=../data/ppis/iref9-annotated.tsv # may fail due to memory
echo "Done loading standard datasets..."
bash loadPublicDatasets.sh
cd ..

sudo /etc/init.d/nginx start

# start the server 
node --harmony server.js

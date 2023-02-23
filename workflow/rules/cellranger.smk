import glob
import os
from pathlib import Path

def get_sample_option(wc):
    option_str=""
    prefix=units["sample"][wc.sample] 
    option_str += f"--sample={prefix}"
    return option_str

def get_fq_path(wc):
    filepath = units["fq1"][wc.sample][0]
    dirname, basename = os.path.split(filepath)
    return dirname

rule cellranger_count:
    input:
        fq=get_fq_path
    output:
        singlecells="{}/{{sample}}/cellranger_count/outs/singlecell.csv".format(OUTDIR),
        fragments="{}/{{sample}}/cellranger_count/outs/fragments.tsv.gz".format(OUTDIR),
        filtered="{}/{{sample}}/cellranger_count/outs/filtered_feature_bc_matrix.h5".format(OUTDIR),
        bam="{}/{{sample}}/cellranger_count/outs/possorted_genome_bam.bam".format(OUTDIR)
    params:
        reference=config['cellranger']['reference']
    envmodules:
        config['envmodules']['cellranger']
    threads: get_resource("cellranger", "threads")
    resources:
        mem_mb=get_resource("cellranger", "mem_mb"),
        walltime=get_resource("cellranger", "walltime")
    log:
        err="{}/{{sample}}/cellranger.err".format(LOGDIR),
        out="{}/{{sample}}/cellranger.out".format(LOGDIR),
        time="{}/{{sample}}/cellranger.time".format(LOGDIR)
    shell:
        """
        {DATETIME} > {log.time} &&
        cellranger-atac count --id={wildcards.sample} \
        --reference={params.reference} \
        --fastqs={input.fq} \
        2> {log.err} > {log.out} &&
        mv {wildcards.sample} "{OUTDIR}/{wildcards.sample}/cellranger_count" &&
        {DATETIME} >> {log.time}
        """

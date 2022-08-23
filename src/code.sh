#!/bin/bash
# vcf_header_corrector 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://documentation.dnanexus.com/developer for tutorials on how
# to modify this file.

main() {

    echo "Value of mutect2_input: '$mutect2_input'"
    echo "Value of cgppindel_input: '$cgppindel_input'"

    set -e -x -v -o pipefail

	export BCFTOOLS_PLUGINS=/usr/local/libexec/bcftools/

    mark-section "downloading inputs"
	time dx-download-all-inputs --parallel

    # add tags required for openCGA
	# write these to separate filtered but unannotated VCFs for uploading
	mark-section "Adding SAMPLE tags to VCF headers"
	sample_id=$(echo "$mutect2_input_name" | cut -d'-' -f1)  # the id to add to the vcfs

	# add sample id to mutect2 vcf on line before ##tumour_sample in header
	# no SAMPLE line already present so create one from full name and ID we want
	mutect2_column_name=$(zgrep "#CHROM" "$mutect2_input_path" | cut -f10)
	sample_field="##SAMPLE=<ID=${mutect2_column_name},SampleName=${sample_id}>"

	#setting output prefixes and names
	mutect2_input_prefix=$(echo "$mutect2_input_name" | cut -d'.' -f1)
	cgppindel_input_prefix=$(echo "$cgppindel_input_name" | cut -d'.' -f1)
	mutect2_output="${mutect2_input_prefix}.opencga.vcf"
	cgppindel_output="${cgppindel_input_prefix}.opencga.vcf"

	zgrep "^#" "$mutect2_input_path" | sed s"/^##tumor_sample/${sample_field}\n&/" > mutect2.header
	bcftools reheader -h mutect2.header "$mutect2_input_path" > "${mutect2_output}"

	# sense check in logs it looks correct
	zgrep "^#" "${mutect2_output}"

	# modify SampleName for tumour sample line to correctly link to our sample ID
	tumour_sample=$(zgrep "##SAMPLE=<ID=TUMOUR" "$cgppindel_input_path")
	header_line=$(sed s"/SampleName=[A-Za-z0-9\_\-]*/SampleName=${sample_id}/" <<< $tumour_sample)

	zgrep "^#" "$cgppindel_input_path" \
		| sed s"/^##SAMPLE=<ID=TUMOUR.*/${header_line}/" > pindel.header

	bcftools reheader -h pindel.header "$cgppindel_input_path" > "${cgppindel_output}"
	# sense check in logs it looks correct
	zgrep '^#' "${cgppindel_output}"

	mark-section "Preparing the outputs for upload"

    mkdir -p ~/out/mutect2_output ~/out/cgppindel_output
	mv ~/"${mutect2_output}" ~/out/mutect2_output/
	mv ~/"${cgppindel_output}" ~/out/cgppindel_output/

    # Upload the outputs
	dx-upload-all-outputs
	mark-success
}

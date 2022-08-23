<!-- dx-header -->
# VCF Header Corrector (DNAnexus Platform App)

## What does this app do?
This app adds a sample's ID number to the headers of compressed Mutect2 and cgpPindel VCF files, generating a new file for each.

Please note that the app does not carry out any filtering steps.

## Typical use cases
The app is for use in pipelines which rely on sample IDs being present in the VCF headers, in order for downstream tools to work. It replaces the VCF reannotation section of this older tool: https://github.com/eastgenomics/eggd_vcf_handler_for_uranus/ 

*The app has access to the internet*

## Inputs

### Required app assets:
* bedtools (v2.30.0)

### Reference files:
* Not applicable

### Input arguments
* mutect2_input: a Mutect2 compressed VCF file, typically ending in '_markdup_recalibrated_tnhaplotyper2.vcf.gz'
* cgppindel_input: a cgpPindel compressed VCF file, typically ending in '_tumor.flagged.vcf.gz'

### Running the applet
Can be run as a stand-alone job as follows:
dx run vcf_header_corrector \
-i mutect2_input="the_file's_id" \
-i cgppindel_input="another_file's_id"

## Outputs
### Generated automatically:
* mutect2_output: a file with the same name as mutect2_input, but with the file extension replaced with '.opencga.vcf.gz'.
* cgppindel_output: a file with the same name as cgppindel_input, but with the file extension replaced with '.opencga.vcf.gz'.


## Limitations
* When building the app, mark-section and mark-success must be executable for the app to build correctly - these two scripts are executable in this repo but it can be easy to miss if the executable bit is lost as it's a metadata change
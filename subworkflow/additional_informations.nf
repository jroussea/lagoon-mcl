include { InformationFiles        } from '../modules/attributes.nf'
include { LabInformation          } from '../modules/attributes.nf'

workflow OTHER_INFORMATIONS {
    take:
        information_files
        proteome

    main:
            information_files = Channel.fromPath(information_files, checkIfExists: true)

            InformationFiles(proteome, information_files)
            proteome_info = InformationFiles.out.proteome_info

            select_info = proteome_info.collectFile(name: "${params.outdir}/network/plouf.tsv")

            LabInformation(select_info)
            //information_label = label_network.concat(information_network).collect()

    emit:
        infos_label = LabInformation.out.label_network
}
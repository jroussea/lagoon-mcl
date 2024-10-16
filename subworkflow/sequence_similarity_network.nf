include { DiamondDB                        } from '../modules/diamond.nf'
include { DiamondBLASTp                    } from '../modules/diamond.nf'
include { FiltrationAlnNetwork             } from '../modules/diamond.nf'
include { NetworkMcxload                   } from '../modules/network.nf'
include { NetworkMcl                       } from '../modules/network.nf'
include { NetworkMcxdump                   } from '../modules/network.nf'
include { NetworkMclToTsv                  } from '../modules/network.nf'

workflow SSN {
    take:
        run_diamond
        all_sequences
        alignment_file
        inflation

    main:
        if (run_diamond == true) {

            //split_all_sequence = all_sequences.splitFasta(by: 100000)

            // diamond database
            DiamondDB(all_sequences)
            diamond_db = DiamondDB.out.diamond_db

            // diamond blastp
            DiamondBLASTp(all_sequences, diamond_db)
            diamond_alignment = DiamondBLASTp.out.diamond_alignment	
        }
        if (run_diamond == false) {
	        diamond_alignment = Channel.fromPath(alignment_file, checkIfExists: true)
        }

        FiltrationAlnNetwork(diamond_alignment)
        diamond_ssn = FiltrationAlnNetwork.out.diamond_ssn

        NetworkMcxload(diamond_ssn)        
        tuple_seq_dict_mci = NetworkMcxload.out.tuple_seq_dict_mci

        NetworkMcl(inflation, tuple_seq_dict_mci)
        tuple_mcl = NetworkMcl.out.tuple_mcl

        NetworkMcxdump(tuple_mcl)
        tuple_dump = NetworkMcxdump.out.tuple_dump

        NetworkMclToTsv(tuple_dump)

    emit:
        tuple_network = NetworkMclToTsv.out.tuple_network

}
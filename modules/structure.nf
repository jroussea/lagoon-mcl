process FastaHeader {
    
    tag ''

    input:
        path tsv_pdb
    
    output:
        //stdout
        path "${tsv_pdb.baseName}.tmp", emit: tsv_pdb_tmp

    script:
        """
        cut -f 1 ${tsv_pdb} > header

        paste header ${tsv_pdb} > ${tsv_pdb.baseName}.tmp
        """
}

// concaténer tous les pdb dans tsv_pdb_all

process ClusterPdb {
    
    // merge cluster size et pdb + sélectionne uniquement les cluster vec plus de 1 pdb
    // en sotie 2 tsv,
    // 1 tsv ou 1 ligne = 1 cluster => indique le nombre de pdb : no_pdb, 1, 2, ...
    // 1 tsv ou 1 ligne = 1 séquence qui possède 1 pdb

    tag ''

    input:
        path tsv_pdb_all
        each cluster_size
    
    output:
        //stdout
        path "*.tsv", emit: cluster_pdb

    script:
        """
    
        merge_pdb.R ${tsv_pdb_all} ${cluster_size}

        """
}

// en sortie on possède 3 cluster avec pdb = on séle

process Foldseek {
    
    // mélange de bash et de r

    

    // ou r permet d'appliquer foldseek sous forme de fonction à chaque cluster 
    // group_by + mutate foldseek

    tag ''

    input:
        path tsv_pdb_all
        each cluster_size
    
    output:
        //stdout
        path "*.tsv", emit: cluster_pdb

    script:
        """
    
        merge_pdb.R ${tsv_pdb_all} ${cluster_size}

        """
}


process Foldseek {
    
    /*
en entré 1 fichier tsv 1 ou plusieurs du type annotation
col 1 = nom de la séquence
col 2 = path vers le pdb

étape 1 = préparer les nom des séquences fasta, ne garder que la première partie (bash / awk / sed) = cut
étape 2 = merge TSV avec TSV cluster size (R / python)
étape 3 = grep cluster avec au moins 1 pdb (R / python)
étape 4 = récupérer par cluster les pdb correspondant
étape 5 = par cluster construire la base de données
étape 6 = par cluster index
étape 7 = par cluster faire tourner foldseek = récupérer 1 tm score par cluster = score d'homogénéité
    */

    tag ''

    input:
        each label_network
        tuple path(network_tsv), val(inflation)
    
    output:
        tuple path("*all*.tsv"), val("${inflation}"), val("${label_network.baseName}"), val("all"), emit: tuple_hom_score_all
        tuple path("*annotated*.tsv"), val("${inflation}"), val("${label_network.baseName}"), val("annotated"), emit: tuple_hom_score_annotated

    script:
        """
        network_homogeneity_score.py ${network_tsv} ${label_network} ${params.pep_colname} ${inflation} ${label_network.baseName}
        """
}
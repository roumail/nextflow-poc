#!/usr/bin/env nextflow

// This script has two processes: countSequences and extractIds. The main workflow creates a channel data_ch from the input data,
//  runs countSequences process with the input data, and then runs extractIds process with the input data as well. Finally, it prints 
// the number of sequences and sequence IDs in the output.

nextflow.enable.dsl=2

// Define the input data as a parameter
params.data = "dataset/sample.fa"

// Process 1: Count the number of sequences in the input file
process countSequences {
    input:
        path file_in

    output:
        stdout emit: num_sequences

    script:
    """
    grep -c '^>' $file_in
    """
}

// Process 2: Extract sequence IDs from the input file
process extractIds {
    input:
        path file_in

    output:
        path 'ids.txt', emit: ids_file

    script:
    """
    grep '^>' $file_in > ids.txt
    """
}

// Main workflow
workflow {
    // Create a channel from the input data
    data_ch = channel.fromPath(params.data)

    // Run the processes in sequence
    countSequences(data_ch)
    extractIds(data_ch)

    // Print the output
    countSequences.out.num_sequences.view()
    extractIds.out.ids_file.view()
}

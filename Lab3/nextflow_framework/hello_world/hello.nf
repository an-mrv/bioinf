#!/usr/bin/env nextflow

process sayHello {
    output:
    stdout

    script:
    """
    echo "Hello, World from Nextflow!"
    """
}

workflow {
    sayHello() | view
}
#!/bin/bash

# Save the current folder path to the variable 'p'
p=$PWD

# Go through each subfolder in the current directory
for d in $p/*; do
    # Move into the current subfolder; stop the script if the folder doesn't exist
    cd "$d" || exit

    # Take the first column from the 'list' file, trim off the last two characters from each line, 
    # and save the result in a new file called 'new.list'
    cut -f 1 list | awk '{ print substr( $0, 1, length($0)-2 ) }' > new.list

    # Reformat 'armfinder_forinterpro.fa' to ensure each sequence is on a single line. 
    # Save the cleaned-up version as 'for_sp.fa'
    awk '{if(NR==1) {print $0} else {if($0 ~ /^>/) {print "\n"$0} else {printf $0}}}' /xxx/armfinder_forinterpro.fa > for_sp.fa

    # Use the IDs in 'new.list' to pull out matching sequences from 'for_sp.fa' 
    # and save them to a file called 'test.fna'
    grep -A 1 -f new.list for_sp.fa > test.fna 

    # Get the name of the current folder and save it in the variable 'x'
    x=$(basename "$(pwd)")

    # Extract matching sequences from 'card.fna' using the current folder name and save them as 'ref.fna'
    grep -A 1 $x /xxx/card-data/card.fna > ref.fna 

    # Split the 'test.fna' file into smaller chunks. Each chunk will start with 'part' in its name.
    seqkit split -i test.fna -O .

    # Process each smaller file one by one
    for split_file in *part*; do
        # Combine the current small file with 'ref.fna' into a new file named 'seq_<split_file>'
        cat "$split_file" ref.fna > seq_"$split_file"

        # Translate the combined sequences into protein sequences, saving the output as 'seq_<split_file>.faa'
        transeq -sequence seq_"$split_file" -outseq seq_"$split_file".faa
        sleep 0.5  # Pause for half a second before the next step

        # Align the protein sequences with MAFFT and save the alignment as 'seq_<split_file>.aln'
        mafft --auto seq_"$split_file".faa > seq_"$split_file".aln
        sleep 0.5  # Pause for half a second

        # Convert the alignment into Clustal format and save it as 'seq_<split_file>.cw'
        pal2nal.pl -nogap seq_"$split_file".aln seq_"$split_file" -output clustal > seq_"$split_file".cw

        # Change the Clustal file into AXT format and save it as 'seq_<split_file>.axt'
        /xxx/KaKs_Calculator3.0/src/./AXTConvertor seq_"$split_file".cw seq_"$split_file".axt
        sleep 0.5  # Pause for half a second

        # Run Ka/Ks calculations on the AXT file and save the results with a unique name
        /xxx/KaKs_Calculator3.0/src/./KaKs -i seq_"$split_file".axt -o "$split_file"_ka_ks -c 11
    done

    # Go back to the main directory after finishing with the current subfolder
    cd ..
done


function crun -d "Compile and run a C program instantly"
    if test (count $argv) -eq 0
        echo "Error: No input files provided."
        return 1
    end

    # Strip the .c extension from the first argument to get the binary name
    set out_name (basename $argv[1] .c)

    # Compile using your strict C23 function
    c23 -o $out_name $argv

    # If compilation succeeds (status 0), run the executable immediately
    if test $status -eq 0
        ./$out_name
    end
end


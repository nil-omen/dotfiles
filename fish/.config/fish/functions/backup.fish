function backup
    for file in $argv
        set --local target (string trim --right --chars / $file)
        cp -rL $target $target.bak
        echo "Backed up $target -> $target.bak"
    end
end

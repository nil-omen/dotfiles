function c23 --wraps='clang -Wall -Wextra -std=c23 -pedantic' --description 'Compile C with strict C23 warnings'
    clang -Wall -Wextra -std=c23 -pedantic $argv
end

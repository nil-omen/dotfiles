function zcc --wraps='zig cc -target aarch64-linux-musl' --description 'Compile C statically using Zig musl'
    zig cc -target aarch64-linux-musl $argv
end

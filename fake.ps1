$ORIG_DIR="$pwd"
$SCRIPT_NAME=$MyInvocation.MyCommand.Name

$TARGET_DIR="target"
$WORKING_DIR=$ORIG_DIR
$UP_TRAVERSAL=3

function _exit {
        cd $ORIG_DIR
        exit
}

function usage {
        write-host "================ Help ================" -ForegroundColor White
        write-host "Usage: $SCRIPT_NAME <command>" -ForegroundColor Gray
        write-host "Commands:" -ForegroundColor Gray

        write-host "    cmake   " -ForegroundColor White -NoNewLine
        write-host 'runs cmake in target dir ($FAKE_CMAKE_FLAGS)' -ForegroundColor Gray

        write-host "    build   " -ForegroundColor White -NoNewLine
        write-host "runs cmake --build $TARGET_DIR" -ForegroundColor Gray

        write-host "    status  " -ForegroundColor White -NoNewLine
        write-host "prints some status information" -ForegroundColor Gray

        write-host "    clean   " -ForegroundColor White -NoNewLine
        write-host "del $TARGET_DIR" -ForegroundColor Gray

        write-host "    <bin>   " -ForegroundColor White -NoNewLine
        write-host "executes <bin> in dir $TARGET_DIR" -ForegroundColor Gray

        write-host "    help    " -ForegroundColor White -NoNewLine
        write-host "show this screen" -ForegroundColor Gray

        _exit
}

function info {
        write-host "INFO: " -ForegroundColor Green -NoNewLine
        write-host $args
}

function err {
        write-host "ERR : " -ForegroundColor Red -NoNewLine
        echo $args
}

if ( $args[0] -eq "help" ) {
        usage
}

for ($i=0; $i -le $UP_TRAVERSAL; $i++) {
        if (Get-Item -Path $WORKING_DIR\CMakeLists.txt -ErrorAction Ignore) {
                break
        }
        if ( $i -eq $UP_TRAVERSAL ) {
                err "CMakeLists.txt does not exist in the upper $UP_TRAVERSAL dir(s)"
                _exit
        }
        $WORKING_DIR=$(Resolve-Path -Path "$WORKING_DIR\..").path
}
info "Found CMakeLists.txt in $WORKING_DIR"

if (Get-Item -Path $WORKING_DIR\fake.conf.ps1 -ErrorAction Ignore) {
        . $WORKING_DIR\fake.conf.ps1
}

$COMMAND = $args[0]

switch ($COMMAND) {
        cmake {
                New-Item -ItemType Directory -Force -Path $WORKING_DIR\$TARGET_DIR | Out-Null
                cd $WORKING_DIR\$TARGET_DIR
                $CMD="cmake ..\. $FAKE_CMAKE_FLAGS"
                info "Invoking: '$CMD'"
                Invoke-Expression -Command $CMD
        }
        build {
                $CMD="cmake --build $WORKING_DIR\$TARGET_DIR"
                info "Invoking: '$CMD'"
                Invoke-Expression -Command $CMD
        }
        status {
                err "Not implemented yet!"
        }
        clean {
                $CMD="Remove-Item -Recurse -Force -Confirm:"+'$false'+" $WORKING_DIR\$TARGET_DIR"
                info "Invoking: '$CMD'"
                Invoke-Expression -Command $CMD
        }
        $null {
                err "Unknown command: <null>"
                usage
        }
        default {
                if (Get-Item -Path $WORKING_DIR\$TARGET_DIR\$COMMAND -ErrorAction Ignore) {
                        $exe="$WORKING_DIR\$TARGET_DIR\$COMMAND"
                        if ($FAKE_EXEC_HOST -ne $null) {
                                scp $exe $FAKE_EXEC_HOST`:.
                                ssh $FAKE_EXEC_HOST -t "chmod +x $COMMAND; ./$COMMAND; rm $COMMAND"
                        } else {
                                .\$exe
                        }
                        _exit
                }
                err "Unknown command: $COMMAND"
                usage
        }
}


_exit

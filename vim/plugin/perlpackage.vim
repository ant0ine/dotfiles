
function! Findperlpackage(args)
    let grepprg_bak=&grepprg
    exec "set grepprg=git\\ grep\\ -i\\ -n\\ --no-color\\ "
    execute "silent! grep \"package .*" . a:args . "\""
    botright copen
    let &grepprg=grepprg_bak
    exec "redraw!"
endfunction

command! -nargs=* -complete=file Fpp call Findperlpackage(<q-args>)

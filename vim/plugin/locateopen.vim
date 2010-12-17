" Name:          locateopen.vim (global plugin)
" Version:       1.1
" Author:        Ciaran McCreesh <ciaranm at gentoo.org>
" Updates:       http://dev.gentoo.org/~ciaranm/vim/
" Purpose:       Open a file for editing without knowing the file's path
"
" License:       You may redistribute this plugin under the same terms as Vim
"                itself.
"
" Usage:         :LocateEdit somefile.txt           " find and edit
"                :LocateSplit somefile.txt          " find and split
"                :LocateRead somefile.txt           " find and read
"                :LocateSource somefile.vim         " find and source
"
" Configuration:
"                :let g:locateopen_ignorecase = 1   " enable ignore case mode
"                :let g:locateopen_smartcase = 0    " disable smart case mode
"                :let g:locateopen_alwaysprompt = 1 " show menu for one match
"
" Requirements:  Needs 'slocate' or a compatible program. You'll also need an
"                up-to-date locate database. Most systems seem to run updatedb
"                on a daily cron, so you should be okay. Note that recently
"                created files may not show up because of this.

let s:slocate_app             = "slocate"
let s:slocate_args            = "-r"
let s:slocate_i_args          = "-i"
let s:slocate_cmd             = s:slocate_app . " " . s:slocate_args
let s:path_seperator          = "/"

let g:locateopen_ignorecase   = 0
let g:locateopen_smartcase    = 1
let g:locateopen_alwaysprompt = 0

" Escape str for passing to slocate -r, so that magic characters aren't
" interpreted as regex metachars.
function! s:EscapeForLocate(str)
    " hmm, toothpick syndrome
    return substitute(a:str, "\\W", "\\\\\\0", "g")
endfun

" Find file, and if there are several then ask the user which one is
" intended.
function! s:LocateFile(file, ignorecase, smartcase)
    let l:command = s:slocate_app
    if a:ignorecase
        let l:command = l:command . " " . s:slocate_i_args
    endif
    let l:command = l:command . " " . s:slocate_args . " '" .
        \ s:path_seperator . s:EscapeForLocate(a:file) . "$'"
    let l:options = system(l:command)

    " Do we have an error?
    " FIXME: this could potentially be broken on non-English systems, although
    " FIXME: it looks like slocate isn't nls-capable just now.
    if l:options =~ "^warning: slocate:"
        throw "LocateOpenError: Something's screwy. Have you run updatedb " .
            \ "recently?"
    endif

    " Do we have no files?
    if l:options == ""
        if (a:smartcase) && (!a:ignorecase)
            return s:LocateFile(a:file, 1, 0)
        else
            throw "LocateOpenError: No file found"
        endif
    endif

    " We have one or more files
    let l:options_copy = l:options
    let l:i = stridx(l:options, "\n")
    let l:x = 0
    while l:i > -1
        let l:option=strpart(l:options, 0, l:i)
        let l:options=strpart(l:options, l:i+1)
        let l:i = stridx(l:options, "\n")
        let l:x = l:x + 1
        echo l:x . ": " . l:option
    endwhile
    let l:options = l:options_copy
    if (l:x > 1) || (g:locateopen_alwaysprompt)
        let l:which=input("Which file? ")
        let l:y = 1
        while l:y <= l:x
            if l:y == l:which
                return strpart(l:options, 0, stridx(l:options, "\n"))
            else
                let l:options=strpart(l:options, stridx(l:options, "\n") + 1)
                let l:y = l:y + 1
            endif
        endwhile
        throw "LocateOpenError: Invalid choice"
    else
        return strpart(l:options_copy, 0, stridx(l:options_copy, "\n"))
    endif
endfun

" Find a file and run :cmd file
function! s:LocateRun(cmd, file)
    try
        let l:options = s:LocateFile(a:file, g:locateopen_ignorecase,
            \ g:locateopen_smartcase)
        exec a:cmd . ' ' . l:options
    catch /^LocateOpenError: /
        echo " "
        echoerr "Error: " . substitute(v:exception, "^LocateOpenError: ",
            \ "", "")
    endtry
endfun

" Find a file and :edit it
function! LocateEdit(file)
    call s:LocateRun('edit', a:file)
endfun

" Find a file and :split it
function! LocateSplit(file)
    call s:LocateRun('split', a:file)
endfun

" Find a file and :source it
function! LocateSource(file)
    call s:LocateRun('source', a:file)
endfun

" Find a file and :read it
function! LocateRead(file)
    call s:LocateRun('read', a:file)
endfun

" Do magicky export things
command! -nargs=1 LocateEdit   :call LocateEdit(<q-args>)
command! -nargs=1 LocateSplit  :call LocateSplit(<q-args>)
command! -nargs=1 LocateSource :call LocateSource(<q-args>)
command! -nargs=1 LocateRead   :call LocateRead(<q-args>)

" vim: set tw=80 ts=4 et :

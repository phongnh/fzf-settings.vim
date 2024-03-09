if empty(globpath(&rtp, 'plugin/fzf.vim'))
    echohl WarningMsg | echomsg 'fzf.vim is not found.' | echohl none
    finish
endif

if get(g:, 'loaded_fzf_settings_vim', 0)
    finish
endif

" Key bindings for opening selected files
let g:fzf_action = {
            \ 'ctrl-m': 'edit',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit',
            \ 'ctrl-t': 'tabedit',
            \ 'ctrl-o': has('mac') ? '!open' : '!xdg-open',
            \ }

" Check if Popup/Floating Win is available for FZF or not
if (has('nvim') && exists('*nvim_open_win') && has('nvim-0.4.2')) ||
            \ (exists('*popup_create') && has('patch-8.2.191'))
    let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.7 } }
else
    let g:fzf_layout = {}
endif

if get(g:, 'fzf_inline_info', has('nvim') || has('gui_running'))
    let $FZF_DEFAULT_OPTS .= ' --inline-info'
endif

let g:fzf_preview_key    = get(g:, 'fzf_preview_key', ';')
let g:fzf_preview_window = ['right:50%:hidden', g:fzf_preview_key]

let g:fzf_find_tool    = get(g:, 'fzf_find_tool', 'fd')
let g:fzf_follow_links = get(g:, 'fzf_follow_links', 0)

let g:fzf_ctags_bin    = get(g:, 'fzf_ctags_bin', 'ctags')
let g:fzf_ctags_ignore = get(g:, 'fzf_ctags_ignore', expand('~/.config/ctags/ignore'))

if get(g:, 'fzf_universal_ctags', fzf_settings#IsUniversalCtags(g:fzf_ctags_bin)) && filereadable(g:fzf_ctags_ignore)
    let g:fzf_tags_command = printf('%s --exclude=@%s -R', g:fzf_ctags_bin, g:fzf_ctags_ignore)
else
    let g:fzf_tags_command = printf('%s -R', g:fzf_ctags_bin)
endif

call fzf_settings#command#Init()

" Files command with preview window
command! -bang -nargs=? -complete=dir Files  call fzf_settings#vim#files(<q-args>, <bang>0)
command! -bang -nargs=? -complete=dir AFiles call fzf_settings#vim#afiles(<q-args>, <bang>0)

command! -bang -nargs=* Rg  call fzf_settings#vim#rg(shellescape(<q-args>), <bang>0)
command! -bang -nargs=* FRg call fzf_settings#vim#frg(shellescape(<q-args>), <bang>0)
command! -bang -nargs=* RRg call fzf_settings#vim#rg(<q-args>, <bang>0)
command! -bang -nargs=* RG  call fzf_settings#vim#rg2(<q-args>, <bang>0)
command! -bang -nargs=* FRG call fzf_settings#vim#frg2(<q-args>, <bang>0)
command! -bang -nargs=* RRG call fzf_settings#vim#rg2(<q-args>, <bang>0)

command! ToggleFzfFollowLinks call fzf_settings#ToggleFollowLinks()

" Extra commands
command! -bang Mru          call fzf_settings#mru#run(<bang>0)
command! -bang MruCwd       call fzf_settings#mru#run_in_cwd(<bang>0)
command! -bang MruInCwd     call fzf_settings#mru#run_in_cwd(<bang>0)
command! -bang BOutline     call fzf_settings#vim#buffer_outline(<bang>0)
command! -bang Quickfix     call fzf_settings#vim#quickfix(<bang>0)
command! -bang LocationList call fzf_settings#vim#location_list(<bang>0)
command! -bang Registers    call fzf_settings#vim#registers(<bang>0)
command! -bang Messages     call fzf_settings#vim#messages(<bang>0)

let g:loaded_fzf_settings_vim = 1

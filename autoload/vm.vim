""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" b:VM_Selection (= s:V) contains Regions, Matches, Vars (= s:v = plugin variables)

" s:Global holds the Global class methods
" s:Regions contains the regions with their contents
" s:v.matches contains the current matches as read with getmatches()

fun! vm#init_buffer(empty, ...)
    """If already initialized, return current instance."""

    if !empty(b:VM_Selection) | return s:V | endif

    let b:VM_Selection = {'Vars': {}, 'Regions': [], 'Funcs':  {},
                        \ 'Edit': {}, 'Global':  {}, 'Search': {},
                        \}

    let s:V            = b:VM_Selection

    "init classes
    let s:v            = s:V.Vars
    let s:Regions      = s:V.Regions

    let s:V.Funcs      = vm#funcs#init()

    "init search
    let s:v.def_reg          = s:V.Funcs.default_reg()
    let s:v.oldreg           = s:V.Funcs.get_reg()
    let s:v.oldsearch        = [getreg("/"), getregtype("/")]
    let @/                   = a:empty? '' : @/

    "store old vars
    let s:v.oldvirtual       = &virtualedit
    let s:v.oldwhichwrap     = &whichwrap
    let s:v.oldlz            = &lz
    let s:v.oldcase          = [&smartcase, &ignorecase]

    "init new vars

    "block: [ left edge, current right edge, min right edge for all regions ]
    let s:v.block            = [0,0,0]
    let s:v.search           = []
    let s:v.IDs_list         = []
    let s:v.ID               = 0
    let s:v.index            = -1
    let s:v.direction        = 1
    let s:v.auto             = 0
    let s:v.silence          = 0
    let s:v.eco              = 0
    let s:v.moving           = 0
    let s:v.only_this        = 0
    let s:v.only_this_always = 0
    let s:v.using_regex      = 0
    let s:v.multiline        = 0
    let s:v.block_mode       = 1
    let s:v.vertical_col     = 0

    let s:V.Search     = vm#search#init()
    let s:V.Global     = vm#global#init()
    let s:V.Edit       = vm#edit#init()
    let s:V.Insert     = vm#insert#init()

    call vm#maps#start()
    call vm#region#init()

    set virtualedit=onemore
    set ww=h,l
    set lz

    let g:VM.is_active = 1
    let s:v.multiline = 0

    call s:V.Funcs.msg("Visual-Multi started. Press <esc> to exit.\n", 0)

    return s:V
endfun


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Reset
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#reset(...)
    let &virtualedit = s:v.oldvirtual
    let &whichwrap = s:v.oldwhichwrap
    let &smartcase = s:v.oldcase[0]
    let &ignorecase = s:v.oldcase[1]
    call s:V.Funcs.restore_regs()
    call vm#maps#end()
    call vm#maps#motions(0, 1)
    let b:VM_Selection = {}
    let g:VM.is_active = 0
    let g:VM.extend_mode = 0
    let s:v.silence = 0

    "exiting manually
    if !a:0 | call s:V.Funcs.msg('Exited Visual-Multi.', 1) | endif

    call clearmatches()
    set nohlsearch
    call garbagecollect()
endfun


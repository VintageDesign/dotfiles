execute pathogen#infect()

colorscheme badwolf " saved in ~/.vim/colors/*.vim

syntax enable
set tabstop=4 " Number of visual spaces per TAB
set softtabstop=0 "Number of spaces in tab when editing
set expandtab
set shiftwidth=4
set smarttab

set number "line numbers
set cursorline
set showcmd
set scrolloff=6
" Disable auto indent on paste
set paste

set wildmenu
set lazyredraw
set showmatch "Matching brackets highlighted
" Highlight as characters are entered
set incsearch
set hlsearch "Must be turned off manually
" Turn off search highlighting with enter
nnoremap <CR> :nohl<CR><CR>

" Use ctrl+[jk] to move lines up and down in normal, insert, and visual mode.
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

set foldenable "enable folding
set foldlevelstart=15
set foldnestmax=10 "max fold level

nnoremap <space> za "Space za folds, unfolds
set foldmethod=indent

" Visual movement
nnoremap j gj
nnoremap k gk

" Move to beginning and end of line
nnoremap B ^
nnoremap E $
" Unset $ and ^ to deter vim professionals from using my device.
nnoremap $ <nop>
nnoremap ^ <nop>

" Move the cursor to the left after inserting two matching containers
inoremap '' ''<Left>
inoremap "" ""<Left>
inoremap () ()<Left>
inoremap <> <><Left>
inoremap {} {}<Left>
inoremap [] []<Left>

" Cursor
set cursorline
set cursorcolumn

" Nerdtree settings
autocmd vimenter * NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif


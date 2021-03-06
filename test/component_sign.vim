let s:suite  = themis#suite('iced.component.sign')
let s:assert = themis#helper('assert')

call iced#system#set_component('sign', {
      \ 'start': 'iced#component#sign#start',
      \ 'requires': ['ex_cmd'],
      \ })
let s:sign = iced#system#get('sign')
let s:temp_file = tempname()

function! s:setup() abort
  call writefile(map(range(10), {_, v -> printf('line%d', v)}), s:temp_file)
  call sign_unplace('*')

  call sign_define('iced_dummy1', {'text': 'd1'})
  call sign_define('iced_dummy2', {'text': 'd2'})

  call s:sign.place('iced_dummy1', 3, s:temp_file)
  call s:sign.place('iced_dummy1', 5, s:temp_file, 'group1')
  call s:sign.place('iced_dummy2', 7, s:temp_file)

  exec printf(':sp %s', s:temp_file)
endfunction

function! s:teardown() abort
  call sign_unplace('*')
  exec ':close'

  if filereadable(s:temp_file)
    call delete(s:temp_file)
  endif
endfunction

function! s:list_in_buffer() abort
  let list = s:sign.list_in_buffer(s:temp_file)
  call sort(list, {a, b -> a.lnum > b.lnum})
  call map(list, {_, v -> iced#util#select_keys(v, ['lnum', 'id', 'name', 'group'])})
  return list
endfunction

function! s:suite.place_and_list_in_buffer_test() abort
  call s:setup()

  let actual_signs = sign_getplaced(s:temp_file, {'group': '*'})[0]['signs']
  call sort(actual_signs, {a, b -> a.lnum > b.lnum})
  call map(actual_signs, {_, v -> iced#util#select_keys(v, ['lnum', 'id', 'name', 'group'])})

  call s:assert.equals(actual_signs, [
      \ {'lnum': 3, 'id': 1, 'name': 'iced_dummy1', 'group': 'default'},
      \ {'lnum': 5, 'id': 1, 'name': 'iced_dummy1', 'group': 'group1'},
      \ {'lnum': 7, 'id': 2, 'name': 'iced_dummy2', 'group': 'default'},
      \ ])

  let list = s:sign.list_in_buffer(s:temp_file)
  call sort(list, {a, b -> a.lnum > b.lnum})
  call map(list, {_, v -> iced#util#select_keys(v, ['lnum', 'id', 'name', 'group'])})
  call s:assert.equals(list, actual_signs)

  call s:teardown()
endfunction

function! s:suite.jump_to_next_test() abort
  call s:setup()

  call s:assert.equals(getcurpos()[1:2], [1, 1])
  call s:sign.jump_to_next()
  call s:assert.equals(getcurpos()[1:2], [3, 1])
  call s:sign.jump_to_next()
  call s:assert.equals(getcurpos()[1:2], [5, 1])
  call s:sign.jump_to_next()
  call s:assert.equals(getcurpos()[1:2], [7, 1])
  call s:sign.jump_to_next()
  call s:assert.equals(getcurpos()[1:2], [3, 1])

  call s:teardown()
endfunction

function! s:suite.jump_to_prev_test() abort
  call s:setup()

  call s:assert.equals(getcurpos()[1:2], [1, 1])
  call s:sign.jump_to_prev()
  call s:assert.equals(getcurpos()[1:2], [7, 1])
  call s:sign.jump_to_prev()
  call s:assert.equals(getcurpos()[1:2], [5, 1])
  call s:sign.jump_to_prev()
  call s:assert.equals(getcurpos()[1:2], [3, 1])
  call s:sign.jump_to_prev()
  call s:assert.equals(getcurpos()[1:2], [7, 1])

  call s:teardown()
endfunction

function! s:suite.unplace_by_default_group_test() abort
  call s:setup()

  call s:assert.equals(s:list_in_buffer(), [
        \ {'lnum': 3, 'id': 1, 'name': 'iced_dummy1', 'group': 'default'},
        \ {'lnum': 5, 'id': 1, 'name': 'iced_dummy1', 'group': 'group1'},
        \ {'lnum': 7, 'id': 2, 'name': 'iced_dummy2', 'group': 'default'},
        \ ])

  call s:sign.unplace_by({'file': s:temp_file})
  call s:assert.equals(s:list_in_buffer(), [
        \ {'lnum': 5, 'id': 1, 'name': 'iced_dummy1', 'group': 'group1'},
        \ ])

  call s:teardown()
endfunction

function! s:suite.unplace_by_specified_group_test() abort
  call s:setup()

  call s:assert.equals(s:list_in_buffer(), [
        \ {'lnum': 3, 'id': 1, 'name': 'iced_dummy1', 'group': 'default'},
        \ {'lnum': 5, 'id': 1, 'name': 'iced_dummy1', 'group': 'group1'},
        \ {'lnum': 7, 'id': 2, 'name': 'iced_dummy2', 'group': 'default'},
        \ ])

  call s:sign.unplace_by({'file': s:temp_file, 'group': 'group1'})
  call s:assert.equals(s:list_in_buffer(), [
        \ {'lnum': 3, 'id': 1, 'name': 'iced_dummy1', 'group': 'default'},
        \ {'lnum': 7, 'id': 2, 'name': 'iced_dummy2', 'group': 'default'},
        \ ])

  call s:sign.unplace_by({'file': s:temp_file, 'group': '*'})
  call s:assert.equals(s:list_in_buffer(), [])

  call s:teardown()
endfunction

function! s:suite.unplace_by_id_test() abort
  call s:setup()

  call s:assert.equals(s:list_in_buffer(), [
        \ {'lnum': 3, 'id': 1, 'name': 'iced_dummy1', 'group': 'default'},
        \ {'lnum': 5, 'id': 1, 'name': 'iced_dummy1', 'group': 'group1'},
        \ {'lnum': 7, 'id': 2, 'name': 'iced_dummy2', 'group': 'default'},
        \ ])

  call s:sign.unplace_by({'file': s:temp_file, 'group': '*', 'id': 2})
  call s:assert.equals(s:list_in_buffer(), [
        \ {'lnum': 3, 'id': 1, 'name': 'iced_dummy1', 'group': 'default'},
        \ {'lnum': 5, 'id': 1, 'name': 'iced_dummy1', 'group': 'group1'},
        \ ])

  call s:teardown()
endfunction

function! s:suite.unplace_by_name_test() abort
  call s:setup()

  call s:assert.equals(s:list_in_buffer(), [
        \ {'lnum': 3, 'id': 1, 'name': 'iced_dummy1', 'group': 'default'},
        \ {'lnum': 5, 'id': 1, 'name': 'iced_dummy1', 'group': 'group1'},
        \ {'lnum': 7, 'id': 2, 'name': 'iced_dummy2', 'group': 'default'},
        \ ])

  call s:sign.unplace_by({'file': s:temp_file, 'group': '*', 'name': 'iced_dummy1'})
  call s:assert.equals(s:list_in_buffer(), [
        \ {'lnum': 7, 'id': 2, 'name': 'iced_dummy2', 'group': 'default'},
        \ ])

  call s:teardown()
endfunction

function! s:suite.refresh_test() abort
  call s:setup()

  call s:assert.equals(s:list_in_buffer(), [
        \ {'lnum': 3, 'id': 1, 'name': 'iced_dummy1', 'group': 'default'},
        \ {'lnum': 5, 'id': 1, 'name': 'iced_dummy1', 'group': 'group1'},
        \ {'lnum': 7, 'id': 2, 'name': 'iced_dummy2', 'group': 'default'},
        \ ])

  call s:sign.refresh({'file': s:temp_file})
  call s:assert.equals(s:list_in_buffer(), [
        \ {'lnum': 3, 'id': 3, 'name': 'iced_dummy1', 'group': 'default'},
        \ {'lnum': 5, 'id': 1, 'name': 'iced_dummy1', 'group': 'group1'},
        \ {'lnum': 7, 'id': 4, 'name': 'iced_dummy2', 'group': 'default'},
        \ ])

  call s:teardown()
endfunction

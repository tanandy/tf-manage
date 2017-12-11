__search_path_not_found() {
    err_part1=$(decorate_error <<-HEREDOC
    Search path ${1} does not exist
    You must create it
HEREDOC)

generate_snippet=$(cat <<-HEREDOC
mkdir ${1}
HEREDOC)
err_part2=$(decorate_error <<'HEREDOC'
    Then, try auto-complete again
HEREDOC)

    # echo -ne "${err}\n$generate_snippet"
    echo -ne "\n${err_part1}\n${generate_snippet}\n${err_part2}"
}

__search_path_is_empty() {
    err_part1=$(decorate_error <<-HEREDOC
    Search path ${1} is empty
    You must create entries first
HEREDOC)

    # echo -ne "${err}\n$generate_snippet"
    echo -ne "\n${err_part1}"
}

__suggest_from_path() {
    __safe_set_bash_setting 'u'
    local search_path=${1}
    __safe_unset_bash_setting 'u'

    # test search path exists
    _cmd="test -d ${search_path}"
    run_cmd_silent "${_cmd}" "" "$(__search_path_not_found ${search_path})"
    result=$?

    # if the folder does not exist, stop building suggestions
    [ "${result}" -eq 1 ] && return 1

    # find and store suggestions
    contents="$(ls -A ${search_path})"

    # test search path not empty folder
    _cmd="test -n \"${contents}\""
    run_cmd_silent "${_cmd}" "" "$(__search_path_is_empty ${search_path})"
    result=$?

    # if the folder is empty, there are no suggestions to give
    [ "${result}" -eq 1 ] && return 1

    # otherwise, print suggestions
    echo "${contents}"
}

_tfm_suggest_arg_1() {
    __suggest_from_path "${MODULE_PATH}"
    return $?
}

_tfm_suggest_arg_2() {
    __suggest_from_path "${CONFIG_PATH}"
    return $?
}

_tfm_suggest_arg_3()
{
    echo "plan apply"
}

_tf_manage_complete() {
    # helper bootstrap
    TOOL_TLDIR=$(cd $(dirname $(readlink $(which tf))) && git rev-parse --show-toplevel && cd - > /dev/null)

    # import bash framework
    source "${TOOL_TLDIR}/vendor/bash-framework/lib/import.sh"

    # import TF wrapper modules
    source "${TOOL_TLDIR}/lib/import.sh"

    # try loading the config
    __load_config
    result=$?

    # if we have a config error, do not continue to build suggestions
    [ "${result}" -eq 1 ] && return 1

    # initialize bash completion variables
    local cur_word prev_word type_list

    # COMP_WORDS is an array of words in the current command line.
    # COMP_CWORD is the index of the current word (the one the cursor is
    # in). So COMP_WORDS[COMP_CWORD] is the current word; we also record
    # the previous word here, although this specific script doesn't
    # use it yet.
    cur_word="${COMP_WORDS[$COMP_CWORD]}"
    prev_word="${COMP_WORDS[$COMP_CWORD-1]}"

    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( $(compgen -W "$(_tfm_suggest_arg_1)" -- $cur_word) )
    elif [ $COMP_CWORD -eq 2 ]; then
        COMPREPLY=( $(compgen -W "$(_tfm_suggest_arg_2)" -- $cur_word) )
    elif [ $COMP_CWORD -eq 3 ]; then
        COMPREPLY=( $(compgen -W "$(_tfm_suggest_arg_3)" -- $cur_word) )
    else
        COMPREPLY=()
    fi
    return 0
}

# Register _tf_manage_complete to provide completion for the following commands
complete -F _tf_manage_complete tf
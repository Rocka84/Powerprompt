#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# gitstatus.sh -- produce the current git repo status on STDOUT
# Functionally equivalent to 'gitstatus.py', but written in bash (not python).
#
# Alan K. Stebbens <aks@stebbens.org> [http://github.com/aks]
# Made sourceable by F. Dillmeier <f.dillmeier@gmail.com> for powerprompt

[ "$0" != "$BASH_SOURCE" ] && __git_status_script_was_sourced="1"

git_branch=""
git_remote=""
git_upstream=""
git_staged=0
git_conflicts=0
git_changed=0
git_untracked=0
git_stashed=0
git_clean=0
git_behind=0
git_ahead=0

timeoutCommand() {
    if [ -n "$BUSYBOX" ]; then
        LC_ALL=C timeout -s SIGKILL 7 "$@"
    else
        LC_ALL=C timeout -k 9s 7s "$@"
    fi
}

loadGitStatus() {
    local show_untracked
    local gitstatus
    local status
    local stash_file
    local tag
    local ahead
    local behind

    [ -n "$1" ] && show_untracked="$1" || show_untracked="${__GIT_PROMPT_SHOW_UNTRACKED_FILES:-"no"}"
    gitstatus=$( timeoutCommand git status --untracked-files="$show_untracked" --porcelain --branch 2> /dev/null)

    if [ "$?" == 124 ]; then
        git_branch="???"
        return 1
    fi

    # if the status is empty, return now
    [ -z "$gitstatus" ] && return 1

    while IFS='' read -r line || [[ -n "$line" ]]; do
    status=${line:0:2}
    while [[ -n $status ]]; do
        case "$status" in
        #two fixed character matches, loop finished
        \#\#) branch_line="${line/\.\.\./^}"; break ;;
        \?\?) ((git_untracked++)); break ;;
        U?) ((git_conflicts++)); break;;
        ?U) ((git_conflicts++)); break;;
        DD) ((git_conflicts++)); break;;
        AA) ((git_conflicts++)); break;;
        #two character matches, first loop
        ?M) ((git_changed++)) ;;
        ?D) ((git_changed++)) ;;
        ?\ ) ;;
        #single character matches, second loop
        U) ((git_conflicts++)) ;;
        \ ) ;;
        *) ((git_staged++)) ;;
        esac
        status=${status:0:(${#status}-1)}
    done
    done <<< "$gitstatus"

    if [[ "$__GIT_PROMPT_IGNORE_STASH" != "1" ]]; then
    stash_file="$( git rev-parse --git-dir 2>/dev/null)/logs/refs/stash"
    if [[ -e "${stash_file}" ]]; then
        while IFS='' read -r wcline || [[ -n "$wcline" ]]; do
        ((git_stashed++))
        done < ${stash_file}
    fi
    fi

    if (( git_changed == 0 && git_staged == 0 && git_untracked == 0 && git_stashed == 0 && git_conflicts == 0)) ; then
        git_clean=1
    fi

    IFS="^" read -ra branch_fields <<< "${branch_line/\#\# }"
    git_branch="${branch_fields[0]}"

    if [[ "$git_branch" == *"Initial commit on"* ]]; then
    IFS=" " read -ra fields <<< "$git_branch"
    git_branch="${fields[3]}"
    git_remote="_NO_REMOTE_TRACKING_"
    elif [[ "$git_branch" == *"No commits yet on"* ]]; then
    IFS=" " read -ra fields <<< "$git_branch"
    git_branch="${fields[4]}"
    git_remote="_NO_REMOTE_TRACKING_"
    elif [[ "$git_branch" == *"no branch"* ]]; then
    tag=$( git describe --tags --exact-match )
    if [[ -n "$tag" ]]; then
        git_branch="$tag"
    else
        git_branch="_PREHASH_$( git rev-parse --short HEAD )"
    fi
    else
    if [[ "${#branch_fields[@]}" -eq 1 ]]; then
        git_remote="_NO_REMOTE_TRACKING_"
    else
        IFS="[,]" read -ra remote_fields <<< "${branch_fields[1]}"
        git_upstream="${remote_fields[0]}"
        for remote_field in "${remote_fields[@]}"; do
        if [[ "$remote_field" == "ahead "* ]]; then
            git_ahead=${remote_field:6}
            ahead="_AHEAD_${git_ahead}"
        fi
        if [[ "$remote_field" == "behind "* ]] || [[ "$remote_field" == " behind "* ]]; then
            git_behind=${remote_field:7}
            behind="_BEHIND_${git_behind# }"
        fi
        done
        git_remote="${behind}${ahead}"
    fi
    fi

    if [[ -z "$git_remote" ]] ; then
    git_remote='.'
    fi

    if [[ -z "$git_upstream" ]] ; then
    git_upstream='^'
    fi

}

if [ -z "$__git_status_script_was_sourced" ]; then
	# if this script is run by itsself
	# call that function immediatly and
	# print the results
    loadGitStatus "$@" || exit 1
    printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n" \
        "$git_branch" \
        "$git_remote" \
        "$git_upstream" \
        "$git_staged" \
        "$git_conflicts" \
        "$git_changed" \
        "$git_untracked" \
        "$git_stashed" \
        "$git_clean" \
        "$git_behind" \
        "$git_ahead"
    exit
fi

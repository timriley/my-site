---
title: Fast GitHub Clone Bash Function Using the OS X Clipboard
permalink: 2009/07/21/fast-github-clone-bash-function-using-the-os-x-clipboard
published_at: 2009-07-21 06:40:00 +0000
---

## Bash Functions Save Time

The keen programmer never has any shortage of new and interesting open source projects to inspect, and for me, GitHub is increasingly the place where the ones I want to see are hosted.

Whenever I want to have a good close look at something, I'll make a clone of the project to my computer and use TextMate to poke around the source. If I want to keep the source around for reference and have no intention to modify it, I'll clone the project to `~/Code/sources/<user_name>-<repository_name>`. I started using this naming convention to help me quickly identify where again to find the upstream copy of the project when I return to it.

I've been following this pattern for quite some months now, and in my ongoing effort to decrease keystrokes, I made a bash function to take care of it for me:

```
function ghclone {
  gh_url=${1:-`pbpaste`}
  co_dir=${HOME}/Code/sources/$(echo $gh_url | sed -e 's/^git:\/\/github.com\///; s/\//-/; s/\.git$//')

  if [-d $co_dir]; then
    cd $co_dir && git pull origin master
  else
    git clone "${gh_url}" "${co_dir}" && cd "${co_dir}"
  fi
}
```

## Optional Arguments and Clipboard Access Save Even More Time

This `ghclone` function accepts a single argument, the URL of the repository on GitHub. If it does not exist as a local clone, it will clone it and leave you in its directory. If you've already cloned it before, it will take you to the clone and update it.

This single function argument is optional, thanks to Bash's cool [parameter substitution](http://tldp.org/LDP/abs/html/parameter-substitution.html#PARAMSUBREF) capabilities. The `gh_url` variable is set from the function argument if it is passed, or from OS X's clipboard:

```
gh_url=${1:-`pbpaste`}
```

For those of us who are used to more expressive languages like Ruby, it is akin to this:

```
gh_url = ARGV[0] || `pbpaste`
```

The `pbaste` utility is shipped by default with Mac OS X, and returns the current value in the system clipboard. This is cool! It means that, with this shortcut function, I can clone GitHub repositories _very_ quickly:

1. Click the copy button next to the repository URL on GitHub.
2. Open the terminal and type `ghclone`
3. Start exploring!

Throw the function into your `~/.bash_profile` to get started. If `pbpaste` is interesting to you, be sure to check its counterpart, `pbcopy`, which you can use to populate the clipboard from the shell.


{ pkgs, ... } :
{
    programs.bash = {
        enable = true;
        enableCompletion = true;
        initExtra = ''
tabs 4
clear
PF_INFO="ascii title os kernel uptime memory shell wm" pfetch

# Fancy prompt
export PROMPT_COMMAND=__prompt_command
__prompt_command() {
    local exit="$?"
    PS1=""
    local reset='\[\e[0m\]'
    local white='\[\e[97m\]'
    local blue='\[\e[38;5;25m\]'
    local bgblue='\[\e[48;5;25m\]'
    local green='\[\e[38;5;34m\]'
    local bggreen='\[\e[48;5;34m\]'
    local gray='\[\e[38;5;238m\]'
    local bggray='\[\e[48;5;238m\]'
    local red='\[\e[38;5;124m\]'
    local bgred='\[\e[48;5;124m\]'

    # Add user
    PS1+="$white$bgblue \u$blue"
    # Add SHLVL (shell depth)
    if [ $SHLVL -gt 2 ]; then
    	PS1+="$bggreen$white $(($SHLVL - 2))$reset$green"
    fi
    # Add dir
    PS1+="$bggray$white \w$reset$gray"
        
    if [ $exit != 0 ]; then
    	# Change end color
        #PS1+="$bgred$white \w$reset$red"
        # Add exit code
        PS1+="$bgred$white $exit$reset$red"
    else
    	# Change end color
        #PS1+="$bggray$white \w$reset$gray"
        # Add end cap
        PS1+=""
    fi
    PS1+="$reset "
}
# Powerline prompt
#export PS1='\[\e[48;5;25;38;5;189m\] \u \[\e[48;5;238;38;5;25m\] \[\e[48;5;238;38;5;189m\]\w      \[\e[0m\]\[\e[38;5;238m\]\[\e[0m\] '

# Multiline prompt
#export PS1="\[\e[32m\]╭──\[\e[31m\](\[\e[34m\]\u\[\e[33m\]@\[\e[34m\]\h\[\e[31m\])\[\e[32m\]-\[\e[31m\](\[\e[34m\]\w\[\e[31m\])\[\e[32m\]-\[\e[31m\](\[\e[34m\]\d\[\e[31m\])
#\[\e[32m\]╰\[\e[0m\] "
'';
        shellAliases = {
            cm = "cmatrix -absu 2";
            pipes = "pipes.sh -KR -p 3 -t3 -c 1 -c 2 -c 3 -c 4 -c 5 -c 6";
            cl = "clear";
            ls = "lsd";
            la = "lsd -a";
            ll = "lsd -al";
            tree = "lsd --tree";
            pathfindsaver = "while sleep 1; do pathfind -f; done";
            qalc = "qalc -s 'varunits 0' -s 'angle 2'";

            flake-rebuild = "nixos-rebuild switch --flake ~/nixos-configuration";
        };
    };

    programs.zoxide = {
        enable = true;
        enableBashIntegration = true;
        options = [ "--cmd cd" ];
    };
    
    home.packages = with pkgs; [
        zoxide
        pfetch
        lsd
        libqalculate
    ];
}

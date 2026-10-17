{
    pkgs
}:

pkgs.writeShellApplication {
  name = "rofi-passmenu";
  
  runtimeInputs = with pkgs; [
    pass
    rofi
    xclip
    xdotool
    gnugrep
    gawk
    coreutils
    libnotify
  ];

  text = ''
    #!/usr/bin/env bash

    store_dir="''${PASSWORD_STORE_DIR:-$HOME/.password-store}"

    get_passwords() {
        echo "[+] Add New Password"
        if [ -d "$store_dir" ]; then
            find "$store_dir" -name "*.gpg" | sort | while IFS= read -r file; do
                pass="''${file#"$store_dir"/}"
                echo "''${pass%.gpg}"
            done
        fi
    }

    selected=$(get_passwords | rofi -dmenu -i -p "pass")
    [[ -z "$selected" ]] && exit 0

    if [[ "$selected" == "[+] Add New Password" ]]; then
        new_path=$(rofi -dmenu -p "Enter path/name for new password:")
        [[ -z "$new_path" ]] && exit 0
        
        choice=$(echo -e "Generate\nManual" | rofi -dmenu -p "Password method:")
        if [[ "$choice" == "Generate" ]]; then
            pass generate "$new_path" 20
            notify-send "Pass" "Generated password for $new_path"
        elif [[ "$choice" == "Manual" ]]; then
            new_pass=$(rofi -dmenu -p "Enter password:" -password)
            [[ -n "$new_pass" ]] && echo "$new_pass" | pass insert -m "$new_path"
        fi
        exit 0
    fi

    action=$(echo -e "1. Type Password\n2. Type Username\n3. Copy Password\n4. Copy Username\n5. Show Password" | rofi -dmenu -i -p "$selected")

    case "$action" in
        "1. Type Password")
            pass show "$selected" | head -n 1 | tr -d '\n' | xdotool type --clearmodifiers -fi -
            ;;
        "2. Type Username")
            pass show "$selected" | grep -i "^username:" | sed 's/^[^:]*:[[:space:]]*//' | tr -d '\n' | xdotool type --clearmodifiers -fi -
            ;;
        "3. Copy Password")
            pass show -c "$selected"
            ;;
        "4. Copy Username")
            pass show "$selected" | grep -i "^username:" | sed 's/^[^:]*:[[:space:]]*//' | xclip -selection clipboard
            ;;
        "5. Show Password")
            pass show "$selected" | head -n 1 | rofi -dmenu -p "Password for $selected"
            ;;
    esac
  '';
}

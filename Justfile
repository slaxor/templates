new template name:
    nix flake new -t git+https://codeberg.org/slaxor/templates#{{template}} {{name}}
    cd {{name}} && sed -i "s/__PROJECT_NAME__/{{name}}/g" $(grep -rl __PROJECT_NAME__ .)
    find {{name}} -depth -name '*__PROJECT_NAME__*' | while read -r p; do mv "$p" "$(echo "$p" | sed "s/__PROJECT_NAME__/{{name}}/g")"; done
    cd {{name}} && git init -q
    @echo "ready: cd {{name}} && direnv allow"

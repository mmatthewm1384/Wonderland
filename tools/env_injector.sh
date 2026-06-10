# Note: Do not append 'set -e' or a shebang here, as this script is explicitly designed 
# to be safely sourced directly inside your active, live terminal shell profile.

_WL_DEFINITIONS=(
    "OPENAI_API_KEY:.openai_token_vault"
    "ANTHROPIC_API_KEY:.anthropic_token_vault"
    "GEMINI_API_KEY:.gemini_token_vault"
    "GITHUB_TOKEN:.github_token_vault"
    "WANDB_API_KEY:.wandb_token_vault"
)

_WL_SECRETS_DIR="/Users/Wonderland/Wonderland/secrets"

for _DEF in "${_WL_DEFINITIONS[@]}"; do
    IFS=":" read -r _EVAR _FNAME <<< "$_DEF"
    _VPATH="$_WL_SECRETS_DIR/$_FNAME"
    
    if [ -f "$_VPATH" ]; then
        # Dynamically load the token cleanly into the active shell context
        export "$_EVAR"="$(cat "$_VPATH" | xargs)"
    fi
done

# Clean up local iteration variables from shell state namespace
unset _WL_DEFINITIONS _WL_SECRETS_DIR _DEF _EVAR _FNAME _VPATH
echo "[WONDERLAND] Active shell environment initialized with secure vault keys."

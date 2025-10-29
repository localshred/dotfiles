#!/usr/bin/env zsh

supported_language_prompts=(js elixir go ruby clojure java)
function get_language_prompt() {
  local prompt=""
  for language in $supported_language_prompts; do
    prompt_function="${language}_prompt"
    if command -v $prompt_function >/dev/null; then
      language_prompt=$(eval "${language}_prompt")
      if [[ ! -z $language_prompt ]]; then
        local prompt="$prompt %{$fg[red]%}${language_prompt}%{$reset_color%}"
      fi
    fi
  done
  echo -n $prompt
}

#!/usr/bin/env zsh

# ZSH Prompt Builder Utility
# Usage: build_prompt <side> <sections>
# Side: "left" or "right"
# Sections: array of [value, color] pairs

build_prompt() {
  local side="$1"
  shift
  local sections=("$@")

  # Color definitions
  local -A colors=(
    [black]=0
    [red]=1
    [green]=2
    [yellow]=3
    [blue]=4
    [purple]=5
    [cyan]=6
    [white]=7
    [bright_black]=8
    [bright_red]=9
    [bright_green]=10
    [bright_yellow]=11
    [bright_blue]=12
    [bright_purple]=13
    [bright_cyan]=14
    [bright_white]=15
  )

  # Arrow characters
  local right_arrow="\ue0b8"
  local left_arrow="\ue0ba"

  local result=""
  local prev_bg=""

  # Parse sections into arrays
  local -a section_values=()
  local -a section_colors=()

  # Simple parsing of the input format
  local i=1
  while [[ $i -le $# ]]; do
    local section="$@[$i]"
    # Remove brackets and split by comma
    section="${section#\[}"
    section="${section%\]}"

    # Split by comma and extract value and color
    local value="${section%%, *}"
    local color="${section##*, }"

    # Remove quotes
    value="${value#\"}"
    value="${value%\"}"
    color="${color#\"}"
    color="${color%\"}"

    # Expand any command substitutions or variables in value
    value=$(eval echo "$value")

    # Skip empty values
    [[ -n "$value" ]] && {
      section_values+=("$value")
      section_colors+=("$color")
    }

    ((i++))
  done

  local num_sections=${#section_values[@]}
  [[ $num_sections -eq 0 ]] && return

  if [[ "$side" == "left" ]]; then
    # Left prompt: sections with right-pointing arrows
    for ((i=1; i<=num_sections; i++)); do
      local value="${section_values[$i]}"
      local color="${section_colors[$i]}"
      local bg_code="${colors[$color]:-7}"
      local fg_code="0"  # Black text on colored background

      # Add the section content
      result+="%K{$bg_code}%F{$fg_code} $value %f%k"

      # Add arrow if not the last section
      if [[ $i -lt $num_sections ]]; then
      local next_color="${section_colors[$((i+1))]}"
      local next_bg_code="${colors[$next_color]:-7}"
      result+="%K{$next_bg_code}%F{$bg_code}$right_arrow%f%k"
      else
        # Final arrow with no background
        result+="%F{$bg_code}$right_arrow%f"
      fi
    done

  elif [[ "$side" == "right" ]]; then
    # Right prompt: sections with left-pointing arrows
    # Build from right to left
    for ((i=num_sections; i>=1; i--)); do
      local value="${section_values[$i]}"
      local color="${section_colors[$i]}"
      local bg_code="${colors[$color]:-7}"
      local fg_code="0"  # Black text on colored background

      # Add arrow if not the first section (rightmost)
      if [[ $i -lt $num_sections ]]; then
        local prev_color="${section_colors[$((i+1))]}"
        local prev_bg_code="${colors[$prev_color]:-7}"
        result="%K{$bg_code}%F{$prev_bg_code}$left_arrow%f%k$result"
      else
        # Leading arrow with no background
        result="%F{$bg_code}$left_arrow%f$result"
      fi

      # Add the section content
      result="%K{$bg_code}%F{$fg_code} $value %f%k$result"
    done
  fi

  echo "$result"
}

# Helper function to parse array-like input more robustly
parse_prompt_sections() {
    local input="$1"
    local -a sections=()

    # Remove outer brackets if present
    input="${input#\[}"
    input="${input%\]}"

    # Split by "], [" pattern
    local IFS=$'\n'
    local -a parts=(${(s/], [/)input})

    for part in "${parts[@]}"; do
        # Clean up the part
        part="${part#\[}"
        part="${part%\]}"

        # Extract value and color
        if [[ "$part" =~ '^"([^"]*)",\s*"([^"]*)"$' ]]; then
            local value="$match[1]"
            local color="$match[2]"

            # Expand the value
            value=$(eval echo "$value")

            [[ -n "$value" ]] && sections+=("[$value, $color]")
        fi
    done

    echo "${sections[@]}"
}

# Example usage functions

# Function to display prompt with colors (for testing)
display_prompt() {
    local prompt_string="$1"
    print -P "$prompt_string"
}

# Example usage functions
example_left_prompt() {
    local result=$(build_prompt left '["%1~", "green"]' '[$(git_prompt_info), "purple"]' '[$ZSH_THEME_GIT_PROMPT_DIRTY, "red"]')
    display_prompt "$result"
}

example_right_prompt() {
    local result=$(build_prompt right '["%~", "green"]' '["ruby:3.3.5", "purple"]')
    display_prompt "$result"
}

# Usage examples:
# my_build_prompt left '["some_dir", "green"]' '["my_git_branch_123", "purple"]' '["☣️", "yellow"]'
# my_build_prompt right '["~/code/some/dir", "green"]' '["ruby:3.3.5", "purple"]'

# To use in your .zshrc:
# PROMPT='$(my_build_prompt left '["${PWD##*/}", "green"]' '["$(git_branch_name)", "purple"]' '["☣️", "yellow"]') '
# RPROMPT='$(my_build_prompt right '["%~", "green"]' '["$(get_language_prompt)", "purple"]')'

PROMPT='%{$fg[green]%}%1~%{$reset_color%}$(git_prompt_info)%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%}) %{$fg[magenta]%}%#%{$reset_color%} '
RPROMPT='%{$fg[green]%}%~%{$reset_color%}$(get_language_prompt)'

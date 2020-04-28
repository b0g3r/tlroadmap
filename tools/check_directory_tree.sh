check_title() {
  local filepath=$1
  local has_frontmatter_title=0
  local has_ending=0
  local has_beginning=0

  if grep -q -E '^# .+$' "$filepath"; then
    # has a markdown first level header in file
    return
  fi

  # iterate line by line

  while IFS="" read -r line || [ -n "$line" ]
  do
    if [ "$line" = '---' ] && [ "$has_beginning" = 0 ]; then
      has_beginning=1
      continue
    fi
    if [ "$line" = '---' ] && [ "$has_beginning" = 1 ]; then
      has_ending=1
      break
    fi
    # check that line has title frontmatter param
    if [[ $line =~ ^title:.+$ ]]; then
      has_frontmatter_title=1
    fi
  done < "$filepath"


  if [ "$has_ending" = 0 ]; then
    echo "$filepath open_frontmatter_block Check the .md file, you have open frontmatter block (end it with '---')";
  fi

  if [ "$has_frontmatter_title" = 0 ]; then
    echo "$filepath without_title Check the .md file, it should have frontmatter block with title param or markdown first level header";
  fi
}


find "$1" -iname '*.md' -print0 |
  while IFS= read -rd '' filepath;
  do
    [[ ! $filepath =~ ^(\.?[a-z0-9-]+\/)+(ru|index|en)\.md$ ]] \
      && echo "$filepath bad_branch_name Check a directory tree, branch should be named only with lowercase letters (a-z), numbers (0-9) and hyphens (-)";

    check_title "$filepath"

  done
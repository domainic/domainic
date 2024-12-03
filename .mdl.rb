# frozen_string_literal: true

all
rule 'MD013', line_length: 120, tables: false

# Allow CHANGELOG.md like nesting
rule 'MD024', allow_different_nesting: true

# Allow ordered lists
rule 'MD029', style: 'ordered'

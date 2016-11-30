name "corporate"
description "for corporate environments that can't support non-company DNS, etc"

run_list 'recipe[workstation::default]'

override_attributes(
  'workstation' => {
    'corporate' => true,
    'crypto-policy' => 'DEFAULT'
  }
)

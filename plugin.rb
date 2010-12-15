Plugin.define do
  name    "associated_file"
  version "0.0.1"
  file    "lib", "associated_file"
  object  "Redcar::AssociatedFile"
  dependencies "project", ">0"
end
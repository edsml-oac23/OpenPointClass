file(REMOVE_RECURSE
  "/workspace/build-spec/lightgbm-prefix/src/lightgbm/lib_lightgbm.a"
  "/workspace/build-spec/lightgbm-prefix/src/lightgbm/lib_lightgbm.pdb"
)

# Per-language clean rules from dependency scanning.
foreach(lang CXX)
  include(CMakeFiles/_lightgbm.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()

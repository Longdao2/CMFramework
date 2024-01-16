#=================================================================================#
# File         make.sh                                                            #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.6                                                              #
# Release      11-10-2023                                                         #
# Details      C/C++ project management tool - [SH] Make                          #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                   Definitions                                   #
#---------------------------------------------------------------------------------#

params=("$@")
curr_opt=0
exclude_opts="move remove import export debug"
make_opts=()
proj_list=()

#---------------------------------------------------------------------------------#
#                                   Get params                                    #
#---------------------------------------------------------------------------------#

for (( i=0; i<$#; i++ ))
{
  if [ "${params[$i]}" = ":::" ]; then
    (( curr_opt = 1 ))
  else
    case $curr_opt in
      0) # options
        make_opts+=("${params[$i]}")
        ;;
      1) # projects
        proj_list+=("${params[$i]}")
        ;;
    esac
  fi
}

#---------------------------------------------------------------------------------#
#                                     Process                                     #
#---------------------------------------------------------------------------------#

if ! [ ${#proj_list[@]} = 0 ]; then
  for exclude_opt in $exclude_opts; do
    if [[ ${make_opts[@]} =~ (^|[[:space:]])$exclude_opt(\.|$|[[:space:]]) ]]; then
      echo -e "\n\033[0;31mERROR: Options [[ $exclude_opts ]] cannot be used in the list of projects\033[0m\n";
      exit 0
    fi
  done

  for curr_proj in "${proj_list[@]}"; do
    echo -e "\n=============== Project: $curr_proj ==============="
    if [ -e "./project/$curr_proj/user_cfg.mk" ]; then
      make "${make_opts[@]}" PROJ_NAME="$curr_proj" || :
    else
      echo -e "\n\033[0;31mERROR: This project does not exist\033[0m\n"
    fi
  done

else
  make "${make_opts[@]}" || :
fi

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#

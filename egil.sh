#!/bin/zsh

check_arch=$(uname -m)
#echo $check_arch
if [[ ${check_arch} == 'x86_64' ]]; then
  sqlcmdpath='/usr/local/Cellar/mssql-tools18/18.*/'
elif [[ ${check_arch} == 'arm64' ]]; then
  sqlcmdpath='/opt/homebrew/Cellar/mssql-tools18/18.*/'
fi

# add colors
autoload colors; colors
green="$fg[green]"
yellow="$bg[yellow]$fg[black]"
red="$bg[red]$fg[black]"
magenta="$bg[magenta]$fg[black]"
cyan="$bg[cyan]$fg[black]"
white="$bg[white]$fg[black]"
blue="$bg[blue]$fg[black]"
reset="$reset_color"

# Load CONFIG and settings
if [[ ${@[$#]} == 'T'  ]]; then
  EGIL_CONF=$(sed -n '2p' ~/gam/.egilconfig)
  DOMAIN=$(sed -n '4p' ~/gam/.egilconfig)
  >&2 echo "${red}  -- EGIL TEST --  ${reset}"
else
  EGIL_CONF=$(sed -n '1p' ~/gam/.egilconfig)
  DOMAIN=$(sed -n '3p' ~/gam/.egilconfig)
fi
STAFFDOMAIN=$(sed -n '5p' ~/gam/.egilconfig)
sortstring=""

# Allow for searches with or without DOMAIN:
if [[ ( ${1:u} =~ ^STUDENT$ ) || ( ${1:u} =~ ^STUDENTGROUPS$ ) ]]; then
  if [[ ${2} == *"@"* ]]; then
    searchemail=${2}
  else
    searchemail=${2}${DOMAIN}
  fi
elif [[ ( ${1:u} =~ ^STUDENTEPPN$ ) || ( ${1:u} =~ ^STAFFEPPN$ ) || ( ${1:u} =~ ^EPPN$ ) ]]; then
  if [[ ${2} == *"@"* ]]; then
    query=${2}
  else
    query=${2}${STAFFDOMAIN}
  fi
elif [[ ${1:u} =~ ^STAFF$ ]]; then
  if [[ ${2} == *"@"* ]]; then
    query=${2}
  else
    query=${2}"@"
  fi
fi

# read (lower) command arguments
case ${1:u} in

#  SCHOOLTYPE)
#    sqlstring="SELECT SchoolUnit.schoolType,SchoolUnit.displayName,SchoolUnit.schoolUnitCode,SchoolUnitGroup.displayName \
#              FROM SchoolUnit \
#              FULL OUTER JOIN SchoolUnitGroup \
#              ON SchoolUnit.schoolUnitGroup=SchoolUnitGroup.externalId \
#              WHERE schoolType = '${2}'"
#    sortstring="schools"
#    ;;
  SCHOOLS)
    sqlstring="SELECT SchoolUnit.schoolType,SchoolUnit.displayName,\
              SchoolUnit.schoolUnitCode,SchoolUnitGroup.displayName \
              FROM SchoolUnit \
              FULL OUTER JOIN SchoolUnitGroup ON SchoolUnit.schoolUnitGroup=SchoolUnitGroup.externalId"
    sortstring="schools"
    ;;
  STUDENT)
    sqlstring="SELECT Student.email,Student.civicNo,Student.givenName,Student.familyName,\
              Student.schoolYear,Student.schoolType,Student.programCode,\
              SchoolUnit.schoolUnitCode,SchoolUnit.displayName,Student.eduPersonPrincipalName \
              FROM Student \
              INNER JOIN SchoolUnit ON Student.schoolUnit=SchoolUnit.externalId \
              WHERE Student.email = '${searchemail}'"
    ;;
  STUDENTPNR)
    sqlstring="SELECT Student.email,Student.civicNo,Student.givenName,Student.familyName,\
              Student.schoolYear,Student.schoolType,Student.programCode,\
              SchoolUnit.schoolUnitCode,SchoolUnit.displayName,Student.eduPersonPrincipalName \
              FROM Student \
              INNER JOIN SchoolUnit ON Student.schoolUnit=SchoolUnit.externalId \
              WHERE Student.civicNo LIKE '%${2//-}%'"
    ;;
  STUDENTEPPN)
    sqlstring="SELECT Student.email,Student.civicNo,Student.givenName,Student.familyName,\
              Student.schoolYear,Student.schoolType,Student.programCode,\
              SchoolUnit.schoolUnitCode,SchoolUnit.displayName,Student.eduPersonPrincipalName \
              FROM Student \
              INNER JOIN SchoolUnit ON Student.schoolUnit=SchoolUnit.externalId \
              WHERE Student.eduPersonPrincipalName = '${query}'"
    ;;
  STUDENTGROUPS)
    sqlstring="SELECT Student.email,StudentGroup.displayName,\
              StudentGroup.studentGroupType,StudentGroup.schoolUnitGroupCode,\
              StudentGroup.schoolType,StudentGroup.parentActivity,StudentMembership.studentGroupId,\
              ParentActivitiesDNP.schoolType,ParentActivitiesDNP.displayName \
              FROM Student \
              FULL OUTER JOIN StudentMembership ON StudentMembership.studentId=Student.externalId \
              FULL OUTER JOIN StudentGroup ON StudentMembership.studentGroupId=StudentGroup.externalId \
              FULL OUTER JOIN ParentActivitiesDNP ON StudentGroup.parentActivity=ParentActivitiesDNP.id \
              WHERE Student.email = '${searchemail}'"
    ;;
  STAFF)
    sqlstring="SELECT TeacherEmail.email,Teacher.civicNo,Teacher.givenName,\
              Teacher.familyName,Employment.employmentRole,\
              SchoolUnit.schoolUnitCode,SchoolUnit.displayName,Teacher.eduPersonPrincipalName\
              FROM TeacherEmail \
              INNER JOIN Teacher ON TeacherEmail.teacherId=Teacher.externalId \
              FULL OUTER JOIN Employment ON TeacherEmail.teacherId=Employment.teacherId \
              FULL OUTER JOIN SchoolUnit ON Employment.schoolUnit=SchoolUnit.externalId \
              WHERE TeacherEmail.email LIKE '${query}%'"
    ;;
  STAFFPNR)
    sqlstring="SELECT TeacherEmail.email,Teacher.civicNo,Teacher.givenName,\
              Teacher.familyName,Employment.employmentRole,\
              SchoolUnit.schoolUnitCode,SchoolUnit.displayName,Teacher.eduPersonPrincipalName\
              FROM Teacher \
              INNER JOIN TeacherEmail ON TeacherEmail.teacherId=Teacher.externalId \
              FULL OUTER JOIN Employment ON TeacherEmail.teacherId=Employment.teacherId \
              FULL OUTER JOIN SchoolUnit ON Employment.schoolUnit=SchoolUnit.externalId \
              WHERE Teacher.civicNo LIKE '%${2}%'"
    ;;
  STAFFEPPN)
    sqlstring="SELECT TeacherEmail.email,Teacher.civicNo,Teacher.givenName,\
              Teacher.familyName,Employment.employmentRole,\
              SchoolUnit.schoolUnitCode,SchoolUnit.displayName,Teacher.eduPersonPrincipalName\
              FROM Teacher \
              INNER JOIN TeacherEmail ON TeacherEmail.teacherId=Teacher.externalId \
              FULL OUTER JOIN Employment ON TeacherEmail.teacherId=Employment.teacherId \
              FULL OUTER JOIN SchoolUnit ON Employment.schoolUnit=SchoolUnit.externalId \
              WHERE Teacher.eduPersonPrincipalName = '${query}'"
    ;;
  REKTOR)
    sqlstring="SELECT Teacher.givenName,Teacher.familyName,TeacherEmail.email,\
              SchoolUnit.schoolUnitCode,SchoolUnit.displayName,SchoolUnit.schoolType,\
              SchoolUnitGroup.displayName\
              FROM Employment \
              FULL OUTER JOIN Teacher ON Employment.teacherId=Teacher.externalId \
              FULL OUTER JOIN SchoolUnit ON Employment.schoolUnit=SchoolUnit.externalId \
              FULL OUTER JOIN SchoolUnitGroup ON SchoolUnit.schoolUnitGroup=SchoolUnitGroup.externalId \
              FULL OUTER JOIN TeacherEmail ON Teacher.externalId=TeacherEmail.teacherId \
              WHERE Employment.employmentRoleTypeId = '1' AND TeacherEmail.emailType = 'Arbete övrigt'"
    sortstring="rektor"
    ;;
  ADMIN)
    sqlstring="SELECT Teacher.givenName,Teacher.familyName,TeacherEmail.email,\
              SchoolUnit.schoolUnitCode,SchoolUnit.displayName,SchoolUnit.schoolType,\
              SchoolUnitGroup.displayName\
              FROM Employment \
              FULL OUTER JOIN Teacher ON Employment.teacherId=Teacher.externalId \
              FULL OUTER JOIN SchoolUnit ON Employment.schoolUnit=SchoolUnit.externalId \
              FULL OUTER JOIN SchoolUnitGroup ON SchoolUnit.schoolUnitGroup=SchoolUnitGroup.externalId \
              FULL OUTER JOIN TeacherEmail ON Teacher.externalId=TeacherEmail.teacherId \
              WHERE Employment.employmentRoleTypeId = '2' AND TeacherEmail.emailType = 'Arbete övrigt'"
    sortstring="rektor"
    ;;
  EPPN)
    sqlstring="SELECT TeacherEmail.email,Teacher.civicNo,Teacher.givenName,\
              Teacher.familyName,\
              Teacher.eduPersonPrincipalName\
              FROM Teacher \
              INNER JOIN TeacherEmail ON TeacherEmail.teacherId=Teacher.externalId \
              WHERE Teacher.eduPersonPrincipalName = '${query}'
              UNION
              SELECT Student.email,Student.civicNo,Student.givenName,Student.familyName,\
              Student.eduPersonPrincipalName \
              FROM Student \
              WHERE Student.eduPersonPrincipalName = '${query}'"
    ;;
  *)
    echo "${cyan}USAGE examples:${reset}"
    echo "${green}egil EPPN $fg[yellow]91ee1a7c-8394-4cf1-be10-6e71dbff3060${reset} //search EPPN (with or without DOMAIN)"
    echo "${green}egil student $fg[yellow]utbtestes4${reset} //search for a student via userID"
    echo "${green}egil studentPNR $fg[yellow]201101019999${reset} //search for a student via civicNo (pnr)"
    echo "${green}egil studentEPPN $fg[yellow]0de300d5-050c-46a1-ac78-46ec121db20f${reset} //search for a student via EPPN (with or without DOMAIN)"
    echo "${green}egil studentgroups $fg[yellow]utbtestes4${reset} //list a users schoolGroups"
    echo "${green}egil staff $fg[yellow]mattias.alqmawi${reset} //search for staff via email (with or without DOMAIN)"
    echo "${green}egil staffPNR $fg[yellow]19740422XX18${reset} //search for staff via civicNo (pnr)"
    echo "${green}egil staffEPPN $fg[yellow]91ee1a7c-8394-4cf1-be10-6e71dbff3060${reset} //search for staff via EPPN (with or without DOMAIN)"
#    echo "${green}egil staffgroups $fg[yellow]lisa.persson${reset} //(NOT APPLICABLE)"
    echo "${green}egil schools${reset} //a list of all schools"
#    echo "${green}egil schooltype $fg[yellow]GY${reset} //a list of all schools based on schoolType"
    echo "${green}egil rektor${reset} //a list of all principals"
    echo "${green}egil admin${reset} //a list of all admins"
    echo "$fg[magenta]Use EGIL TEST, by adding 'T' at the end of any command:${reset}"
    echo "${green}egil student utbtestes4 $fg[yellow]T${reset}"
    exit 0
    ;;

esac

#/opt/homebrew/Cellar/mssql-tools18/18.2.1.1/bin/./sqlcmd -U [user] -P [password] -S [SERVER] -C -W -s';'
## INTEL:
#/usr/local/Cellar/mssql-tools18/18.4.1.1/bin/./sqlcmd -U [user] -P [password] -S [SERVER] -C -W -s';'

RETVAL=$(eval "${sqlcmdpath}bin/./sqlcmd $EGIL_CONF -C -W -s';'" << EOF
${sqlstring}
GO
EXIT
EOF
)

last_line=$(echo $RETVAL | tail -n 1)

if [[ $last_line == '(0 rows affected)' ]]; then
  echo "${yellow}No rows returned from database${reset}"
  exit 0
fi

if [[ $sortstring == "schools" ]]; then
  echo ${RETVAL//,/.} | gsed '1 s/displayName$/schoolUnit.displayName/' \
      | gsed 2d | gsed '$ d' | gsed '$ d' | gsed 's/NULL/-/g' | csvsort -c 1,2 \
      | tee ~/gam/EGIL_out.csv | column -t -s,
elif [[ $sortstring == "rektor" ]]; then
  echo ${RETVAL//,/.} | gsed '1 s/displayName$/schoolUnitGroup.displayName/' \
      | gsed 2d | gsed '$ d' | gsed '$ d' | gsed 's/;;/;-;/g' | csvsort -d ";" -y "0" -c 6,5,2 \
      | tee ~/gam/EGIL_out.csv | gsed 's/NULL/-/g' | column -t -s,
elif [[ $sortstring == "none" ]]; then
  echo ${RETVAL//,/.}
else
  echo ${RETVAL//,/.} | gsed '1 s/displayName/schoolUnit.displayName/' | gsed '1 s/eduPersonPrincipalName/eduPersonPrincipalName(EPPN)/' \
      | gsed 's/^;/NULL;/' | gsed 's/;;/;NULL;/' |gsed 2d | gsed '$ d' | gsed '$ d' \
      | tee ~/gam/EGIL_out.csv | gsed 's/NULL/-/g' | column -t -s";"
fi

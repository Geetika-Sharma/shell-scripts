#!/bin/bash

start=`date +%s`

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
function usage()
{
    echo -e "${RED} \t\t\t\t!!!ERROR!!! \n \t\tAWS_REGION environment variable is not set. ${NC}
    
    ${YELLOW}\t\tPlease set the same by using following command:
                export AWS_REGION=<region with versioned staging functions>
                e.g export AWS_REGION=eu-west-1 ${NC}"
    exit 1
}

function usageArgs()
{
    echo -e "${RED} \t\t\t\t***Usage*** \n \t\tPlease provide the environment for which the versions are to be deleted. ${NC}
    ${YELLOW}\t\t Provide the same by following:
                $0 <Environment name> (Allowed values - stg|staging)
                e.g $0 stg ${NC}"
    exit 1
}

function getLambdaSize()
{
    TotalCodeSize=`aws lambda get-account-settings | grep TotalCodeSize | tail -1 | cut -f2 -d':' | tr -d , | awk '{ printf "%.2f\n", $1/1024/1024/1024; }'`
    FunctionCount=`aws lambda get-account-settings | grep FunctionCount | cut -f2 -d':' | tr -d ,`
    echo -e "\n \t${YELLOW}******************************************************************************
                        Total Code Size = $TotalCodeSize GB \n\t\t\tFunction Count = $FunctionCount
        ******************************************************************************${NC} \n"
    
}

if [ -z "${AWS_REGION}" ] 
then
    usage
fi

if [ $# -ne 1 ]
then
    usageArgs
fi

environment=$1

if [[ $environment =~ ^[sS]tg ]] || [[ $environment =~ ^[sS]taging ]] 
then
    echo "Checking the code size and function count before starting.."
    getLambdaSize

    # Get list of all the staging functions
    echo -e "Getting the list of all the staging lambda functions..."
    stagingFunctions=`aws lambda list-functions | grep FunctionName | grep $environment | cut -f2 -d':' | tr -d '", '`
    versionedFunctions=""

    stagingFunctionsCount=`echo $stagingFunctions | wc -w`
    if [ "$stagingFunctionsCount" -eq "0" ]
    then
        echo -e "\t\t\t\t${YELLOW}No function exists with $environment substring. \n\t\t\t\tExiting... ${NC}"
        exit
    fi

    echo -e "\nGetting list of all the versioned staging lambda functions\n"
    printf '_%.0s' {1..73}
    printf "\n|%-65s|%5s|\n" "FUNCTION NAME" "COUNT"
    printf '_%.0s' {1..73}
    echo
    while read functionName
    do
        isVersioned=`aws lambda list-versions-by-function --function-name $functionName | grep Version | grep -Eo '[0-9]{1,4}' | wc -l`
        if [ "$isVersioned" -ne "0" ] 
        then
            versionedFunctions+="$functionName,"
            printf "|%-65s|%5s|\n" $functionName $isVersioned 
            echo $functionName >> functions.tmp
        fi
    done <<< "$stagingFunctions"
    printf '_%.0s' {1..73}

    if [ ! -f functions.tmp ]
    then
        echo -e "\t\t\t\t${YELLOW}No function is versioned. \n\t\t\t\tExiting... ${NC}"
        exit
    fi

    echo -e "\n\t\t\t\t ${YELLOW}!!! Warning !!! \n If you choose 'Y' then the script will delete all the versions (except the \$LATEST) of the staging lambda functions ${NC}"
    read -p "Do you want to continue - Y/N? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then

        echo -e "\n \t******************************************************************************
                                Deleting all the versioned staging lambda functions
            ****************************************************************************** \n"
        while read versionedFunctionName
        do
            versions=`aws lambda list-versions-by-function --function-name $versionedFunctionName | grep Version | grep -Eo '[0-9]{1,4}' | sort -n`
            versionsCount=`echo $versions | wc -w`
            echo "Deleting a total of $versionsCount versions of $versionedFunctionName"
            while read version
            do
                # ALERT!! Uncomment below line to delete all the versions of the versioned Lambda Function except the $LATEST
                #aws lambda delete-function --function-name $versionedFunctionName --qualifier $version
                aws lambda get-function --function-name $versionedFunctionName --qualifier $version | grep Version
                echo "Version: $version is deleted"
            done <<< "$versions"
        done < functions.tmp
        rm functions.tmp

        echo "Checking the code size and function count after completion.."
        getLambdaSize
    else
        exit 1
    fi
else
    echo "Only allowed values are - stg and staging"
fi
end=`date +%s`
runtime=$((end-start))
echo -e "$0 ran for $runtime seconds"
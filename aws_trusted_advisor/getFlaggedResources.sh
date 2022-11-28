#!/bin/bash


# Get Ids and names
function getTrustedAdvisorChecksIdName(){
    aws support describe-trusted-advisor-checks --language "en" --query 'checks[].[id, name]' > aws_check_ids_name.txt
}

function getFlaggedResourcesCheckIds() {
    aws support describe-trusted-advisor-check-summaries --check-ids "Qch7DwouX1" "hjLMh88uM8" "DAvU99Dc4C" "Z4AUBRNSmz" "HCP4007jGY" "1iG5NDGVre" "zXCkfM1nI3" "Pfx0RwqBli" "7DAFEmoDos" "Yw2K9puPzl" "nNauJisYIT" "H7IgTzjTYb" "wuy7G1zxql" "iqdCTZKCUp" "S45wrEXrLz" "ZRxQlPsb6c" "8CNsSllI5v" "opQPADkZvH" "f2iK5R6Dep" "CLOG40CDO8" "BueAdJ7NrP" "PPkZrjsH2q" "tfg86AVHAZ" "j3DFqYTe29" "Ti39halfu8" "B913Ef6fb4" "cF171Db240" "C056F80cR3" "k3J2hns32g" "796d6f3D83" "51fC20e7I2" "c9D319e7sG" "b73EEdD790" "Cb877eB72b" "vjafUGJ9H0" "a2sEc6ILx" "xSqX82fQu" "xdeXZKIUy" "7qGXsKIUw" "N415c450f2" "N425c450f2" "N430c450f2" "Bh2xRR2FGH" "N420c450f2" "DqdJqYeRm5" "12Fnkpl8Y5" "G31sQ1E9U" "1e93e4c0b5" "R365s2Qddf" "0t121N1Ty3" "8M012Ph3U5" "4g3Nt5M1Th" "xuy7H1avtl" "ePs02jT06w" "rSs93HQwa1" "0Xc6LMYG8P" "hJ7NN0l7J9" "tV7YY0l7J9" "gI7MM0l7J9" "eI7KK0l7J9" "dH7RR0l6J9" "cG7HH0l7J9" "aW9HH0l8J6" "iH7PP0l7J9" "bW7HH0l7J9" "gW7HH0l7J9" "aW7HH0l7J9" "fW7HH0l7J9" "jL7PP0l7J9" "kM7QQ0l7J9" "lN7RR0l7J9" "nO7SS0l7J9" "oQ7TT0l7J9" "pR7UU0l7J9" "qS7VV0l7J9" "rT7WW0l7J9" "sU7XX0l7J9" "iK7OO0l7J9" "7fuccf1Mx7" "jtlIMO3qZM" "gjqMBn6pjz" "UUDvOa5r34" "jEhCtdJKOY" "dYWBaXaaMM" "3Njm0DJQO9" "keAhfbH5yb" "dV84wpqRUs" "P1jhKWEmLa" "jEECYg2YVU" "pYW8UkYz2w" "gfZAn3W7wl" "XG0aXHpIEt" "dBkuNCvqn5" "wH7DD0l3J9" "gH5CC0e3J9" "6gtQddfEw6" "c5ftjdfkMr" "ru4xfcdfMr" "dx3xfcdfMr" "ty3xfcdfMr" "dx3xfbjfMr" "dx8afcdfMr" "EM8b3yLRTr" "8wIqYSt25K" "L4dfs2Q4C5" "L4dfs2Q3C3" "L4dfs2Q3C2" "L4dfs2Q4C6" "dH7RR0l6J3" "gI7MM0l7J2" "Cm24dfsM12" "Cm24dfsM13" "Wxdfp4B1L1" "Wxdfp4B1L2" "Wxdfp4B1L3" "Wxdfp4B1L4" "Qsdfp3A4L1" "Qsdfp3A4L2" "Qsdfp3A4L3" --query 'summaries[?hasFlaggedResources==`true`].checkId' | tr -d ',[ ] " ' | grep -v '^$' > flaggedResourcesId.txt
}

getTrustedAdvisorChecksIdName
getFlaggedResourcesCheckIds

while read -r id; do 
    output=$((aws support describe-trusted-advisor-check-result --check-id $id --output table --query 'result.sort_by(flaggedResources[?status!="ok"],&metadata[2])[].metadata' 2>&1 ) 2>&1)
    checkName=`grep -A1 $id aws_check_ids_name.txt | tr -d '", ' | grep -v $id`
    echo -e "\t\t\t\t***********************************************************************"
    echo -e "\t\t\t\t\t\t $id: $checkName"
    echo -e "\t\t\t\t***********************************************************************"
    if [[ $output == *"invalid type for value"* ]]; then
        aws support describe-trusted-advisor-check-result --check-id $id --output table --query 'result.sort_by(flaggedResources[?status!="ok"],&metadata[1])[].metadata'
    else
        aws support describe-trusted-advisor-check-result --check-id $id --output table --query 'result.sort_by(flaggedResources[?status!="ok"],&metadata[2])[].metadata' 
    fi
done < flaggedResourcesId.txt
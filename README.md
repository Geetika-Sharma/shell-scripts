#  Shell Scripts
This repository contains shell scripts to accomplish various tasks.

## Features

- Different mini projects in bash to accomplish trivial tasks

### aws_trusted_advisor
This project is used to get all the resources flagged by Trusted Advisor 

### delete_all_versions_lambda
This project deletes all the versions except the $LATEST of the versioned Lambda Functions. 

The objective is to free storage as each function version and layer version consumes storage. Default storage for uploaded functions (.zip file archives) and layers is 75 GB only.
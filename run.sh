#!/bin/bash


if [ -d /home/mcooper/work-stuff ]
then
        echo "Directory /c/Users/marcc/GolandProjects/awesomeProject exists."
        terraform int
      ./terraformer-datadog import datadog --resources=monitor --filter="Name=tags;Value='team:sre','journey:tfe'" --api-key=${DD_API_KEY} --app-key=${DD_APP_KEY}
      ./terraformer-datadog import datadog --resources=dashboard  --filter="dashboard=t5u-ymn-ixs" --api-key=${DD_API_KEY} --app-key=${DD_APP_KEY}
        else
        echo "Error: Directory /home/rundeck/mbsre-rundeck-poc does not exist. Use Rundeck's Github plug-in to clone repository"
         echo "Unable to locate datadog-terraformer "
    fi
tail -f /dev/null
    exit 1
#checking
    #docker run -e DD_API_KEY=$DvitD_API_KEY -e DD_APP_KEY=$DD_APP_KEY -v "//var/run/docker.sock:/var/run/docker.sock" -v "C:\Users\marcc\GolandProjects\awesomeProject:/auto-sync/generated" -w /auto-sync -i test ./run.sh
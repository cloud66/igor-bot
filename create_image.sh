#/bin/bash
if [ $1 ]; then
 git pull
 docker build -t cloud66/igor:$1 .
 docker build -t cloud66/igor-webpage:$1 -f registration_webpage/Dockerfile .
 docker login
 docker push cloud66/igor:$1
 docker push cloud66/igor-webpage:$1
else
 echo 'The version of the new build is required'
fi
#docker build -f registration_webpage/Dockerfile . -t fuck/sticks:0.10

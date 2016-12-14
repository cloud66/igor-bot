#/bin/bash
if [ $1 ]
then
	git checkout master
 	git pull origin master
 	docker build -t cloud66/igor:latest -t cloud66/igor:$1 .
 	docker build -t cloud66/igor-webpage:latest -t cloud66/igor-webpage:$1 -f registration_webpage/Dockerfile .
 	docker push cloud66/igor:$1
 	docker push cloud66/igor-webpage:$1
else
	echo 'Please pass the new version of the build as an argument!'
fi

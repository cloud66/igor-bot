# Cloud 66 ChatOps
ChatOps is an open source Slack-bot, build by [Cloud 66](http://www.cloud66.com/?utm_source=gh&utm_medium=ghp&utm_campaign=robochat). It is your very own personal-assistant that operates on your stacks directly from the Slack chat window. Now, you can display the state of your stacks, deploy them and cancel them with simple commands such as `list` , `deploy` and `cancel`.

- Website: http://www.igor-bot.io/
- [Download Igor](app.cloud66.com/easydeploys)
- Articles: http://blog.cloud66.com/tag/igor-bot/ 

### Key features:
__________________________________________________________________
- Open Source project 
- Easy to customise to your work-flow
- Manage your Cloud 66 stacks from Slack
- Allows you to deploy specific services from specific stacks
- Allows you to cancel deploying stacks
- Allows you to display the state of your stacks for you or your team

### Quick Start:
__________________________________________________________________
#### Create a Slack bot

First thing you will need to do is to create your ChatOps bot on Slack.
-Go to `https://you_slack_team.slack.com/apps/manage/custom-integrations` 
-Go to `Bots`
-Go to `Add Configuration`
-Choose the name of your bot, the name will be required before each commands
-Save the token for later

Once you have filled the registration page you can invite your bot to any slack channels from your team you want : `/invite @bot-name`.

#### Download the app

Then you must install the ChatOps app from the Cloud66's app store
-   Go to ` https://app.cloud66.com/easydeploys`
-   Install the `ChatOps` app
-   Deploy the stack
-   Click on 'Browse' to access the web resgistration page for your bot.

#### Deregister

You may want to remove your bot, if so you just have to go to the registration page from the `Browse` of your ChatOps container and then clic on deregister. You will need to redeploy the stack for this to take effect.

### Developing RoboChat:
__________________________________________________________________

If you wish to work on the project itself, don't worry ChatOps is open source!

### Documentation:
__________________________________________________________________

The commands are the key words we are adressing to igor so that he can do the rigth operations. To give him an order you must call him by his name and then enter one of the following commands.

Here is an exemple :

`igor deploy -s my-stack-name`

Here is a list of all the commands:

-   `deploy` | `redeploy` : Deploy the specified stack.
-   `cancel` | `stop` | `exit` | `halt` : Cancel the specified stack.
-   `list` | `get` | `show` | `find` | `stacks` : List all the stacks or a specified one.

Commands you are giving to igor may accept or need options. In the next part we will see the options for each commands. If you try to use a wrong option, igor will respond with a usage message corresponding to the command you tried to use, if the usage message is not enough you may find an answer with the help option.

Here is an example:

`igor deploy -h`

To specify an environment you need to use the `-e` option followed by the full name of the environment.
To specify a stack you need to use the `-s` option followed by the full name of the stack.
To specify a service you need to use the `-v` option followed by the full name of the environment.

Here is an example of the docker service in the stack `my-stack-name` from production environment:

`igor deploy -e production -s my-stack-name -v docker`

or 

`igor deploy -v docker -e production -s my-stack-name`

The order of the options doesn't matter.

#### Deploy

The deploy command is the best alternative to deploy your stacks. Instead of going on your Cloud 66 accounr or use the toolbelt you will be able to directly do it from Slack. The deploy command only works if you provide the exact name of an existing stack, the other options such as environment ans services are optional. You will be warn if the stack you specified dosen't exist.

Here is an exemple :

`-igor deploy -s my-stack-name`

or 

`igor deploy -e production -s my-stack-name -v docker`

Trying to deploy a stack which is actually deploying will get you differents warning according to where it was launch first time. If it was from slack then the response will simply be that it is already deploying. If it was directly from Cloud 66 then you will be noticed that the deploy is now queued. If you don't want the stack to be queued for later deploy then use the `-w` option and set it as false.

Here is an example :

`igor deploy -s my-stack-name -w false

#### List

Listing the stack allow you to display for you or your team the actual state of one or multiples stack. You can choose to show 1 particular stack using the `-s` option or display all of them without using any options.


`-igor list -s my-stack-name`

or 

`igor list`

#### Cancel

The cancel command needs a stack as an option using `-s` and this is the same process as the other commands requiring a stack, you can use `-e` to choose the environment and `-v` to choose the service.

Here is an exemple :

`cancel -s my-stack-name`

Depending of the actual state of the stack you are trying to cancel you will get the apropriate answer such as already deploying, already cancelling, trying to cancel.


### Help:
__________________________________________________________________


###### If the bot doesn't connect to Slack


If you can't see your bot connected among the members of your channel on Slack it means the container running Igor ChatOps failed to launch due to an incorrect slack token, you will need to redeploy your stack and set a valid one.


(in reality if the service fail to launch is will try again every x seconds a certain number of times but I am not sure about this rule, so if the user realize he sent a wrong slack token, he can change it and it will work. But if he waits for too long before updating with a valid one then the service will not try to relaunch, should we say something in the help or just do your redeploy ?)




###### If the bot doesn't connect to Cloud 66 API


If you successfully connected igor to slack you may however have set a wrong Cloud 66 token. In this case Igor will answer you saying he can’t access Cloud 66 and you must update your token on the registration page  (no need to redeploy).




###### If you get an error while registration


If you are redirected to the error page it means we had trouble creating a file on the host and you should set the rights to the service.

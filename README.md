# Cloud 66 ChatOps
Igor is an open source Slack-bot, built by [Cloud 66](http://www.cloud66.com/?utm_source=gh&utm_medium=ghp&utm_campaign=robochat). It is your very own personal assistant that operates on your stacks directly from the Slack chat window. Now, you can display the state of your stacks, perform deployments, and cancel them with simple commands like `list` , `deploy`, and `cancel`.

- Download Igor: http://app.cloud66.com/easydeploys


### Key features:
__________________________________________________________________
- Manage your Cloud 66 stacks from Slack 
- Easy to customise to your workflow
- Allows you to deploy specific services from specific stacks
- Custom activity webhook for your stack
- Allows you to display the state of your stacks for you or your team
- Open Source project

### Quick install:
__________________________________________________________________
#### Create a Slack bot

First thing you will need to do is to create your ChatOps bot on Slack.
- Go to `https://you_slack_team.slack.com/apps/manage/custom-integrations` 
- Go to `Bots`
- Go to `Add Configuration`
- Choose the name of your bot, the name will be required before each commands
- Save the token for later

Once you have filled the registration page you can invite your bot to any slack channels from your team you want : `/invite @bot-name`.

#### Download Igor

You can install the app either from the Cloud 66 app store or from the docker-compose

Then you must install the ChatOps app from the Cloud66's app store
-   Go to ` https://app.cloud66.com/easydeploys`
-   Install the `ChatOps` app
-   Deploy the stack
-   Click on 'Browse' to access the web resgistration page for your bot.

or

the docker-compose file is available here https://github.com/cloud66/igor-bot/docker-compose.yml

#### Deregister

On the registration page from the `Browse` of your Igor registration container and then click on deregister. You will have to restart your Igor container for the changes to take place.

### Developing Igor:
__________________________________________________________________

Feel free to contibute to Igor - it's an open source project available on Github!

https://github.com/cloud66/igor-bot

### Documentation:
__________________________________________________________________

In order to address Igor, you must call it by the Slack bot name you used, followed by the command you wish to run.

Here is an exemple :

`igor deploy -s my-stack-name`

Here is a list of all the operations you can do with Igor:

##### Commands:

-   `deploy` : Deploy the specified stack - a stack is required.
-   `cancel` : Remove the stack from the deployment queue - a stack is required
-   `list` : List either all stacks, or a specific one

##### Flags:

-   `--stack` | `-s` : The exact name of the stack
-   `--environment` | `-e`  : The environment of the stack
-   `--services` | `-v` : The name of a service in the stack
-   `--wait` | `-w` : By default, if the stack is already deploying from Cloud 66, or Igor is waiting for a custom webhook URL, the deploy command will queue the stack for a later deploy. To avoid queuing, use `-w false`



### Queue deployment:
__________________________________________________________________

If you want igor to queue a deployment based on a custom webhook URL (for example, wait until the stack has no busy workers before deploying), you can use the igor-bot/config/config.yml file.



### Help:
__________________________________________________________________


#### If the bot doesn't connect to Slack

If you can't see your bot connected among the members of your channel on Slack it means the container running Igor ChatOps failed to launch - likely due to an incorrect slack token. You will need to redeploy your stack and set a valid one.

#### If Igor cannot connect to the Cloud 66 API

If you have successfully connected Igor to Slack but it cannot access Cloud 66, you may have set an incorrect Cloud 66 token. You can try updating your Cloud 66 token on the registration page.

#### If you get an error during registration

One possible reason for this is that the container does not have access to write to the host - if so, you can try setting the correct folder permissions.



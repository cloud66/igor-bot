# igor-bot
Igor is a custom Cloud 66 tool. It is a slack bot able to operate on your stacks. You will be able to manage your stacks directly through Slack. It means you can display the state of your stacks, deploy them and cancel them with simple commands such as `list` , `deploy` and `cancel`.

![Codeship Status for cloud66/habitus](https://codeship.com/projects/714284d0-e914-0133-1e5d-4eaa3299b296/status)

- Website: http://www.igor-bot.io/
- [Download Igor](https://github.com/cloud66/habitus/releases?utm_source=Githubdownload&utm_medium=GHDpage&utm_campaign=habitus)
- Slack Channel: https://cloud66ers.slack.com/messages/igor-bot/
- Articles: http://blog.cloud66.com/tag/igor-bot/ 

### Key features:
__________________________________________________________________
- Open Source project
- Manage you Cloud 66 stacks from Slack
- Allows you to deploy specififc services from specific stacks
- Allows you to cancel deploying stacks
- Allows you to display the state of your stacks for you or your team

#### Install igor-bot

Bla. Here is an example:
``` 
bla
```
#### Register

Once you have invited igor-bot to yout chat you may try any command so that he will answer by inviting you to log in your Cloud 66 accout. Register with your Cloud 66 account and then this time use the token to register through Slack.

Here is an exemple :

`igor register -c token`

Igor is now operationnal.

#### Commands

The commands are the key word we are adressing to igor so that he can do the rigth operations. To give him an order you must call him by his name then enter one of the following commands.

Here is an exemple :

`igor deploy -s my-stack-name`

Here is a list of all the commands:

-   `deploy` | `redeploy` : Deploy the specified stack.
-   `cancel` | `stop` | `exit` | `halt` : Cancel the specifield stack.
-   `register` | `authorize` | `auth` : Try to register to your Cloud 66 account with the specified token.
-   `deregister` | `deauthorize` | `deauth` : Deregister igor from your Cloud 66 account
-   `list` | `get` | `show` | `find` | `stacks` : List all the stacks or a specified one.

Commands you are giving to igor may accept or need options. In the next part we will see the options for each commands. If you miss spell or try to use a wrong option, igor will respond with a usage message corresponding to the command you tried to use, if the usage message is not enough you may find an answer with the help option.

Here is an example:

`igor deploy -h`

To specify an environment you need to use the `-e` option followed by the full name of the environment.
To specify a stack you need to use the `-s` option followed by the full name of the stack.
To specify a service you need to use the `-v` option followed by the full name of the environment.

Here is an example of the docker service in the stack `my-stack-name` from production environment:

`igor deploy -e production -s my-stack-name -v docker`

or 

`igor deploy -v docker -e production -s my-stack-name`

Note that the order of the options doesn't matter.

#### Deploy

The deploy command is the best alternative to deploy your stacks. Instead of going on your Cloud 66 account and redploy you stack you will be able to directly do it from Slack. The deploy command only works if you provide the exact name of an existing stack, the other options such as environment ans services are optional. You will be warn if the stack you specified dosen't exist.

Here is an exemple :

`-igor deploy -s my-stack-name`

or 

`igor deploy -e production -s my-stack-name -v docker`

Trying to deploy a stack which is actually deploying you will get differents warning according to where it was launch first time. If it was from slack then the response will simply be that it is already deploying. If it was directly from Cloud 66 then you will be noticed that the deploy is now queued. If you don't want the stack to be queued for later deploy then use the `-w` option and set it as false.

Here is an example :

`igor deploy -s my-stack-name -w false

#### List

Listing the stack allow you to display for you or your team the actual state of one or multiples stack. You can choose to show 1 particular stack using the -s option or display all of them without using any options.


`-igor list -s my-stack-name`

or 

`igor list`

#### Cancel

The cancel command needs a stack as an option using `-s` and this is the same process as the other commands requiring a stack, you can use `-e` to choose the environment and `-v` to choose the service.

Here is an exemple :

`cancel -s my-stack-name`

Depending of the actual state of the stack you are trying to cancel you will get the apropriate answer such as already deploying, already cancelling, trying to cancel.


igor-bot
=======

A Bot To Deploy Your Stacks
------------------------

### <a href="#welcome-to-github-pages" id="welcome-to-github-pages" class="anchor"><span class="octicon octicon-link"></span></a>Welcome to igor-bot

Igor is a custom Cloud66's tool. It is a slack bot able to operate on your stacks with commands such as `deploy` or `cancel` or `list`.

#### Install igor-bot

Bla. Here is an example:

``` 
bla
```
#### Register


#### Commands

The commands are the key word we are adressing to igor so that he can do the rigth operations. To give him an order you must call him by his name then enter one of the following commands.

Here is an exemple :

`igor deploy -s my-stack-name`

Here is a list of all step elements:

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

#### Deploy

The deploy command is the best alternative to deploy your stacks. Instead of going on your Cloud 66 account and redploy you stack you will be able to directly do it from Slack. The deploy command may only work if you provide the exact name of an existing stack. You will be warn if the stack you specified dosen't exist.

Here is an exemple :

`-igor deploy -s my-stack-name`




#### Cleanup

Cleanup is a step that runs after the build is finished for a step. At the moment, cleanup is limited to commands:

This runs the commands in the provided order on the image and then as a last step squashes the image to remove anything that’s been removed. This is particularly useful when it comes to private information like ssh private keys that need to be on the image during the build (to pull git repos for example) but can’t be published as part of the built image.

#### Image sequencing

Habitus allows dovetailing (sequencing) of images from different steps. This means a step can use the image built by the previous step as the source in its Dockerfile `FROM` command. This is done automatically if `FROM` command refers to an image name used by a previous step.

Habitus automatically parses the `FROM` image name and replaces it with the correct name when it is used in multi-tenanted setup. This enables multiple builds of the same build file to run in parallel with different session UIDs (see below).

Please note if you are using step A’s result in step B’s `FROM` statement, you need to make sure A is listed under `depends_on` attribute of B. Otherwise both A and B will be built in parallel.

#### Step dependencies

Steps can depend on each other. This can be specified by the `depends_on` attribute.

Steps can depend on one or more of the other steps. This will determine the build order for steps. Independent steps are built in parallel and according to the build order defined by dependencies.

#### Environment variables

Environment variables can be used in the build file with the `_env(VAR)` format:

      
    artifacts:
          - /go/src/go-service/_env(SERVICE_NAME)
      

This will be replaced before the build file is fed into the build engine. By default Habitus inherits all environment variables of its parent process. This can be overridden by passing environment variables into Habitus explicitly through the env command parameter:

<kbd>$ habitus -env SERVICE\_NAME=abc -env RAILS\_ENV=production</kbd>

In the example above, you can pass in AWS S3 key and secret like this:

<kbd>$ habitus -env ACCESS\_KEY=\(ACCESS_KEY -env SECRET_KEY=\)SECRET\_KEY</kbd>

#### Running commands

Habitus allows you to run an arbitary command inside of a built container. This can be useful in many cases like uploading the build artifacts to webserver, resetting your exception handling service after each build or starting your release process.

`command` attribute is optional. If present, the image is built and a container is started based on it to run the command.

`command` runs after the build, cleanup and copying of the artifacts are done.

An example to upload a build artefact to S3 can be like this

      
        FROM cloud66/uploader
        ADD ./iron-mountain /app/iron-mountain
      

`cloud66/uploader` is a simple Docker image that has [S3CMD] installed on it.

The Dockerfile here is a simple one that starts from `cloud66/uploader` and adds one of the build artifacts to the image so it can be uploaded to S3.

  [S3CMD]: http://s3tools.org/s3cmd
  
  #### Command line parameters

Habitus accepts the following command line parameters:

-   `f`: Path to the build file. If not specified, it will default to `build.yml` in the work directory.
-   `d`: Path to work directory. This is the path where Dockerfiles should exist for each step and the build happens. Defaults to the current directory.
-   `no-cache`: Don’t use docker build caching.
-   `suppress`: Suppress docker build output.
-   `rm`: Remove intermediate built images.
-   `force-rm`: Forcefully remove intermediate images.
-   `uid`: A unique ID used for a build session to allow multi-tenancy of Habitus
-   `level`: Logging level. Acceptable values: `debug`, `info`, `notice`, `warning`, `error` and critical. Defaults to `debug`
-   `host`: Address for Docker daemon to run the build. Defaults to the value of `$DOCKER_HOST`.
-   `certs`: Path of the key and cert files used to connect to the Docker daemon. Defaults to `$DOCKER_CERT_PATH`
-   `env`: Environment variables used in the build process. If not specified Habitus inherits all environment variables of the parent process.
-   `keep-all`: Overrides the keep flag for all steps so you can inspect and debug the created images of each step without changing the build file.
-   `no-cleanup`: Don’t run cleanup commands. This can be used for debugging and removes the need to run as sudo
-   `force-rmi`: Forces removal of unwanted images after the build
-   `noprune-rmi`: Doesn’t prune unwanted images after the build

#### Development Environment for Habitus

Habitus requires running in privileged more (sudo) so it can run the squash method (keeping file permissions across images). It also requires the following environment variables: `DOCKER_HOST` and `DOCKER_CERT_PATH`. These are usually available when Docker is running on a machine, but might not be available in sudo mode. To fix this, you can pass them into the app with commandline params:

<kbd>$ sudo habitus –host $DOCKER\_HOST –certs $DOCKER\_CERT\_PATH</kbd>

#### Dependencies

You would also need [gnu tar] to be available on the machine:

##### OSX

##### 

[Instructions for OSX]

#### Multi-tenancy for Habitus

Habitus supports multi-tenancy of builds by using a `uid` parameter.

All builds and images will be tagged with the `uid` for this unless a step name explicitly has a tag. In that case the tag is concatenated with the `-uid`.

  [gnu tar]: https://www.gnu.org/software/tar/
  [Instructions for OSX]: https://github.com/cloud66/habitus/blob/gh-pages/gnu-tar.md
  


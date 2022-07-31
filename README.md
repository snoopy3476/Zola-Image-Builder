# Zola Pages Deployer

  Build and deploy [Zola (static site generator)](https://www.getzola.org/) project to
  [Repository Static Pages (*GitLab*/*GitHub* Pages)](#pages-deployment) automatically,  
  whenever pushed to remote repositories (*GitLab*/*GitHub*)

## Abstract

  - Workflow on push to *GitLab*/*GitHub*
    1. Build Zola project to a static site
    2. [Optimize](#optimizer-pass) built output above
       - Optimize Zola built result with optimizer passes
       - Built-in optimizer
         - `10_minify`: Minify text files (e.g. `.html`, `.js`, `.css`)
         - `20_gzip_compression`: Perform static gzip compression on text files
       - Add other optimizer scripts in addition to built-in ones
    3. [Deploy](#pages-deployment) optimized output above to
       [*GitLab* Pages](https://docs.gitlab.com/ee/user/project/pages/) / 
       [*GitHub* Pages](https://pages.github.com/)
       - Supports [Pages Export on deploy](#pages-export)
         (deploying built pages to an external repository),
         not only to pushed repository
  

  - Use cases
    - Build Zola & deploy Pages automatically on push
      - Push to *GitLab*/*GitHub*, then *GitLab*/*GitHub* Pages site is deployed
        (for *GitHub*, [configuration](#pages-deployment) is required)
    - Build Zola in a repository A, but export & deploy the Pages outputs to another repository B
      - It is possible to push & build source in a private repository A,
        but deploy the outputs in public repository B



## Quick Start

  1. Git clone from this repository.
     - From *GitLab*
       ```shell
       git clone -b v1.0.0 --single-branch https://gitlab.com/snoopy3476/zola-pages-deployer
       cd zola-pages-deployer
       git switch -c main
       ```
     - From *GitHub*
       ```shell
       git clone -b v1.0.0 --single-branch https://github.com/snoopy3476/zola-pages-deployer
       cd zola-pages-deployer
       git switch -c main
       ```

  2. Remove the sample zola project directory.
     ('`~_sample_zola_project-remove_this_before_use`')
     ```shell
     git rm -rf ./~_sample_zola_project-remove_this_before_use
     ```

  3. Put a single Zola project directory in the Zola Pages Deployer directory.  
     (NOTE: directory name '`optimizer`', '`public`', and '`static`' are reserved
     and must not be used for inner Zola project directory!)

  4. Build
  
     - Build on remote repositories automatically
       - Push to *GitLab*/*GitHub*, then Zola project is built automatically on remote
         - Built output is also deployed to Pages if pushed to ***default branch***
     - Build locally
       - Install prerequisites
         - [`podman`](https://podman.io/) or [`docker`](https://www.docker.com/)
       - Use following scripts:
         - `./build.sh [zola-dir]`:
           Build Zola project,
           then put the result output inside the subdirectory '`public`'
         - `./img-build.sh <img-name> [zola-dir]`:
           Build Zola project,
           then put the result output inside the webserver OCI container image (`thttpd`)
           so that it can be served via container
         - `./test-img.sh [zola-dir]`:
           Build Zola project inside webserver image (`thttpd`),
           then run the Zola container created from the image.
           Note that output image and container is removed after exit



## Features

  > Following features are provided in addition to just building a Zola site.


### Optimizer Pass
  
  > After Zola build, optimizing the built result is done with optimizer passes
    (which are in the directory '`optimizer`').
  
  - Optimizer pass files should have execute permission (e.g. `$ chmod +x opt_pass_file`)
  - Optimizer passes inside the directory '`optimizer`' are run in ascending order of their filenames
    - E.g. `00_first_script` > `10_second_script` > `20_third_script` > ...
  - Each optimizer runs at a temporary directory somewhere else,
    which has two subdirectories: '`input`' and '`output`'
    - All optimizers read files to optimize from '`input`' directory,
      do optimize them,
      then put the result files inside '`output`' directory
    - Examples of optimizer files
      - Just pass input as output, without any modification:
        ```shell
        #!/bin/sh
        cp -af ./input/. ./output
        ```
      - Add gzip compressed results `(orig_filename).gz` for each input file:
        ```shell
        #!/bin/sh
        cp -af ./input/. ./output && gzip -krf9 ./output
        ```
  - Place user-defined optimizers inside the directory '`optimizer`' to add custom passes in addition to built-in ones


### Pages Deployment
  
  > When this project is pushed to a remote repository,
    Zola project is built into Pages automatically with *GitLab* CI / *GitHub* Actions.
  
  - Behaviors of the feature
  
    - On push to *GitLab*/*GitHub*, according to the pushed branch
      - ***Default branch***:
        1. First build Zola
        2. Then deploy to *GitLab*/*GitHub* Pages
      - Other branches:
        1. Build Zola only
    
    - [When ***`Pages Export`*** is enabled](#pages-export)
    
  - Required configuration for *`GitHub Pages`*
    - After first push and Pages branch creation,
      [Configure *GitHub* Pages](https://docs.github.com/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)
      on the repository to server pages
      - Set source branch to: *`pages`* (or your custom Pages branch in other name)
      - Set directory to: '`/docs`'
    - (Cf. No additional configuration is needed for *`GitLab Pages`*,
      just push to *GitLab* and it is deployed)


#### Pages Export

  > Export & deploy built result site outputs
    to an *external repository*, not deploying to the pushed repository itself.
    
  - Behavior according to whether [environment variables for Pages Export](#environment-variables-for-pages-export) is configured
    - Not configured:
      1. Build & Deploy on pushed repository
    - Configured:
      1. First build on pushed repository
      2. Then deploy on a ***different repository*** other than the pushed one



## Environment Variables

  > Set following environment variables to control build and deploy process on *GitLab*/*GitHub*.
  
  - Environment variables can be set by:
    - *GitLab*: Adding as variables in `Project Settings` > `CI/CD` > `Variables`
    - *GitHub*: Adding as secrets in `Repository Settings` > `Security` > `Secrets` > `Actions`
    - Local run: Setting as environment variables (e.g. `$ ENV1=ENVVAR1 ENV2=ENVVAR2 ./build.sh`)
  


### Environment Variables for Build

  > These environment variables take effect on build stage on *GitLab*/*GitHub*, or local manual run.
  
  
  - For Zola

    - `ZOLA_VER`: Version of Zola  
                  (e.g. `0.16.0`)
      - Default value: `latest`
    - `ZOLA_BASE_URL`: `base_url` for Zola to override default in comfig.toml

  - For webserver image
    
    > (Only for local `img-build.sh`, `test-img.sh` run. Currently not used on *GitLab*/*GitHub*)

    - `CACHE_MAX_AGE`: Default http cache-control max-age value in seconds (for thttpd).
                       This value can be overwritten on each container run
                       by setting this environment variable.
      - Default value: `600`

  - For test run
    
    > (Only for local `test-img.sh` run. Currently not used on *GitLab*/*GitHub*)

    - `EXTERNAL_PORT`: external port to get http request on test run.
      - Default value: `8000`



### Environment Variables for Pages Export
  
  > These environment variables set *path* and *authentication* information
  > of an external target repository for [Pages Export](#pages-export).
  >
  > NOTE: If Zola output site is to be served on the repository where it is pushed,
    these environment variables should NOT be set.
  >
  > Repository address format using following variables:
  > - `REPO_PROTOCOL`://`REPO_ID`:`REPO_PW`@`REPO_HOST`/`REPO`
  > - Examples
  >   - `https://(some_GITHUB_TOKEN)@github.com/snoopy3476/Zola-Pages-Deployer`
  >   - `ssh://git@github.com/snoopy3476/Zola-Pages-Deployer`
  >     - Same with: `git@github.com:snoopy3476/Zola-Pages-Deployer`


  - Repository path
    
    - `REPO_PROTOCOL`: Protocol  
                       (e.g. `ssh`, `https`)
      - Default value: `ssh`
    - `REPO_HOST`: Host name of the target repository server to push pages  
                   (e.g. `gitlab.com`, `github.com`, IP of any local hosted server)
      - Default value: Current running server
    - `REPO`: Repository name in the target repository server to push pages  
              (e.g. `username/reponame`)
      - Default value: Current repository path
    - `REPO_BRANCH`: Branch name of the repository to push pages  
                     (e.g. `pages`, `gh-pages`)
      - Default value: `pages`

  - Repository authentication
  
    > If authentication error occurs after setting *repository path* variables above,
    > set appropriate authentication info to one or more of following variables
  
    - `REPO_ID`: ID of the target repository server to push pages  
                 (e.g. `git`, server_token)
      - Default value:
        - `git` (in general cases)
        - [**GITHUB_TOKEN**](https://docs.github.com/actions/security-guides/automatic-token-authentication) (only on *GitHub* server, and `REPO_PROTOCOL` is `https`)
      - If you use
        [*GitHub* personal access token (PAT)](https://docs.github.com/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
        to export, set a PAT value to this variable
    - `REPO_PW`: Password of the target repository server to push pages  
                 (WARNING: Using this variable is not recommended in general!)
    - `REPO_KEY`: SSH private key of the target repository to push pages.
                  Used only when `REPO_PROTOCOL` is `ssh`.
      - Using *repository deploy key*
        (
         [GitLab Deploy Keys](https://docs.gitlab.com/ee/user/project/deploy_keys/)
         /
         [GitHub Deploy Keys](https://docs.github.com/developers/overview/managing-deploy-keys#deploy-keys)
        )
        is recommended, not your account SSH key directly
        1. Create a new pair of temporary RSA key in local shell
           (e.g. `$ ssh-keygen -m pem -t rsa -b 4096 -N '' -f ./tmpkey`)
        2. Copy the contents of output ***private*** key,
           and set it to this `REPO_KEY` variable
        3. Copy the contents of output ***public*** key,
           and add it as a new deploy key of the target repository
           (that you want to deploy Pages).  
           Check `Allow write access` when creating the new deploy key
        4. Remove local temporary keys created before
           (e.g. `$ rm ./tmpkey ./tmpkey.pub`)
      - RSA key (starting with `-----BEGIN RSA PRIVATE KEY-----`) is recommended,
        as SSH in *GitHub* runner does not seems to handle
        newer, non-RSA algorithms well (e.g. ed25519)



## Author
Kim Hwiwon \<kim.hwiwon@outlook.com\>



## License
The MIT License (MIT)

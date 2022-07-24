# Zola Pages Builder

  - Build [Zola (static site generator)](https://www.getzola.org/) project to
    [Repository Static Pages](#repository-static-pages-deployment) (GitLab/GitHub Pages)
    automatically with remote repository CI/CD support
      
  - Additional features
    - On pages build:
      - Minify text files (e.g. `.html`, `.js`, `.css`)
      - Perform static gzip compression on text files
    - On pages deploy:
      - Supports [deploying built pages to an external repository](#environment-variables-for-pages-export),
        not only to current repository

  - Examples: Use cases of this builder
  
    - Build Zola & deploy Pages automatically by push
      - Push to GitLab, then GitLab Pages site is deployed
      - Push to GitHub, then GitHub Pages site is deployed (after [configuration](#pages-deployment-configuration))
      
    - Build Zola in a repository A, but export & deploy the Pages outputs to another repository B
      - It is possible to push & build source in a private repository A,
        but deploy the outputs in public repository B
      - [Set related environment variables in the builder repository](#environment-variables-for-pages-export) to enable this feature



## Quick Start

  1. Remove the sample zola project directory.
     (`~_sample_zola_project-remove_this_before_use`)

  2. Put a single Zola project directory in the Zola Pages Builder directory.
     (Warning: directory name `static` and `public` are reserved for other purpose
     and must not be used for inner Zola project directory!)

  3. Build
  
     - Build on remote repositories automarically
       - Add a Zola project as subdirectory, push this project to GitLab/GitHub,
         then Zola project is built automatically on remote
       - If pushed branch is a *default branch* of that repository,
         then built Zola project is also deployed to GitLab/GitHub Pages
         
     - Build locally
       - Install prerequisites
         - [`podman`](https://podman.io/) or [`docker`](https://www.docker.com/)
       - Use following scripts:
         - `./build.sh [zola-dir]`:
           Build Zola project,
           then put the result output inside the subdirectory `public`
         - `./img-build.sh <img-name> [zola-dir]`:
           Build Zola project,
           then put the result output inside the webserver OCI container image (`thttpd`)
           so that it can be served via container
         - `./test-img.sh [zola-dir]`:
           Build Zola project inside webserver image (`thttpd`),
           then run the Zola container created from the image.
           Note that output image and container is removed after exit



## Repository Static Pages Deployment
  When this project (with a valid Zola subdirectory) is pushed to a remote repository,
  Zola project is built automatically with GitLab CI or GitHub Actions.

  In case that the pushed branch is a *default branch* of the remote repository,
  then the project is also deployed to GitLab/GitHub Pages.
  
  
### Pages Deployment Configuration

  - `GitLab Pages`
    (using GitLab CI file: `.gitlab-ci.yml`)
    - No additional configuration is needed on GitLab

  - `GitHub Pages`
    (using GitHub Actions file: `.github/workflows/deploy-pages-zola.yml`)
    - Required configuration
      - [Configure GitHub Pages](https://docs.github.com/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site) on the repository to server pages
        (which deploy a branch to GitHub Pages)
        - Set source branch to *`pages`* (or other branch if you set an output branch as different name), and directory to `/public`



## Environment Variables
  Set following environment variables to control build and deploy on server CI build.
  
  - Set environment variables at:
    - GitLab: Add as variables in `Project Settings` > `CI/CD` > `Variables`
    - GitHub: Add as secrets in `Repository Settings` > `Security` > `Secrets` > `Actions`
    - Local run: Set as environment variables (e.g. `$ ENV1=ENVVAR1 ENV2=ENVVAR2 ./build.sh`)
  


### Environment Variables for Build
  These environment variables take effect at build stage on server CI build, or local manual run.


#### Common Envs

  - `ALPINE_VER`: Version of alpine (builder and image). (Default: latest)


#### Builder Image Envs

  - `ZOLA_VER`: Version of Zola (in alpine repository). (Default: latest)
  - `ZOLA_BASE_URL`: `base_url` for Zola to override default in comfig.toml
  - `MINIFY_VER`: Version of minify (in alpine repository). (Default: latest)
  - `MINIFY_ARGS`: Additional arguments of minify. (Default: null)
  - `NO_MINIFY`: Do not perform any minify if env is set. (Default: null)
  - `GZIP_TARGET_EXTENSIONS`: File extensions list to compress with gzip,
                              separated with space.
                              To disable Gzip static compression, set this env to a single space (` `).
                              (Default: `html css js xml txt`)
  - `GZIP_COMPRESSION_LEVEL`: compression level of gzip. (Default: `9`)


#### Web Server Image Envs
  (Only for local `img-build.sh`, `test-img.sh` run. Currently not used on server CI build)

  - `THTTPD_VER`: thttpd (webserver) version. (Default: latest)
  - `CACHE_MAX_AGE`: http cache-control max-age value in seconds (for thttpd).
                     (Default: `600`)


#### Test Run Envs
  (Only for local `test-img.sh` run. Currently not used on server CI build)

  - `EXTERNAL_PORT`: external port to get http request on test run.
                     (Default: `8000`)



### Environment Variables for Pages Export
  These environment variables are used for exporting & deploying built result site outputs
  to an *external repository* with `git push`, not deploying to the building repository itself.
  
  So if Zola output site is to be served on the repository where it is built,
  these environment variables should not be set.


  - `REPO_PROTOCOL`: Protocol (ex. `ssh` (default), `https`)
  - `REPO_HOST`: Host name of the target repository server to push pages
                 (ex. `gitlab.com`, `github.com`, IP of any local hosted server).
                 (Default: current server)
  - `REPO`: Repository name in the target repository server to push pages
            (ex. `username/reponame.git`).
            (Default: current repository)
  - `REPO_BRANCH`: Branch name of the repository to push pages
                   (ex. `pages` (default), `gh-pages`).
  - `REPO_ID`: ID of the target repository server to push pages
               (ex. `git` (default), username, GITHUB_TOKEN).  
               If you use GitHub personal access token (PAT) to export,
               set the PAT value to this variable.
  - `REPO_PW`: Password of the target repository server to push pages.
  - `REPO_KEY`: Ssh private key of the target repository to push pages.
                Used only when `REPO_PROTOCOL` is `ssh`.  
                RSA key (starting with `-----BEGIN RSA PRIVATE KEY-----`) is recommended,
                as ssh in GitHub runner does not seems to handle newer algorithms (e.g. ed25519).



## Author
Kim Hwiwon \<kim.hwiwon@outlook.com\>



## License
The MIT License (MIT)

# Zola Image Builder
  Build [Zola (static site generator)](https://www.getzola.org/) project to:
  - Webserver OCI container image (podman, docker, etc.) locally
  - [Repository Pages](#repository-pages-cicd-support) (GitLab/GitHub Pages)
    automatically with remote repository CI/CD support



## Usage

  1. Remove the sample zola project directory.
     (`~_sample_zola_project-remove_this_before_use`)

  2. Put a single Zola project directory in the Zola Image Builder directory.
     (Warning: directory name `public` is reserved as output directory
      and must not be used!)

  3. Build

     - Build locally
       - Install prerequisites
         - [`podman`](https://podman.io/) or [`docker`](https://www.docker.com/)
       - Use following scripts:
         - `./build.sh [zola-dir]`:
           Build Zola project,
           then put the result output inside the subdirectory `public`
         - `./img-build.sh <img-name> [zola-dir]`:
           Build Zola project,
           then put the result output inside the webserver image (`thttpd`)
           so that it can be served via container
         - `./test-img.sh [zola-dir]`:
           Build Zola project inside webserver image (`thttpd`),
           then run the Zola container created from the image.
           Note that output image and container is removed after exit

     - Build on remote repositories automarically
       - Add a Zola project as subdirectory, push this project to GitLab/GitHub,
         then Zola project is built automatically on remote
       - If pushed branch is a *default branch* of that repository,
         then built Zola project is also deployed to GitLab/GitHub Pages
       - Check for details on
         [Repository Pages](#repository-pages-cicd-support) below



## Environment Variables


### Common Envs

  - `ALPINE_VER`: version of alpine (builder and image). (Default: latest)


### Builder Image Envs

  - `ZOLA_VER`: version of Zola (in alpine repository). (Default: latest)
  - `ZOLA_BASE_URL`: base_url for Zola to override default in comfig.toml

  - `MINIFY_VER`: version of minify (in alpine repository). (Default: latest)
  - `MINIFY_ARGS`: additional arguments of minify. (Default: null)
  - `NO_MINIFY`: do not perform any minify if env is set. (Default: null)

  - `GZIP_TARGET_EXTENSIONS`: file extensions list to compress with gzip,
                              separated with space.
                              (Default: `html css js xml txt`)
  - `GZIP_COMPRESSION_LEVEL`: compression level of gzip. (Default: `9`)


### Web Server Image Envs
  (Only for `img-build.sh`, `test-img.sh`)

  - `THTTPD_VER`: thttpd (webserver) version. (Default: latest)
  - `CACHE_MAX_AGE`: http cache-control max-age value in seconds (for thttpd).
                     (Default: `600`)


### Test Run Envs
  (Only for `test-img.sh`)

  - `EXTERNAL_PORT`: external port to get http request on test run.
                     (Default: `8000`)



## Repository Pages CI/CD support

  If this project (with a valid Zola subdirectory) is pushed to a remote repository,
  Zola project is built automatically with GitLab CI or GitHub Actions.

  In case that the pushed branch is a *default branch* of the remote repository,
  then the project is also deployed to GitLab/GitHub Pages.

  - `GitLab Pages`
    (using GitLab CI file: `.gitlab-ci.yml`)
    - No additional configuration is needed on GitLab

  - `GitHub Pages`
    (using GitHub Actions file: `.github/workflows/deploy-pages-zola.yml`)
    - Required configuration
      - [Configure GitHub Pages](https://docs.github.com/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)
        (to deploy *`gh-pages`* to GitHub Pages)
        - Set source branch to *`gh-pages`*, and directory to `/ (root)`



## Author
Kim Hwiwon \<kim.hwiwon@outlook.com\>



## License
The MIT License (MIT)

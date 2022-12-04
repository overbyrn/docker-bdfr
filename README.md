# docker-bdfr (bulk-downloader-for-reddit)

Docker version of [bulk downloader for reddit](https://github.com/aliparlakci/bulk-downloader-for-reddit). Currently tracking the development branch.

## Features
 - Configurable: runs python3 -m bdfr download using the `--opts` option to allow for configuring bdfr via a yaml file or command line args.
 - Only on the development branch as of now. See [Options](https://github.com/aliparlakci/bulk-downloader-for-reddit/tree/development#options) and [their example yaml](https://github.com/aliparlakci/bulk-downloader-for-reddit/blob/development/opts_example.yaml).
 - Optional post-download actions to sanitize filenames, remove or convert duplicates to symlinks.
 - Optional delay (random or specific) before running BDFR. Useful with multiple BDFR containers as prevents all containers downloading at the same time.
 - Configurable period to wait between multiple BDFR runs, incl. no-wait, where container will exit gracefully after a single run.

## Environment Variables

| VARIABLE         | DESCRIPTION                                                                                        | DEFAULT |
|------------------|----------------------------------------------------------------------------------------------------|:-------:|
| BDFR_POSTLIMIT   | Limit of number of submissions retrieve                                                            |    10   |
| BDFR_OFFSET      | Delay before running BDFR. Useful with multiple BDFR containers. -1=No Delay, 0=Random (1-24hrs)   |    -1   |
| BDFR_WAIT        | Time to wait (in seconds) between BDFR runs. 0 = Don't wait, just exit. Equates to a single-run    |   300   |
| BDFR_AUTH        | Run as authenticated or unauthenticated Reddit session [true/false]                                |  false  |
| BDFR_USER        | The user to run-as when running an authenticated session                                           |         |
| BDFR_VERBOSE     | Verbosity of BDFR logging. 0=INFO, 1=DEBUG, 2=FULL                                                 |    0    |
| BDFR_NODUPES     | Will not redownload files if they already exist somewhere in the download folder tree [true/false] |   true  |
| BDFR_SORT        | Downloads based on Reddit sort type. Options: controversial, hot, new, rising, top                 |   new   |
| BDFR_DETOX       | Whether to run detox to clean-up filenames [true/false]                                            |  false  |
| BDFR_RDFIND      | Whether to run rdfind to replace duplicate files [true/false]                                      |  false  |
| BDFR_RDFIND_OPTS | Use these options when running rdfind. Default action if empty: convert duplicates to symlinks     |         |
| BDFR_SYMLINKS    | Whether to run symlinks to change absolute/messy links to relative [true/false]                    |  false  |


## Setup

1. rename `options.yaml.example` -> `options.yaml`
1. rename `default_config.cfg` -> `config.cfg`
2. modify and put in a directory (ideally a persistent mounted volume)
3. choose a download directory (ideally a persistent mounted volume)
4. run docker container:
```
docker run -d \  
-v /your/config/location:/config \  
-v /your/download/location/downloads \  
-p 7634:7634 \  
-e BDFR_POSTLIMIT=9999 \
-e BDFR_OFFSET=-1 \
-e BDFR_WAIT=300 \
-e BDFR_AUTH=false \
-e BDFR_VERBOSE=0 \
-e BDFR_NODUPES=true \
-e BDFR_SORT=new \
-e BDFR_DETOX=false \
-e BDFR_RDFIND=false \
-e BDFR_SYMLINKS=false \
--name bdfr \
overbyrn/docker-bdfr
```


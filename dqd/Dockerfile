FROM docker.io/rocker/r-ver:4.2.3

RUN <<EOF
apt-get update
apt-get install -y --no-install-recommends openjdk-11-jre-headless
apt-get clean
rm -rf /var/lib/apt/lists/*

# The default GitHub Actions runner has 2 vCPUs (https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners)
install2.r --error --ncpus 2 \
    rJava \
    remotes \
    ParallelLogger \
    SqlRender \
    DatabaseConnector \
    shiny
R CMD javareconf
EOF

RUN R -e "remotes::install_github(repo = 'OHDSI/DataQualityDashboard')"

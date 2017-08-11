#!/bin/bash
set -ex

IS_PONTOON=$(git show -s --format=%s | grep -q 'Pontoon:' && echo 'true' || echo '')
if [[ $IS_PONTOON ]]; then
  echo "Skipping Integration Tests on Pontoon commit.";
  exit 0;
fi

GECKODRIVER_URL=$(
  curl -s 'https://api.github.com/repos/mozilla/geckodriver/releases/latest' |
  python -c "import sys, json; r = json.load(sys.stdin); print([a for a in r['assets'] if 'linux64' in a['name']][0]['browser_download_url']);"
);

curl -L -o geckodriver.tar.gz $GECKODRIVER_URL
gunzip -c geckodriver.tar.gz | tar xopf -
chmod +x geckodriver
sudo mv geckodriver /home/ubuntu/bin
geckodriver --version

pip install tox mozdownload mozinstall

mkdir -p /home/ubuntu/firefox-downloads/
mozdownload --version latest --type daily --destination /home/ubuntu/firefox-downloads/firefox_nightly/
mozinstall $(ls -t /home/ubuntu/firefox-downloads/firefox_nightly/*.tar.bz2 | head -1)
firefox --version
cd FoxPuppet
mkdir results
tox -- -n 4

# loco-backup
Locomotive CMS Backup Tool

## What it does

loco-backup will connect to locomotive CMS with the provided credentials, fetch all Sites you have access to and start a wagon backup for each site. 

## Setup 

Copy config example and edit it to suit your needs.

```
cp config/config.yml.example config/config.yml
bundle
```
Add your locomotive CMS Email, host and API Key. 

## Start

```
ruby backup.rb
```

# This setup for mongodb assumes that the replica set can be determined from
# the id of the minion
# NOTE: Currently this will not work behind a private device in AWS VPC. 
# http://lodge.glasgownet.com/2012/07/11/apt-key-from-behind-a-firewall/comment-page-1/
# Modern versions of MongoDB

{% set mongo_directory = salt['pillar.get']('mongodb:mongo_directory', '/mongodb') -%}
{% set use_ppa = salt['pillar.get']('mongodb:use_ppa', True) -%}
{% set settings = salt['pillar.get']('mongodb:mongo_settings') -%}
{% set version = salt['pillar.get']('mongodb:version') -%}
{% set replica_set = salt['grains.get']('replica_set') -%}

include:
  - .replica

{% if use_ppa %}
mongo_ppa:
  pkgrepo.managed:
    - humanname: MongoDB PPA
    - name: deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen
    - file: /etc/apt/sources.list.d/mongodb.list
    - keyid: 7F0CEB10
    - keyserver: keyserver.ubuntu.com

mongodb-10gen:
  pkg.installed:
{% if version %}
    - version: {{ version }}
{% endif %}
    - require:
      - pkgrepo: mongo_ppa

{% else %}

mongodb-server:
  - pkg.installed

{% endif %}

{{ mongo_directory }}:
  file.directory:
    - user: mongodb
    - group: mongodb
    - mode: 755
    - makedirs: True

{{ mongo_directory }}/data:
  file.directory:
    - user: mongodb
    - group: mongodb
    - mode: 755
    - makedirs: True

{{ mongo_directory }}/log:
  file.directory:
    - user: mongodb
    - group: mongodb
    - mode: 755
    - makedirs: True

/etc/mongodb.conf:
  file.managed:
    - source: salt://mongodb/templates/mongodb.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        replica_set: {{ replica_set }}
        settings: {{ settings }}

mongodb:
  service.running:
    - watch:
      - file: /etc/mongodb.conf
    - require:
    {% if use_ppa %}
      - pkg: mongodb-10gen
    {% else %}
      - pkg: mongodb-server
    {% endif %}

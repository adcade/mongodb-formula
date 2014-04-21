{% set replica_set = salt['grains.get']('replica_set', None) -%}
{% set replica_settings = salt['pillar.get']('mongodb:replica_settings') -%}
{% set manage_replica_set = salt['pillar.get']('mongodb:manage_replica_set', False) -%}
{% set reconfigure_replica_set = salt['pillar.get']('mongodb:reconfigure_replica_set', False) -%}
{% set mongo_settings = salt['pillar.get']('mongodb:mongo_settings') -%}

{% if replica_set %}

{% set name = replica_set %}
{% set servers = replica_settings.servers %}

/etc/replset.js:
  file.managed:
    - source: salt://mongo/templates/replset.js.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        name: {{ name }},
        servers: {{ servers }},
        manage_replica_set: {{ manage_replica_set }},
        reconfigure_replica_set: {{ reconfigure_replica_set }}

run_replica_set:
  cmd.run:
    - name: mongo /etc/replset.js
    - require:
      - file: /etc/replset.js

{% endif %}

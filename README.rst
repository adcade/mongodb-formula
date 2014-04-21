=====
MongoDB
=====

Install MongoDB from PPA or natively. 


Available states
================

``mongodb``
---------

Installs MongoDB. Set grain replica_set to name of your replica set if desired.

Currently only tested on Ubuntu 12.4.

Enable automation replica set management:

manage_replica_set: True

reconfigure_replica_set: True


#!/bin/bash

etcdctl set smokeping/config/owner "Ryan M Sutton"
etcdctl set smokeping/config/email "ping@ryanmsutton.com"
etcdctl set smokeping/config/company "Foo"

etcdctl set smokeping/config/alertto "ping@ryanmsutton.com"
etcdctl set smokeping/config/alertfrom "ping@ryanmsutton.com"

etcdctl set smokeping/targets/test/name "Test"
etcdctl set smokeping/targets/test/host "ryanmsutton.com"

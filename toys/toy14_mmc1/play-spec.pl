#!/usr/bin/env perl
use strict;
use warnings;
exec 'prove', '-v', 't/';

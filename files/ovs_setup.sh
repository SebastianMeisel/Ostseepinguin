#!/bin/bash
export namespaces=(red green blue)
declare -xA colorlist=(red '\e[31m'
		      green '\e[32m'
		      orange '\e[33m'
		      blue '\e[34m'
		      magenta '\e[35m'
		      cyan '\e[36m')

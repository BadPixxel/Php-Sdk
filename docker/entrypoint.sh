################################################################################
#
# Copyright (C) 2020 BadPixxel <www.badpixxel.com>
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#
################################################################################

# Composer Build
cat  travis/composer.sh | sh
# Execute Grump Travis Testsuite
cat travis/grumphp.sh | sh
# Run After Script
cat  travis/after.sh | sh
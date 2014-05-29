#!/bin/bash
# Copyright (C) 2014 Prgmr.com Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.

latest=$(git log -1 --pretty="format:%H")
git branch $latest || exit 1
cleanup() {
	git branch -D $latest 1> /dev/null
}
trap cleanup EXIT

tags=$(git tag -l)
latest_date=0
for tag in $tags; do
  all=$(git log -1 --pretty="format:%ct:%H" $tag)
  date=$(echo $all | cut -f1 -d:)
  hash=$(echo $all | cut -f2 -d:)
  in_head=$(git branch --contains $hash | grep -E "  ${latest}\$")
  if [ "$date" -gt "$latest_date" -a "$in_head" != "" ] ; then
    latest_date=$date
    latest_tag=$tag
    latest_hash=$hash
  fi
done

if [ "$latest_hash" = "" ] ; then
  exit 1
fi

offset=$(git log --pretty="format:%H" | grep -n $latest_hash | cut -f1 -d:)
offset=$(($offset - 1))
objname=$(echo $latest | cut -b1-7)
echo "$latest_tag-${offset}-g${objname}"

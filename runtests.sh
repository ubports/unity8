#!/bin/bash

#
# Copyright (C) 2013 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# This is a very quick and dirty attempt to figure some metrics for our tests
# It monitors all qml files with inotifywatch and generates a cobertura
# compatible coverage.xml file containing the statistics. This is far from
# perfect but its a start and indeed gives somewhat meaningful numbers
#
# If this proves to be useful, it probably could/should be rewritten
# in a more robust and flexible way, preferably in a language where
# floating point operations and xml writing is natively supported.


SRCDIR=`dirname "$(readlink -f "$0")"`

file_list=""

for i in `find . -name "*.qml" -or -name "*.js" | grep -v tests | grep -v debian | grep -v doc/`; do
  file_list="$file_list $i"
done

(inotifywatch -v -e access $file_list > statistics.txt) &
INOTIFYPID=`echo $!`

sleep 1

cd -

make -k xvfballtests
if [ $? -ne 0 ]; then
    echo '<?xml version="1.0" encoding="UTF-8" ?><testsuite errors="0" failures="1" tests="1" name="makeExitStatusTest"><properties/><testcase result="fail" name="makeExitStatus"><failure message="Make test did not suceed" result="fail"/></testcase><system-err/></testsuite>' > testMakeExitStatus.xml
fi

cd -

kill $INOTIFYPID
sleep 1

countedfiles=0
testedfiles=0
countedlines=0
testedlines=0
testedfilelist=""

for i in $file_list; do
  countedfiles=$((countedfiles+1))
  thislines=`cat $i | grep -v '^$' | wc -l`
  headerlines=`grep -n -m 1 "{" $i | cut -d ":" -f 1`
  thislines=$((thislines-headerlines))
  countedlines=$((countedlines+thislines))
  grep $i statistics.txt > /dev/null
  if [ $? -eq 0 ]; then
    echo "[Y] $i"
    testedfiles=$((testedfiles+1))
    testedlines=$((testedlines+$thislines))
    testedfilelist="$testedfilelist $i"
  else
    echo "[N] $i"
  fi
done


filespercentage=$((testedfiles*100/countedfiles))
echo "Total files: $testedfiles/$countedfiles ($filespercentage%)"


linespercentage=$((testedlines*100/countedlines))
linespercentagef=`echo "$testedlines/$countedlines" | bc -l`
echo "Total lines: $testedlines/$countedlines ($((linespercentage))%)"

cd -

coveragefile=coverage-qml.xml

echo "<?xml version=\"1.0\" ?>" > $coveragefile
echo "<!DOCTYPE coverage" >> $coveragefile
echo "  SYSTEM 'http://cobertura.sourceforge.net/xml/coverage-03.dtd'>" >> $coveragefile

echo "<coverage branch-rate=\"0.0\" line-rate=\"$linespercentagef\" timestamp=\"`date +%s`\" version=\"gcovr 2.5-prerelease\">" >> $coveragefile
echo "  <sources>" >> $coveragefile
echo "    <source>`pwd`</source>" >> $coveragefile
echo "  </sources>" >> $coveragefile
echo "  <packages>" >> $coveragefile
echo "    <package branch-rate=\"0.0\" complexity=\"0.0\" line-rate=\"$linespercentagef\" name=\"unity8\">"  >> $coveragefile
echo "      <classes>" >> $coveragefile

for i in $file_list; do
  found=0
  for j in $testedfilelist; do
    if [ $i == $j ]; then
      found=1
    fi
  done

  thislines=`cat $SRCDIR/$i | grep -v '^$' | wc -l`
  headerlines=`grep -n -m 1 "{" $SRCDIR/$i | cut -d ":" -f 1`
  thislines=$((thislines-headerlines))

  if [ $found -eq 1 ]; then
    echo "        <class branch-rate=\"0.0\" complexity=\"0.0\" filename=\"$i\" line-rate=\"1.0\" name=\"$i\">" >> $coveragefile

    echo "          <lines>" >> $coveragefile
    for linenr in $(seq 1 $thislines); do
      echo "          <line branch=\"false\" hits=\"1\" number=\"$linenr\"/>" >> $coveragefile
    done
    echo "          </lines>" >> $coveragefile

  else
    echo "        <class branch-rate=\"0.0\" complexity=\"0.0\" filename=\"$i\" line-rate=\"0.0\" name=\"$i\">" >> $coveragefile

    echo "          <lines>" >> $coveragefile
    for linenr in $(seq 1 $thislines); do
      echo "          <line branch=\"false\" hits=\"0\" number=\"$linenr\"/>" >> $coveragefile
    done
    echo "          </lines>" >> $coveragefile

  fi
    echo "        </class>" >> $coveragefile
done

echo "      </classes>" >> $coveragefile
echo "    </package>"  >> $coveragefile
echo "  </packages>" >> $coveragefile
echo "</coverage>" >> $coveragefile

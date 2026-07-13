#!/bin/sh

cd $(dirname $0)

for filename in *
do
  if [ "$filename" != "$(basename $0)" ]
  then
      ln -fs $(pwd)/$filename ~/.$filename
  fi
done


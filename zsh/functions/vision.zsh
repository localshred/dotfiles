#!/usr/bin/env sh

# Functions for working with the vision board

vimvision()
{
  vim $VISIONBOARD
}

vimvisionideas()
{
  vim "${VISIONBOARDDIR}/ideas.md"
}

vision()
{
  egrep '\[( |x)\] \*' $VISIONBOARD | sort
}

visionadd()
{
  echo "[ ] ${@}" >> $VISIONBOARD
}

visionall()
{
  cat $VISIONBOARD | sort
}

visiondone()
{
  grep '\[x\]' $VISIONBOARD | sort
}

visionstat()
{
  echo "Current: $(vision | wc -l | tr -d ' ')"
  echo "Finished: $(visiondone | wc -l | tr -d ' ')"
  echo "Total: $(visionall | wc -l | tr -d ' ')"
}


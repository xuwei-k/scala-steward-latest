#!/bin/bash

set -ex

git clone https://github.com/scala-steward-org/scala-steward.git

cd scala-steward

if [ -z $SCALA_STEWARD_VERSION ]; then
  git checkout $SCALA_STEWARD_VERSION
fi

mkdir modules/core/.jvm

echo "echo $1" > modules/core/.jvm/github_token.sh

chmod +x modules/core/.jvm/github_token.sh

echo "- $GITHUB_REPOSITORY" > modules/core/.jvm/repos.md

cs install scalafmt

echo 'TaskKey[Unit]("runGitHubAction") := Def.taskDyn {
  val args = Seq(
    Seq("--disable-sandbox"),
    Seq("--do-not-fork"),
    Seq("--workspace", "workspace"),
    Seq("--repos-file", "repos.md"),
    Seq("--git-author-email", "41898282+github-actions[bot]@users.noreply.github.com"),
    Seq("--vcs-login", "github-actions[bot]"),
    Seq("--git-ask-pass", "github_token.sh"),
  ).flatten.mkString(" ", " ", "")
  (LocalProject("core") / Compile / run).toTask(args)
}.value' > run.sbt

sbt runGitHubAction
